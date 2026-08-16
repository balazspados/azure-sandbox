# alz

Terraform root module that deploys the core Azure Landing Zone (ALZ) architecture for MAU: the management group hierarchy, policy definitions/assignments, and policy role assignments. It builds on the [`Azure/avm-ptn-alz`](https://registry.terraform.io/modules/Azure/avm-ptn-alz/azurerm/latest) module and a custom ALZ library under [`lib/`](lib/).

This config depends on the separate [`../alz-management`](../alz-management) stack, which must be deployed first — it reads that stack's state via `terraform_remote_state` to pick up the org prefix, region, environment name, and cost center (see [locals.tf](locals.tf)).

## What this deploys

- **Management group hierarchy** — defined in [`lib/architecture_definitions/custom_alz.alz_architecture_definition.json`](lib/architecture_definitions/custom_alz.alz_architecture_definition.json):

  ```
  alz (root)
  ├─ platform
  │  ├─ management
  │  ├─ connectivity
  │  ├─ identity
  │  └─ security
  ├─ applications
  │  ├─ appa      (corp archetype)
  │  ├─ appb      (online archetype)
  │  └─ appc      (online archetype)
  ├─ sandbox
  └─ decommissioned
  ```

- **Custom policies**, assigned at the root `alz` management group via the `root_custom` archetype override ([`lib/archetype_definitions/root_custom.alz_archetype_override.json`](lib/archetype_definitions/root_custom.alz_archetype_override.json)):

  | Assignment | Purpose |
  |---|---|
  | `MAU-Allowed-Locations` | Restrict deployments to allowed Azure regions |
  | `MAU-CIS-Benchmark` | CIS Benchmark compliance initiative |
  | `MAU-Subnet-NSG-Audit` | Audit subnets that lack an associated NSG |
  | `MAU-PublicIP-DMZ-Only` | Only allow public IPs in designated DMZ subnets (custom policy definition) |
  | `MAU-Tag-Description`, `MAU-Tag-CostCenter`, `MAU-Tag-Environment`, `MAU-Tag-updateSchedule`, `MAU-Tag-Function`, `MAU-Tag-Application`, `MAU-Tag-deployedBy`, `MAU-Tag-client`, `MAU-Tag-deploymentMethod`, `MAU-Tag-gitRepository` | Append standard tags to resources |

- **Subscription placement** — `management`, `connectivity`, `identity`, and `security` subscriptions are moved into their matching management groups (see `subscription_placement` in [main.tf](main.tf)). `applications`/`appa`/`appb`/`appc` and `sandbox` have no subscriptions placed yet.

- **A resource group for private DNS zones** (`azurerm_resource_group.private_dns_zone`), created in the connectivity subscription. The module that would populate it with actual DNS zones is currently commented out (see Known Issues).

## Layout

```
alz/
├── main.tf                    # providers, remote state, RG, alz_architecture module
├── variables.tf                # subscription id/MG-name inputs
├── locals.tf                   # values pulled from alz-management remote state
├── terraform.tf                 # provider version constraints
├── backend.tf                   # azurerm remote state backend config
├── terraform.tfvars              # subscription IDs for this environment (not committed with real values — see below)
├── lib/                          # custom ALZ library, scanned via the alz provider's custom_url
│   ├── architecture_definitions/  # custom_alz.alz_architecture_definition.json — the MG hierarchy
│   ├── archetype_definitions/     # root_custom.alz_archetype_override.json — policies attached to root
│   ├── policy_definitions/        # custom policy definitions (e.g. publicip-dmz-only)
│   └── policy_assignments/        # policy assignments referenced by archetypes
└── temp/                          # staging area for definitions/assignments not yet wired into lib/ (see Known Issues)
```

## Providers

Four `azurerm` provider configs are declared:

- default (unaliased) — not currently used by any resource in this config
- `azurerm.connectivity`, `azurerm.identity`, `azurerm.security` — scoped to their respective subscription IDs via `var.*_subscription.id`

All four have `prevent_deletion_if_contains_resources = true`, and the `private_dns_zone` resource group additionally has `lifecycle { prevent_destroy = true }` — both guard against accidental deletion of foundational shared infrastructure.

The `alz` provider is configured with:
- `library_overwrite_enabled = true`
- `library_references`: the upstream `platform/alz` library (pinned ref, check the [releases page](https://github.com/Azure/Azure-Landing-Zones-Library/releases) for the current version) plus this repo's `lib/` folder as a `custom_url`
- `suppress_warning_policy_role_assignments = true`

## Variables

Set in [terraform.tfvars](terraform.tfvars) (not committed with real subscription IDs in this doc — see the file itself for actual values):

| Variable | Shape | Notes |
|---|---|---|
| `enable_telemetry` | `bool` | Azure Verified Modules telemetry toggle |
| `management_subscription` | `{ id, MG_name }` | Subscription ID + target MG name |
| `connectivity_subscription` | `{ id, MG_name }` | " |
| `identity_subscription` | `{ id, MG_name }` | " |
| `security_subscription` | `{ id, MG_name }` | " |

`MG_name` values must match the corresponding `id` field in `custom_alz.alz_architecture_definition.json` — this is what makes subscription placement land in the right management group.

## Deploying

Prerequisites: `../alz-management` must already be deployed (its state is read via remote state).

```bash
cd alz
terraform init
terraform plan
terraform apply
```

## Known issues / WIP

- **`temp/` is a staging folder, not part of the active library.** The `alz` provider's `custom_url` only scans `lib/`, so anything under `temp/` (currently: draft archetype definitions for `connectivity`/`corp`/`decommissioned`/`identity`/`landing_zones`/`management`/`online`/`platform`/`root`/`sandbox`, plus a draft `Tag-RG-Description` assignment and its `require-rg-tag` policy definition) has no effect until moved into `lib/`. The RG-tag-required policy is intentionally parked here — not yet implemented.
- **Commented-out `amba` library reference** (main.tf) and **commented-out `private_dns_zones` module** (main.tf) — both deferred, not yet enabled.
- **Provider version mismatch with `alz-management`**: this stack pins `azurerm ~> 5.0`; `alz-management` pins `azurerm ~> 4.35`. They're independent state files so this isn't a hard error, but confirm this is a deliberate staged upgrade rather than drift before assuming parity in provider behavior across the two stacks.
- **`azurerm.identity` and `azurerm.security` provider aliases are declared but not yet referenced** by any resource in this config — expected to be used once identity/security-specific resources are added.
- A `tfplan` file exists in this directory from local plan runs; it is `.gitignore`d (`*.tfplan`/`tfplan`) and should stay untracked. (The sibling `alz-management` stack has a similarly-purposed `deploy.out` file that — unlike this one — *is* tracked in git; that's flagged separately as a security cleanup item for that stack, not this one.)
