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
3. Create the Entra ID app registration + service principal that will represent HCP Terraform.
4. Create **two** federated identity credentials on it — one for `run_phase:plan`, one for
   `run_phase:apply` — trusting HCP Terraform's OIDC issuer for a specific org/project/workspace.
5. Grant that service principal an RBAC role (`Owner` by default) at the true **Tenant Root Group
   scope (`/`)**.
6. Configure the HCP Terraform workspace's environment variables so runs authenticate via OIDC.
7. De-elevate the Global Admin's root access again — it should not stay elevated permanently.

Steps 1–5 and 7 are the CLI script (`bootstrap-hcp-oidc.sh`). Step 6 is done once in the HCP
Terraform UI/API per workspace.

## Why the role is granted at Tenant Root Group scope, not a pre-created anchor MG

Earlier drafts of this bootstrap pre-created a single "anchor" management group and scoped the
role there, to limit the identity's blast radius to one subtree instead of the whole tenant. That
trades against your ALZ Terraform's own job: if the role is scoped to a pre-existing anchor MG,
your Terraform code has to treat that MG as a `data` reference, not something it creates — the
very top node of your hierarchy would sit outside Terraform's control.

Per your call, this bootstrap now grants the role at the true Tenant Root Group (`/`) instead, so
your ALZ Terraform is free to create the **Intermediate Root** management group itself — and
everything below it — with nothing pre-existing to work around. This is also the ALZ accelerator's
own default: `accelerator-bootstrap-modules`' `root_parent_management_group_id` variable defaults
to the Tenant Root Group ID when left unset, and Microsoft's own accelerator walkthroughs describe
the deployment identity needing "Owner on your chosen parent management group" — root, in this
case.

The trade-off to hold onto: this service principal now carries standing `Owner` rights over
**every** subscription and management group in the tenant, permanently — not just the ones this
ALZ will ever touch. That's the accepted cost of letting Terraform own the entire hierarchy from
the top down rather than anchoring below a manually-created boundary.

Your ALZ Terraform code creates the Intermediate Root as a normal managed resource — no `data`
source needed, since nothing pre-exists above it anymore:

```hcl
resource "azurerm_management_group" "intermediate_root" {
  name         = "mau-mg-root"
  display_name = "MAU Intermediate Root"
  # no parent_management_group_id needed — defaults to the Tenant Root Group
}

resource "azurerm_management_group" "platform" {
  name                       = "mau-mg-platform"
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.intermediate_root.id
}

resource "azurerm_management_group" "connectivity" {
  name                       = "mau-mg-connectivity"
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}
```

Subscription placement (moving the tenant's initial subscription under whichever MG it ultimately
belongs in) is likewise now entirely your ALZ Terraform's job — via
`azurerm_management_group_subscription_association` — rather than something this bootstrap does.

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
| `APP_DISPLAY_NAME` | Name of the app registration for HCP Terraform | `mau-hcp-terraform-oidc` |
| `TFC_ISSUER` | HCP Terraform issuer URL (SaaS default shown; use your TFE hostname if self-hosted) | `https://app.terraform.io` |
| `TFC_ORG` / `TFC_PROJECT` / `WORKSPACE_NAME` | Your HCP Terraform org/project/workspace | — |
| `RBAC_ROLE` | Role granted at Tenant Root Group scope (`/`) | `Owner` |

## Compliance with the Azure Landing Zone conceptual architecture

This bootstrap mirrors how Microsoft's own ALZ Terraform accelerator handles the same
chicken-and-egg problem:

- **Position in the hierarchy.** The canonical ALZ tree is `Tenant Root Group → Intermediate Root
  → {Platform {Identity, Management, Connectivity}, Landing Zones {Corp, Online, Sandbox},
  Decommissioned}`. Nothing above the Tenant Root Group is created by this bootstrap — your ALZ
  Terraform creates the Intermediate Root node and everything below it, which is the normal,
  recommended split.
- **Matches the official accelerator's default scope.** Azure's own
  [`accelerator-bootstrap-modules`](https://github.com/Azure/accelerator-bootstrap-modules) expose
  a `root_parent_management_group_id` variable that defaults to the Tenant Root Group ID when left
  unset — i.e. the accelerator's own out-of-the-box behavior is to anchor at true root, not a
  pre-created intermediate MG. Granting the role at `/` here follows that same default.
- **Role matches documented accelerator guidance.** Microsoft's accelerator walkthroughs describe
  the deployment identity needing "Owner on your chosen parent management group" — Owner, not
  Contributor, because the identity also needs to assign RBAC roles during subscription vending
  and landing zone setup, which plain Contributor can't do.
- **OIDC is the recommended auth pattern, not a substitution.** The ALZ accelerator's own CI/CD
  integrations (GitHub, Azure DevOps) use workload identity federation — federated credentials on
  a managed identity or app registration — rather than client secrets. Using OIDC for HCP
  Terraform follows the same principle for a different CI/CD system.
- **Hierarchy depth.** Microsoft's guidance recommends keeping the management group tree to a
  maximum of four levels. Tenant Root Group → Intermediate Root → Platform/Landing
  Zones/Decommissioned → their children is exactly four, so there's no headroom to add another
  layer above what your ALZ Terraform already plans without exceeding that guidance.

The trade-off worth restating: this is the accelerator's *default*, but it's the broader of the
two options discussed earlier, not the narrower one. The service principal holds standing `Owner`
rights over the entire tenant permanently, not just the ALZ subtree — accepted here because it
lets Terraform own the full hierarchy from the top down.

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

```zsh
az ad app federated-credential list --id "$APP_ID" -o table
az role assignment list --assignee "$APP_ID" --scope "/" -o table
```

Then trigger a plan-only run in the HCP Terraform workspace and confirm the Azure provider
initializes without any static credential configured — the run logs will show it obtained a
dynamic credential via OIDC.

## Next: wiring up the HCP Terraform side

Once the script has run and you have `client_id` / `tenant_id` / `subscription_id` in hand:

1. **Create (or confirm) the org, project, and workspace** in HCP Terraform with the *exact* names
   used in `TFC_ORG` / `TFC_PROJECT` / `WORKSPACE_NAMES` in the script. This isn't cosmetic — the
   federated credential's `subject` string is matched literally against these names on every run,
   so a mismatch (wrong project, workspace renamed later, etc.) fails OIDC auth outright.
2. **Set execution mode to Remote.** Dynamic credentials only work on HCP Terraform's own runners —
   local execution mode never triggers the OIDC exchange, since there's no HCP Terraform run
   environment to mint the token in.
3. **Choose how runs are triggered**: VCS-driven (connect the workspace to your ALZ Terraform repo,
   most common for an ongoing platform), CLI-driven (`terraform login` + push runs manually, fine
   for iterating before you've settled the repo), or API-driven. Any of the three works with
   dynamic credentials — the auth mechanism doesn't depend on how runs are triggered.
4. **Add the four environment variables** from the table above (`TFC_AZURE_PROVIDER_AUTH`,
   `TFC_AZURE_RUN_CLIENT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID`) under the workspace's
   **Variables → Environment variables** — not Terraform variables, and not sensitive/write-only,
   since none of them are secrets (they're identifiers; the actual secret-equivalent is the OIDC
   trust relationship itself, which never touches this list).
5. **Point the Terraform working directory** at your ALZ code (the module that creates
   `azurerm_management_group.intermediate_root` and its children), and set a Terraform version
   constraint that satisfies AzureRM ≥ 3.25 / Microsoft Entra ID (`azuread`) provider ≥ 2.29 for
   basic dynamic credentials (higher minimums noted earlier if you later add multiple provider
   configurations).
6. **Run a plan-only speculative run first**, before allowing apply. Check the run log for the
   Azure provider picking up dynamic credentials — confirms the trust relationship works before
   anything gets created.
7. **Apply.** This is the run that actually creates the Intermediate Root management group and
   whatever else your ALZ code defines underneath it.
8. **Repeat steps 1 and 4** for any additional workspace (e.g. a `tst` workspace) — the app
   registration, federated credentials, and root-scope role assignment are already shared across
   all workspaces named in `WORKSPACE_NAMES`, so only the HCP Terraform-side workspace setup needs
   repeating.
9. **Don't forget the de-elevation step** from the bootstrap script's own summary — it's easy to
   consider the job done once the first apply succeeds, but that's your personal Global Admin
   access still sitting elevated at root until you turn it back off.

From here it's worth deciding, separately, how much further hardening you want on the HCP Terraform
side itself — team/RBAC access within the org, run tasks or policy-as-code (Sentinel/OPA) gating
applies, and notifications on run status — but none of that blocks getting the first successful
OIDC-authenticated apply through.

## One workspace per configuration, not one workspace for everything

If your ALZ Terraform is split across multiple root modules — the AVM starter modules line up
almost exactly with typical naming here: `avm-ptn-alz` (management group hierarchy + policy
definitions/assignments + RBAC), `avm-ptn-alz-sub-vending` (subscription vending/placement),
`avm-ptn-alz-management` (the Management landing zone's own resources — Log Analytics,
Automation Account, etc.), `avm-ptn-alz-connectivity-hub-and-spoke-vnet` or
`-virtual-wan` (the Connectivity/network landing zone) — each of these should be its **own HCP
Terraform workspace with its own state**, not stacked into a single workspace. HCP Terraform's own
guidance is explicit about this: keep workspace scope small, split by lifecycle (policy structure
changes rarely; network changes often), split by blast radius (a bad network apply shouldn't be
able to touch the management group hierarchy or policy in the same state), and split by team
ownership where different teams own different landing zones.

**Dependency order** generally runs: `alz` (core MG hierarchy + policy) first, since everything
else places resources under management groups it creates → `alz-sub-vending` next, to move/create
subscriptions into the right spot in that hierarchy → then `alz-management` and
`alz-connectivity-*` in parallel, since they deploy into different subscriptions and don't depend
on each other, only on the hierarchy and subscription placement being done.

**Passing values between them** (e.g. the management group ID from `alz` that `alz-management`
needs to know where to sit, or the hub VNet ID from `alz-connectivity` that a later spoke
workspace needs for peering): use the `tfe_outputs` data source from the `tfe` provider to read
one workspace's outputs into another's configuration, rather than hardcoding IDs or reaching for
raw remote state. You can also wire up **run triggers** between workspaces so a successful apply
in `alz` automatically queues a run in `alz-sub-vending`, and so on down the chain — that handles
ordering; `tfe_outputs` handles the actual data.

**What this means for the OIDC bootstrap**: every one of these workspaces needs its own federated
credential pair (`run_phase:plan` / `run_phase:apply`) on the same app registration — the app
registration, its Owner role at Tenant Root Group scope, and everything else stays shared across
all of them; no need to mint a separate identity per workspace unless you specifically want
tighter per-workspace RBAC scoping later (e.g. a network workspace that can't touch the management
subscription).

Don't re-run `bootstrap-hcp-oidc.sh` itself to add a workspace — `az ad app create` doesn't check
for an existing app, so a second run creates a duplicate app registration rather than reusing the
first. Instead use `add-hcp-workspace-oidc.sh <workspace-name> [<workspace-name> ...]`, a
companion script that looks up the existing app by its display name and only adds the new
federated credential pair(s):

```zsh
./add-hcp-workspace-oidc.sh alz-management alz-network alz-sub-vending
```

Same `client_id` / `tenant_id` / `subscription_id` values apply to every workspace — just repeat
the workspace-side variable setup (step 4 in the wiring-up section above) for each new one.

Organizationally, it's worth grouping these related workspaces under one HCP Terraform **Project**
(the `TFC_PROJECT` you've already been using as a placeholder) so team access and variable sets can
be managed once across all of them rather than per workspace.