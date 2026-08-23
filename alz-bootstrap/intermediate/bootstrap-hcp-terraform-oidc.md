# Bootstrapping HCP Terraform ↔ Azure OIDC Trust for a New Tenant

## Why this can't just be a Terraform run

HCP Terraform (Terraform Cloud) authenticates to Azure at run time by presenting a short-lived OIDC
token that Azure exchanges for real credentials — but that exchange only works if Azure already has
a **federated identity credential** on an app registration that trusts HCP Terraform's issuer. In a
brand-new tenant nothing exists yet: no app registration, no federated credential, no management
group scoped for it, and — critically — even a Global Administrator has **no Azure RBAC rights**
until they elevate themselves.

So this has to be a one-time, human-run bootstrap using your own `az login` session, executed
**outside** Terraform (per your call: plain Azure CLI, not imported into Terraform state). Everything
built after this point — the rest of the ALZ management group hierarchy, policies, subscription
vending, landing zones — runs through HCP Terraform using the identity this bootstrap creates.
This bootstrap identity itself stays out-of-band: don't later `terraform import` it or let an ALZ
Terraform run try to manage the same app registration/federated credential/role assignment, or you'll
get drift or a run that deletes its own trust relationship.

## Order of operations

1. Sign in as a Global Administrator and confirm tenant context.
2. Elevate that Global Admin to `User Access Administrator` at root scope (`/`) — required once, in
   every new tenant, because Global Admin alone doesn't carry Azure RBAC rights.
3. Create an intermediate management group under the Tenant Root Group, and move the tenant's
   initial subscription under it. This becomes the scope the HCP Terraform identity manages.
4. Create the Entra ID app registration + service principal that will represent HCP Terraform.
5. Create **two** federated identity credentials on it — one for `run_phase:plan`, one for
   `run_phase:apply` — trusting HCP Terraform's OIDC issuer for a specific org/project/workspace.
6. Grant that service principal an RBAC role (`Contributor` by default) at the management group
   scope.
7. Configure the HCP Terraform workspace's environment variables so runs authenticate via OIDC.
8. De-elevate the Global Admin's root access again — it should not stay elevated permanently.

Steps 1–6 and 8 are the CLI script (`bootstrap-hcp-oidc.sh`). Step 7 is done once in the HCP
Terraform UI/API per workspace.

## Why step 3 (the intermediate management group) exists

The RBAC role granted in step 6 has to be scoped to something that already exists — you can't
grant a permission on a resource before it's created. In a brand-new tenant, the only things that
predate your ALZ hierarchy are the Tenant Root Group itself (scope `/`) and the initial
subscription. That leaves two options:

- **Scope the role at the true Tenant Root Group (`/`).** The HCP Terraform identity could then
  create the top-level management group itself, but the role assignment applies to the *entire
  tenant* permanently — every subscription or management group anyone creates in the future,
  related to this ALZ or not, sits under an identity with standing Contributor rights.
- **Pre-create a single anchor management group out-of-band (what this script does) and scope
  the role there.** Blast radius is limited to that one subtree. This is also what Microsoft's own
  Enterprise-Scale / ALZ accelerator guidance recommends, for the same reason.

This repo uses the second option. That means your ALZ Terraform code must treat `TENANT_MG_ID`
as an **existing** resource, not one it creates:

```hcl
# Correct — reference the bootstrap-created Intermediate Root as a data
# source, then create the standard ALZ children underneath it:
data "azurerm_management_group" "intermediate_root" {
  name = "mau-mg-root"
}

resource "azurerm_management_group" "platform" {
  name                       = "mau-mg-platform"
  display_name               = "Platform"
  parent_management_group_id = data.azurerm_management_group.intermediate_root.id
}

resource "azurerm_management_group" "connectivity" {
  name                       = "mau-mg-connectivity"
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}
```

```hcl
# Wrong — do not also declare the Intermediate Root as a managed resource;
# Terraform would fight the bootstrap script over ownership of it and
# a `terraform destroy` could delete the very MG the OIDC role assignment
# depends on.
resource "azurerm_management_group" "intermediate_root" {
  name = "mau-mg-root"
}
```

Everything *underneath* the anchor MG — child management groups, policy assignments, subscription
placement — is fair game for your ALZ Terraform to fully own.

## Prerequisites

- `zsh` (the script's shebang targets zsh, not bash — this is a standing preference for this
  project's scripts; run it as `./bootstrap-hcp-oidc.sh` or `zsh bootstrap-hcp-oidc.sh`).
- Azure CLI ≥ 2.50 (`az version`; run `az upgrade` if `az ad app federated-credential` isn't found).
- You're signed in (`az login`) as a user who is at least a Global Administrator (needed for the
  elevate-access step) or already holds `Owner`/`User Access Administrator` at root scope and
  `Application Administrator` in Entra ID.
- You know the HCP Terraform **organization name**, **project name**, and **workspace name(s)** the
  federated credentials should trust. The script below uses placeholders
  (`<TFC_ORG>`, `<TFC_PROJECT>`, `<WORKSPACE_NAME>`) — replace them before running.
- If you're running one workspace per environment (`prd`/`tst` per your naming convention), run the
  federated-credential-creation portion once per workspace name — the app registration and role
  assignment are shared, only the federated credential's `subject` changes.

## What the script does, and the placeholders to fill in

| Placeholder | Meaning | Example |
|---|---|---|
| `TENANT_MG_ID` | Machine name of the new intermediate management group (canonical ALZ term: **Intermediate Root**, sits directly under Tenant Root Group) | `mau-mg-root` |
| `TENANT_MG_DISPLAY_NAME` | Friendly display name | `MAU Intermediate Root` |
| `APP_DISPLAY_NAME` | Name of the app registration for HCP Terraform | `mau-hcp-terraform-oidc` |
| `TFC_ISSUER` | HCP Terraform issuer URL (SaaS default shown; use your TFE hostname if self-hosted) | `https://app.terraform.io` |
| `TFC_ORG` / `TFC_PROJECT` / `WORKSPACE_NAME` | Your HCP Terraform org/project/workspace | — |
| `RBAC_ROLE` | Role granted at the management group scope | `Contributor` |

Note on naming: management groups are logical/global constructs, so they don't carry an
environment or region segment the way the project's `<org>-<service>-<env>-<region>-<nnn>`
resource pattern expects — `mau-mg-root` follows the spirit (org prefix + short tag) without
forcing env/region onto something that has neither. It's deliberately *not* called
`mau-mg-platform`: in canonical ALZ terms "Platform" is a specific child management group one
level below the Intermediate Root (alongside "Landing Zones" and "Decommissioned"), and this
anchor MG sits one level above that, immediately under the Tenant Root Group.

## Compliance with the Azure Landing Zone conceptual architecture

This bootstrap slots into the canonical ALZ management group hierarchy at exactly the right
point, and mirrors how Microsoft's own ALZ Terraform accelerator handles the same chicken-and-egg
problem:

- **Position in the hierarchy.** The canonical ALZ tree is `Tenant Root Group → Intermediate Root
  → {Platform {Identity, Management, Connectivity}, Landing Zones {Corp, Online, Sandbox},
  Decommissioned}`. `TENANT_MG_ID` created here *is* the Intermediate Root node. Your ALZ
  Terraform is expected to create everything below it — that's the normal, recommended split, not
  a workaround.
- **The anchor-MG pattern matches the official accelerator.** Azure's own
  [`accelerator-bootstrap-modules`](https://github.com/Azure/accelerator-bootstrap-modules) expose
  a `root_parent_management_group_id` variable — an existing management group (or the Tenant Root
  Group) that the accelerator's Terraform is pointed at as a parent, not something it creates
  itself. This bootstrap script produces exactly that kind of pre-existing anchor for your ALZ
  code to reference the same way.
- **OIDC is the recommended auth pattern, not a substitution.** The ALZ accelerator's own CI/CD
  integrations (GitHub, Azure DevOps) use workload identity federation — federated
  credentials on a managed identity or app registration — rather than client secrets. Using OIDC
  for HCP Terraform follows the same principle for a different CI/CD system.
- **Hierarchy depth.** Microsoft's guidance recommends keeping the management group tree to a
  maximum of four levels to avoid unnecessary complexity. Tenant Root Group → Intermediate Root →
  Platform/Landing Zones/Decommissioned → their children is exactly four, so there's no headroom
  to add another layer above what your ALZ Terraform already plans without exceeding that
  guidance.

One thing worth being deliberate about: the ALZ accelerator's own bootstrap defaults to anchoring
directly at the **Tenant Root Group** (empty `root_parent_management_group_id`) rather than a
separately created Intermediate Root MG. This bootstrap script instead pre-creates that
Intermediate Root explicitly so the OIDC identity's RBAC role has a narrower scope than the true
tenant root — a stricter stance than the accelerator's default, not a looser one.

## After the script runs

Take the three printed values — `client_id` (the app's `appId`), `tenant_id`, and
`subscription_id` — and set these in the HCP Terraform workspace (**Variables → Environment
variables**, not Terraform variables):

| Variable | Value | Sensitive? |
|---|---|---|
| `TFC_AZURE_PROVIDER_AUTH` | `true` | No |
| `TFC_AZURE_RUN_CLIENT_ID` | the app's client ID | No |
| `ARM_SUBSCRIPTION_ID` | target subscription ID | No |
| `ARM_TENANT_ID` | tenant ID | No |

Do **not** set `ARM_CLIENT_ID`, `ARM_USE_OIDC`, or `ARM_CLIENT_SECRET` — HCP Terraform injects the
OIDC-derived credential itself via the `TFC_AZURE_*` variables. Your `azurerm`/`azuread` provider
blocks in the ALZ Terraform code just need `subscription_id` / `tenant_id` (or those same
`ARM_*` env vars) — no `client_id`, `use_oidc`, or secret:

```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
```

If you later add per-alias provider configurations (multiple subscriptions in one workspace), that
needs AzureRM ≥ 3.60 / Microsoft Entra ID provider ≥ 2.43 and follows a different variable
pattern (`TFC_AZURE_*[_TAG]` / `TFC_DEFAULT_AZURE_*`) — flag if you get there and this guide can be
extended.

## Cleanup / hygiene

- After confirming the role assignment landed, toggle **Microsoft Entra ID → Properties → Access
  management for Azure resources** back to **No** (or re-run the de-elevate command in the script)
  so the Global Admin doesn't retain standing root-scope RBAC.
- Rotating: federated credentials don't expire the way client secrets do, but if you ever need to
  retire this identity, delete the two federated credentials and the app registration/service
  principal directly in Azure — since this was never imported into Terraform state, there's nothing
  to `terraform destroy`.

## Verification

```bash
az ad app federated-credential list --id "$APP_ID" -o table
az role assignment list --assignee "$APP_ID" --scope "/providers/Microsoft.Management/managementGroups/$TENANT_MG_ID" -o table
```

Then trigger a plan-only run in the HCP Terraform workspace and confirm the Azure provider
initializes without any static credential configured — the run logs will show it obtained a
dynamic credential via OIDC.