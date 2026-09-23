# ta-alz-core

Terraform root module that deploys the Azure Landing Zone **platform core**: the management-group
hierarchy and policy (`avm-ptn-alz`), the Management landing zone's own resources — Log Analytics
workspace, Automation Account, Data Collection Rules, user-assigned managed identity
(`avm-ptn-alz-management`) — subscription vending/placement for the management, connectivity,
identity, and security subscriptions, the platform's Resource Guard deployment (MUA protection
for Recovery Services Vaults), and Microsoft Defender for Cloud's `CloudPosture` plan on the
management subscription.

This is the first stack to apply in this environment. `ta-alz-network`, `ta-alz-iam`, `ta-alz-identity` and
`ta-alz-security` all read this stack's outputs via `terraform_remote_state` and depend on
it having applied successfully first.

## Prerequisites

- **GitHub repository, version-controlled.** This Terraform configuration must live in a GitHub
  repository under version control, connected to HCP Terraform (via its GitHub App/OAuth
  integration) — every workspace below is VCS-driven (see Deploying), meaning it plans/applies from
  commits pushed to a tracked branch rather than from local `terraform apply`. The repository needs
  to exist and be reachable by HCP Terraform before any of the 5 workspaces can be created and
  connected to it.
- **Tenant bootstrap.** Before this stack can be applied to production, the tenant-level OIDC
  bootstrap must be completed as **5 separate** Entra ID app registrations/service principals, one
  per HCP Terraform workspace/stack (one for `ta-alz-core`'s `alz` workspace, and one each for
  `ta-alz-network`, `ta-alz-iam`, `ta-alz-identity`, `ta-alz-security`), each with its own OIDC
  federated credentials trusting HCP Terraform and responsible only for its own workspace/stack —
  not one shared SPN trusted by every workspace. This is a one-time, human-run, out-of-band step,
  not something any of these Terraform stacks manages.
  **Note:** `alz-bootstrap/root-binding/bootstrap-oidc.md` currently documents a different,
  single-shared-SPN model (one app registration + role assignment, trusted by all workspaces via
  multiple federated credentials) — that doc/script needs to be revised (or a new one written)
  before it can be used to produce the 5-SPN-per-stack setup production requires.
- **5 HCP Terraform workspaces**, one per stack (`alz`, `alz-network`, `alz-iam`, `alz-identity`,
  `alz-security`), each VCS-connected, execution mode Remote, and each with OIDC auth wired to its
  own SPN from the bootstrap above. `ta-alz-core`'s `alz` workspace additionally needs its OIDC auth
  configured for all four subscription-aliased providers it uses (`management`, `connectivity`,
  `identity`, `security` — see `terraform.tf`); because this stack configures multiple
  subscription-scoped provider aliases in one workspace (not just the default provider), that auth
  uses the per-alias/tagged `TFC_AZURE_*` variable pattern described in
  `alz-bootstrap/root-binding/bootstrap-oidc.md` ("If you later add per-alias provider
  configurations...").
- **Greenfield tenant — no pre-existing subscriptions.** This is a greenfield deployment: the
  Azure tenant starts empty, with none of the four platform subscriptions
  (management/connectivity/identity/security) existing beforehand. All four must be created fresh
  by `main.subscriptions.tf`'s subscription vending module (`subscription_alias_enabled = true` on
  every call).  A valid Enterprise Agreement/MCA billing scope (`subscription_billing_scope`) is required
  for each of the four.
- **Custom ALZ library overrides — standard ALZ policies are intentionally removed.**
  Recorded decision tracked in the project's design decision register, which also notes that a **workshop with the customer is recommended** to
  assess which of the removed stock ALZ policies should actually be reinstated (e.g. security
  guardrails, diagnostics settings, encryption enforcement) before production go-live. 

## Configuration

Core settings live in `locals.tf` under `locals.alz_config` — organization ID, environment,
region, the four subscription IDs/management-group names, tenant ID, and `resource_lock_kind`
(currently `null`; no lock is applied to the management resource group in this environment by
design). Resource names follow the convention `<org_id>-<resource type>-<application/service>-
<environment>-<region short>-<instance>` (e.g. `ta-rg-mgmt-prd-ae-001`); see `locals.tf` and
`locals.resource-guard-deployment.tf` for the concrete names this stack creates.

`common_tags` (`locals.tf`) is applied to every resource this stack creates or tags. Note that
`costCenter` is currently a placeholder (`"XXX"`) pending the real value, and `gitRepository`,
`deployedBy`, and `updateSchedule` are currently empty strings — the custom `TA-Require-RG-Tag`
policy only checks tag *existence*, so these placeholders won't block deployment, but should be
filled in with real values when available.

## Module versions

As of 2026-09-22, every AVM module this stack pins is on the latest version published to the
Terraform Registry:

| Module | Registry | Pinned version | Latest available (2026-09-23) |
|---|---|---|---|
| `Azure/avm-ptn-alz-management/azurerm` | Public (`registry.terraform.io`) | 0.9.0 | 0.9.0 |
| `Azure/avm-ptn-alz/azurerm` | Public (`registry.terraform.io`) | 0.21.0 | 0.21.0 |
| `Azure/avm-res-dataprotection-resourceguard/azurerm` | Public (`registry.terraform.io`) | 0.1.0 | 0.1.0 (only release published) |
| `Azure/avm-ptn-alz-sub-vending/azure` (used 4×) | Public (`registry.terraform.io`) | 0.3.2 | 0.3.2 |
| `ta-res-azure-defender/azurerm` | Private (`app.terraform.io/padi-org`) | 1.0.0 | 1.0.0 (only release published) |

## Management Landing Zone (`alz_management`)

`main.tf` first creates the management resource group directly —
`azurerm_resource_group.rg_management` (name `local.platform_base_parameters.rg_name`, e.g.
`ta-rg-mgmt-prd-ae-001`, via the `azurerm.management` provider alias) plus a conditional
`azurerm_management_lock.rg_management` that only exists when `local.alz_config.resource_lock_kind
!= null` (currently `null`, so no lock is applied today — see Configuration above). This same
resource group is reused by the Resource Guard Deployment below.

`module.alz_management` (`Azure/avm-ptn-alz-management/azurerm`, pinned `0.9.0`, see table above)
then deploys the Management landing zone's own resources **into** that resource group
(`resource_group_creation_enabled = false`, since the RG is created separately above rather than
by the module) via the `azurerm.management`/`azapi.management` provider aliases:

- **Log Analytics Workspace** (`platform_base_parameters.law_name`, e.g. `ta-log-mgmtlaw-prd-ae-001`)
  — internet ingestion and query both explicitly disabled, retention set to 365 days (the module's
  defaults are enabled/enabled/30). Its resource ID is re-exported downstream via the
  `platform_log_analytics_workspace_id` output (see Outputs below).


## Subscription Vending

`main.subscriptions.tf` calls `Azure/avm-ptn-alz-sub-vending/azure` (pinned `0.3.2`, see table
above) once per platform subscription — `subscription_management`, `subscription_connectivity`,
`subscription_security`, `subscription_identity` — with display names from
`locals.subscriptions.tf`'s `locals.alz_subscriptions_parameters`.

**Target design: all four subscriptions are created by this module.** Every call should use
`subscription_alias_enabled = true` (calling the Subscription Alias API to create a brand-new
subscription from `subscription_alias_name`/`subscription_workload`/`subscription_billing_scope`)
— the same pattern `subscription_identity` already uses. None of the four should be adopted via
`subscription_update_existing`/a hardcoded `subscription_id`; management-group placement for all
four is handled separately either way, by `module.alz_architecture`'s `subscription_placement`.

## ALZ Architecture (`alz_architecture`)

`module.alz_architecture` (`Azure/avm-ptn-alz/azurerm`, pinned `0.21.0`, see table above) deploys
the platform's management-group hierarchy and Azure Policy overlay, from this repo's custom ALZ
library under `lib/`, rather than the module's stock `alz` architecture:

- `architecture_name = "custom_alz"` points at
  `lib/architecture_definitions/custom_alz.alz_architecture_definition.json`, which defines 12
  management groups rooted at `root` (not the module default's `alz` root id): `platform` and
  `applications` directly under `root`; `management`, `connectivity`, `identity`, and `security`
  under `platform`; `appa`, `appb`, `appc` under `applications`; and `sandbox` /
  `decommissioned` directly under `root`.
- Each management group's `archetypes` entry (e.g. `root_custom`, `platform_custom`,
  `security_custom`) points at a matching override file in
  `lib/archetype_definitions/*.alz_archetype_override.json` — these are the "custom ALZ library
  overrides" referenced under Prerequisites above, where standard ALZ policies were intentionally
  removed from the archetypes. The policy assignments actually wired in live in
  `lib/policy_assignments/` — mostly tag-enforcement policies (`tag-RG-*`, `tag-*`, including
  `TA-Require-RG-Tag`, see Configuration above) plus a handful of guardrails
  (`Allowed-Locations`, `CIS-Benchmark`, `Subnet-NSG-Audit`, `audit-backup-vm`,
  `publicip-dmz-only`).
- `parent_resource_id = data.azapi_client_config.current.tenant_id` — deploys directly under the
  tenant root, using the calling identity's own tenant ID rather than a hardcoded one.
- `subscription_placement` maps each of the four subscriptions vended by
  `module.subscription_management`/`connectivity`/`identity`/`security` (see Subscription
  Vending above) into its corresponding management group
  (`local.alz_config.<x>_subscription_MG_name`) — so this module can only run once those four
  subscription IDs exist.
- The `retries` block (error-message-regex retry tuning for management groups/policy
  definitions/assignments/role assignments) is present in `main.tf` but fully commented out —
  not currently in use.

The resulting management-group resource IDs are exposed via the `management_group_resource_ids`
output (see Outputs below). Note its description in `outputs.tf` gives `"alz"` as an example
key — that's stale for this custom architecture; the actual top-level key is `root`, not `alz`.

## Resource Guard Deployment

`main.resource-guard-deployment.tf` calls the AVM module
`Azure/avm-res-dataprotection-resourceguard/azurerm` (pinned `0.1.0`, see table above) to create a
Resource Guard Deployment in the management resource group (`azurerm_resource_group.rg_management`,
from `main.tf`), using the `azurerm.management`/`azapi.management` provider aliases. Resource
Guard enables Multi-User Authorization (MUA) protection on Recovery Services Vaults elsewhere in
the landing zone — critical vault operations (e.g. disabling soft delete, stopping backups) then
require approval from a second user.

Notes on the configuration (`locals.resource-guard-deployment.tf`):
- `rgd_name` is `"${org_id}rgdbackup${environment}${region_short}001"` — this deliberately
  **doesn't** follow the stack's usual `<org_id>-<resource type>-...` naming convention, because
  the resource guard name must be 5–50 characters of lowercase letters and numbers only (no
  hyphens allowed).
- `vault_critical_operation_exclusion_list = []` is set explicitly (not left `null`/omitted) —
  per the inline comment in `main.resource-guard-deployment.tf`, omitting it causes Terraform to
  keep detecting drift on every plan.

The deployment's resource ID is exposed via the `resource_guard_deployment_id` output (see
Outputs below), which downstream stacks use to attach MUA protection to their own Recovery
Services Vaults.

## Microsoft Defender for Cloud

`main.defender.tf` calls `app.terraform.io/padi-org/ta-res-azure-defender/azurerm` (pinned
`1.0.0`, see table above), a small module hosted on our private Terraform Cloud registry (source
lives in the `azure-tf-modules/ta-res-azure-defender` repo), which wraps
`azurerm_security_center_subscription_pricing` directly (one resource per entry in a `plans` map,
each with a `tier` — `Free`/`Standard` — and an optional `subplan`). It's a thin wrapper rather
than an AVM module because there isn't a published AVM module for subscription-level Defender
pricing plans; this same module is also used by `ta-alz-security` and `ta-alz-identity`, each
configuring their own subscription's plans.

Currently configured here: only `CloudPosture = { tier = "Free" }`, applied to the **management**
subscription (via the `azurerm.management` provider alias). 

To enable additional plans, add entries to the `plans` map in `main.defender.tf`. Valid
`resource_type` keys (per the inline comment in `ta-res-azure-defender/main.tf`): `AI`, `Api`,
`AppServices`, `ContainerRegistry`, `KeyVaults`, `KubernetesService`, `SqlServers`,
`SqlServerVirtualMachines`, `StorageAccounts`, `VirtualMachines`, `Arm`, `Dns`,
`OpenSourceRelationalDatabases`, `Containers`, `CosmosDbs`, and `CloudPosture`.

## Deploying

This workspace is VCS-driven, so a normal deploy is:

1. Push/merge the change to the branch this HCP Terraform workspace tracks.
2. HCP Terraform automatically queues a **plan**. Review it in the workspace UI — check that
   resources are targeting the expected subscriptions (via the `management`/`connectivity`/
   `identity`/`security` provider aliases).
3. Approve the **apply** in the HCP Terraform UI (or via the API, per your workspace's approval
   settings).
4. On success, this stack's outputs (see below) become available to downstream workspaces via
   `terraform_remote_state`.

For a local speculative plan instead (e.g. to sanity-check a change before pushing), use
`terraform login` against HCP Terraform and run `terraform plan` from this directory — CLI-driven
runs still execute remotely against the `alz` workspace because of the `cloud` block in
`backend.tf`; this doesn't bypass VCS-triggered applies.

## Outputs

`outputs.tf` exposes, for consumption by downstream workspaces:

- `alz_config` — shared platform config (org ID, region, environment, all four subscription IDs
  and management-group names, tenant ID, telemetry/lock settings).
- `platform_log_analytics_workspace_id` — the platform LAW resource ID.
- `management_group_resource_ids` — map of management-group key (`alz`, `platform`,
  `connectivity`, `identity`, etc.) to its resource ID.
- `resource_guard_deployment_id` — the Resource Guard Deployment's resource ID, used to enable
  Multi-User Authorization on Recovery Services Vaults. Note the inline comment in `outputs.tf`
  documenting a known casing bug in the upstream `avm-res-dataprotection-resourceguard` module
  (0.1.0) that this output works around with `replace(...)`.
- `rg_management` — the management resource group's ID and name.

## Verifying a deployment

There's no application to smoke-test here — verification is at the Azure control-plane level:

```zsh
az group show --name ta-rg-mgmt-prd-ae-001 --subscription <management_subscription_id>
az account management-group show --name management
az monitor log-analytics workspace show --resource-group ta-rg-mgmt-prd-ae-001 --workspace-name ta-log-mgmtlaw-prd-ae-001
az security pricing show --name CloudPosture --subscription <management_subscription_id>
```

Confirm the resources landed in the subscriptions you expect before relying on downstream stacks
that consume this stack's outputs. For the Defender for Cloud check, confirm the output shows
`"pricingTier": "Free"`.
