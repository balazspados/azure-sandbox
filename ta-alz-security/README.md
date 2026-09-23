# ta-alz-security

Terraform configuration that deploys the platform's security-subscription resources: a dedicated
Log Analytics workspace for security data (`main.law-security.tf`), fronted by an Azure Monitor
Private Link Scope (AMPLS) and a private endpoint into the connectivity subscription's
private-endpoints subnet, and Microsoft Defender for Cloud's `CloudPosture` plan on the security
subscription (`main.defender.tf`).

This stack depends on two other stacks having applied first: `remote_state.tf` reads
`ta-alz-core`'s `alz` workspace for `alz_config`, and `ta-alz-network`'s `alz-network` workspace
for the private-endpoints subnet and private DNS zone resource IDs.

## Prerequisites

- **`ta-alz-core` (workspace `alz`) already applied.** This stack's `locals.tf` reads
  `data.terraform_remote_state.alz.outputs.alz_config`.
- **`ta-alz-network` (workspace `alz-network`) already applied.** `locals.law-security.tf` reads
  `data.terraform_remote_state.alz_network.outputs.private_endpoints_subnet` and
  `.private_dns_zone_resource_ids` (5 zone keys — see Security Log Analytics Workspace below) to
  wire up the private endpoint.
- **HCP Terraform workspace `alz-security`** (org `padi-org`, `backend.tf`), with OIDC auth
  configured for the `azurerm`/`azapi` providers. `terraform.tf` declares 4 subscription-aliased
  provider pairs — `connectivity`, `management`, `security`, `identity` — but this stack currently
  only uses the `security` alias (for the resource group, LAW, AMPLS, and Defender) and the
  `connectivity` alias (for the private endpoint, since that's where the private-endpoints subnet
  lives); the `management` and `identity` aliases are declared but not yet used by any resource
  here.

## Configuration

`locals.tf`'s `common_tags` is applied to every resource this stack creates. Resource names
follow the repo's `<org_id>-<resource type>-<environment>-<region short>-<instance>` convention
(no `<application>` segment, same as the resource groups in `ta-alz-network`) — e.g. the security
resource group is `${org_id}-rg-sec-${environment}-${region_short}-001`
(`locals.tf`'s `security_law_rg_name`).

`main.tf`'s conditional `azurerm_management_lock.rg_law_security` (same pattern as `ta-alz-core`
and `ta-alz-network`) only exists when `local.alz_config.resource_lock_kind != null` — read from
`ta-alz-core`'s shared `alz_config` output, not set locally in this stack.

## Module versions

As of 2026-09-23, checked against the Terraform Registry:

| Module | Registry | Pinned version | Latest available (2026-09-23) |
|---|---|---|---|
| `Azure/avm-res-operationalinsights-workspace/azurerm` | Public | 0.5.1 | 0.5.1 |
| `ta-res-azure-defender/azurerm` | Private (`app.terraform.io/padi-org`) | 1.0.0 | 1.0.0 (only release published) |

## Security Log Analytics Workspace

`main.tf` first creates the security resource group directly —
`azurerm_resource_group.rg_law_security` (via the `azurerm.security` provider alias).
`module.law_security` (`Azure/avm-res-operationalinsights-workspace/azurerm`, pinned `0.5.1`, see
table above) then deploys the LAW itself into that resource group, also via `azurerm.security`:

- `${org_id}-log-seclaw-${environment}-${region_short}-001` — internet ingestion and query both
  explicitly disabled, retention set to 365 days (the module's defaults are enabled/enabled/30),
  same pattern as the platform LAW in `ta-alz-core`.
- `log_analytics_workspace_sku` is set in `locals.law-security.tf` (`"PerGB2018"`) but the
  parameter itself is commented out in the module call — the module's default is also
  `"PerGB2018"`, so this has no practical effect today, but the local wouldn't take effect if
  ever changed unless the module call is uncommented too.
- `log_analytics_workspace_identity = { type = "SystemAssigned" }` — the workspace gets its own
  managed identity.

**Private access via AMPLS**, all in `main.law-security.tf`:
- `azurerm_monitor_private_link_scope.ampls_law_security` (via `azurerm.security`) and
  `azurerm_monitor_private_link_scoped_service.law_security` link the security LAW into an Azure
  Monitor Private Link Scope.
- `azurerm_private_endpoint.pep_law_security` — deployed via the **`azurerm.connectivity`**
  provider alias (not `.security`), into `ta-alz-network`'s private-endpoints subnet and resource
  group (`platform_vnet_005`/`rg_nw_005`, read via remote state). Its `private_service_connection`
  targets the AMPLS scope (`subresource_names = ["azuremonitor"]`, not the LAW resource directly),
  and its `private_dns_zone_group` links 5 zones from `ta-alz-network`'s
  `private_dns_zone_resource_ids` output: `azure_monitor`, `azure_log_analytics`,
  `azure_log_analytics_data`, `azure_monitor_agent`, and `azure_storage_blob`.

## Microsoft Defender for Cloud

`main.defender.tf`'s `module.defender_security` calls
`app.terraform.io/padi-org/ta-res-azure-defender/azurerm` (pinned `1.0.0`, see table above) —
the same private-registry module used by `ta-alz-core`, `ta-alz-network`, and `ta-alz-iam` —
applied to the **security** subscription (via the `azurerm.security` provider alias). Only
`CloudPosture = { tier = "Free" }` is configured today. See `ta-alz-core`'s README for the
module's full `resource_type` key list and the rationale for using a private-registry module
instead of an AVM one.

## Deploying

Same VCS-driven flow as the other stacks: push to the tracked branch, review the plan in the
HCP Terraform workspace `alz-security` (org `padi-org`), approve the apply. Run this only after
both `ta-alz-core` and `ta-alz-network` have applied successfully, since both stacks' remote-state
outputs are consumed here.

## Outputs

`outputs.tf` exposes one output, for consumption by downstream workspaces:

- `security_log_analytics_workspace` — an object with the security LAW's resource ID (`id` =
  `module.law_security.resource_id`) and its resource group name (`rg_name` =
  `azurerm_resource_group.rg_law_security.name`), available to any stack that reads this
  workspace's (`alz-security`) remote state via `terraform_remote_state`. `ta-alz-identity`
  consumes `.id` for its own resources' `diagnostic_settings`.

## Verifying a deployment

There's no application to smoke-test here — verification is at the Azure control-plane level:

```zsh
az group show --name ta-rg-sec-prd-ae-001 --subscription <security_subscription_id>
az monitor log-analytics workspace show --resource-group ta-rg-sec-prd-ae-001 --workspace-name ta-log-seclaw-prd-ae-001
az monitor private-link-scope show --name pls-ta-log-seclaw-prd-ae-001 --resource-group ta-rg-sec-prd-ae-001
az network private-endpoint show --name pep-ta-log-seclaw-prd-ae-001 --resource-group <connectivity_private_endpoints_subnet_resource_group>
az security pricing show --name CloudPosture --subscription <security_subscription_id>
```

Confirm the resource group and LAW landed in the security subscription, the private endpoint
landed in the connectivity subscription's private-endpoints resource group, and — for the
Defender for Cloud check — that the output shows `"pricingTier": "Free"`.
