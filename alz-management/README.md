# alz-management

Terraform root module that deploys the ALZ management resources for MAU: a dedicated resource group and a Log Analytics Workspace (via [`Azure/avm-ptn-alz-management`](https://registry.terraform.io/modules/Azure/avm-ptn-alz-management/azurerm/latest)), in the `management` subscription.

This stack is foundational — the [`../alz`](../alz) stack reads its outputs via `terraform_remote_state` to derive the org prefix, region, environment, and cost center used across the rest of the landing zone. **Deploy this stack first.**

## What this deploys

- **`azurerm_resource_group.management`** — the management resource group, named `{org_prefix}-rg-mgmt-{environment}-{location_short}-{instance}`.
- **`avm-ptn-alz-management` module**, into that resource group:
  - Log Analytics Workspace, named `{org_prefix}-law-mgmt-{environment}-{location_short}-{instance}`
  - Azure Automation Account (`automation_account_name` set but currently unused/inactive — see Known Issues)
  - The module also optionally supports Data Collection Rules and a User Assigned Managed Identity, neither of which is configured here.

Both `prevent_deletion_if_contains_resources` (provider-level) and `lifecycle { prevent_destroy = true }` (resource-level) guard the management resource group against accidental deletion, since it's a dependency of the `alz` stack.

## Layout

```
alz-management/
├── main.tf           # provider, resource group, avm-ptn-alz-management module
├── variables.tf       # org_prefix, environment, azure_region, platform_costcenter
├── locals.tf           # common_tags, instance number
├── outputs.tf           # values consumed by ../alz via terraform_remote_state
├── terraform.tf          # provider version constraints
├── backend.tf             # azurerm remote state backend config
└── terraform.tfvars        # actual values for this environment (see below)
```

## Variables

Set in [terraform.tfvars](terraform.tfvars) (placeholders shown here — see the file itself for actual values):

| Variable | Type | Notes |
|---|---|---|
| `org_prefix` | `string` | 1–5 characters, validated. Used as the naming prefix for every resource across both stacks. |
| `environment` | `string` | e.g. `prd` |
| `azure_region` | `{ location, location_short }` | e.g. `{ location = "<region>", location_short = "<short-code>" }` |
| `platform_costcenter` | `string` | Tag value applied via `local.common_tags` |

## Outputs

Consumed by `../alz` via `data.terraform_remote_state.alz-management`:

| Output | Value |
|---|---|
| `resource_group_management_terraform` | Name of the management resource group |
| `org_prefix`, `environment`, `azure_region_location`, `azure_region_location_short`, `platform_costcenter` | Passed through from variables, used to build consistent naming/tags downstream |

## Naming convention

All resource names follow: `{org_prefix}-{service}-{environment}-{location_short}-{instance}` (e.g. `mau-rg-mgmt-prd-ae-001`), single-hyphen-joined, no segment omitted. Apply this convention to any new resource added to either stack.

## Deploying

```bash
cd alz-management
terraform init
terraform plan
terraform apply
```

Deploy this stack, then `cd ../alz` and follow [its README](../alz/README.md).

## Known issues / WIP

- **`automation_account_name` is set but the automation account isn't actually in use** (see the inline comment on that argument in `main.tf`) — it's a mandatory module parameter, so a name is supplied even though nothing consumes it yet.
- **`azurerm` provider version differs from the `alz` stack**: this stack pins `~> 4.35` (matching the `avm-ptn-alz-management` module's own requirement), while `alz` pins `~> 5.0`. They're independent state files, so this isn't a hard error — but it means the two stacks run different major provider versions against the same tenant. Worth confirming this is a deliberate staged upgrade rather than drift.
- **`deploy.out` is tracked in git and contains a binary Terraform plan.** It was committed under a filename that bypasses the `.gitignore` rules for `*.tfplan`/`tfplan` (those only match the plan-file extension/name this repo's `.gitignore` anticipated, not `.out`). Terraform plan files can contain sensitive attribute values in plaintext internally. This should be untracked (`git rm --cached alz-management/deploy.out`), added to `.gitignore`, and — since it's already pushed to the `origin` remote — any sensitive values it contains should be treated as exposed and rotated if applicable.
- The commented-out outputs in `outputs.tf` (automation account, data collection rules, log analytics workspace, managed identity, resource group resource IDs) reflect module capabilities not yet wired up — uncomment as those features get enabled.
