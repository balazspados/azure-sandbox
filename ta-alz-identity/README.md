# ta-alz-identity

Terraform root module that deploys the identity subscription's workload resources: a Key Vault
holding the customer-managed key for disk encryption, plus the Disk Encryption Set that uses it
(`main.kv-des-identity.tf`), a Recovery Services Vault with VM and SQL backup policies
(`main.rsv-identity.tf`), three Azure Update Manager maintenance configurations
(`main.update-manager.tf`), and Microsoft Defender for Cloud plans on the identity subscription
(`main.defender.tf`).

This stack depends on `ta-alz-core` (workspace `alz`), `ta-alz-network` (workspace
`alz-network`), and `ta-alz-security` (workspace `alz-security`) having applied first:
`remote_state.tf` reads `alz_config`/`resource_guard_deployment_id` from the first,
`rg_identity`/`private_endpoints_subnet`/`private_dns_zone_resource_ids` from the second, and
`security_log_analytics_workspace` (an `{ id, rg_name }` object) from the third — the last of
these feeds `local.security_log_analytics_workspace.id`, used by both the Key Vault's and the
Recovery Services Vault's `diagnostic_settings` below.

## Configuration

`locals.tf`'s `common_tags` is applied to every resource this stack creates. Resource names
follow the repo's `<org_id>-<resource type>-<application/service>-<environment>-<region
short>-<instance>` convention (e.g. `identity_recovery_vault_parameters.name` →
`${org_id}-rsv-backup-${environment}-${region_short}-001`).

## Module versions

As of 2026-09-23, checked against the Terraform Registry:

| Module | Registry | Pinned version | Latest available (2026-09-23) |
|---|---|---|---|
| `Azure/avm-res-keyvault-vault/azurerm` | Public | 0.11.0 | 0.11.0 |
| `Azure/avm-res-compute-diskencryptionset/azurerm` | Public | 0.1.1 | 0.1.1 |
| `Azure/avm-res-recoveryservices-vault/azurerm` | Public | 1.3.2 | 1.3.2 |
| `Azure/avm-res-maintenance-maintenanceconfiguration/azurerm` (used 3×) | Public | 0.1.0 | 0.1.0 |
| `ta-res-azure-defender/azurerm` | Private (`app.terraform.io/padi-org`) | 1.0.0 | 1.0.0 (only release published) |

## Identity Key Vault & Disk Encryption Set

`main.kv-des-identity.tf`'s `module.key_vault_identity` (pinned `0.11.0`, see table above)
deploys into `ta-alz-network`'s identity resource group, via the `azurerm.identity`/
`azapi.identity` provider aliases:

- `kv_name = "${org_id}kvidn${environment}${region_short}001"` — no hyphens, unlike the repo's
  usual convention (the same pattern the connectivity and security Key Vaults used before being
  switched to hyphenated names — see `ta-alz-network`'s README).
- `public_network_access_enabled = true` / `network_acls.default_action = "Allow"`, both marked
  `# TEMPORARY`. A private endpoint (`azurerm_private_endpoint.pep_key_vault_identity`, via
  `azurerm.connectivity`, into `ta-alz-network`'s private-endpoints subnet, linked to the
  `azure_key_vault` private DNS zone) already exists, so — same as the connectivity Key Vault
  before it was flipped — nothing but actually making the change blocks reverting this to
  `false`/`"Deny"`.
- `enabled_for_disk_encryption = true` required so the Disk Encryption Set below can retrieve/unwrap the key.
- `role_assignments.deployment_user_kv_admin` grants **Key Vault Administrator** to whichever
  identity runs this stack's own Terraform apply (`data.azurerm_client_config.identity`), same
  self-granted-admin pattern used by the other Key Vaults in this repo.
- `diagnostic_settings.law` sends to `local.security_log_analytics_workspace.id` — `ta-alz-security`'s
  LAW, read via remote state (see Prerequisites above).
- One key, `cmk_for_disk_encryption` — RSA 2048, `wrapKey`/`unwrapKey`, with an automatic
  rotation policy (rotates 365 days before expiry, expires after 2 years, notifies 30 days
  before expiry).

`module.des_identity` (`Azure/avm-res-compute-diskencryptionset/azurerm`, pinned `0.1.1`, see
table above) creates a Disk Encryption Set using that key (`encryption_type =
"EncryptionAtRestWithCustomerKey"`), with its own system-assigned managed identity and
`auto_key_rotation_enabled = true`. The module call doesn't set
`key_vault_role_assignment_enabled`, so it uses that variable's default (`true`) — the module
itself grants the DES's managed identity **Key Vault Crypto Service Encryption User** on
`key_vault_resource_id`, so no explicit `role_assignments`/access-policy entry is needed in this
file for the key access to work.

## Recovery Services Vault

`main.rsv-identity.tf`'s `module.identity_recovery_vault` (`Azure/avm-res-recoveryservices-vault/azurerm`,
pinned `1.3.2`, see table above) deploys into `ta-alz-network`'s identity resource group, via the
`azurerm.identity`/`azapi.identity` provider aliases:

- `public_network_access_enabled = false` from the start — a private endpoint
  (`azurerm_private_endpoint.pep_identity_recovery_vault`, via `azurerm.connectivity`,
  `subresource_names = ["AzureBackup"]`, linked to the `azure_backup` private DNS zone) is live
  alongside it, unlike the Key Vault above which is still in its temporary public-access state.
- `storage_mode_type = "ZoneRedundant"`, `cross_region_restore_enabled = false`, `soft_delete_enabled = "Enabled"`.
- **3 VM backup policies** (`locals.rsv-identity.tf`): `OS-tier1-Hourly` (4-hourly, 1-day instant
  restore, 30-day/12-month/7-year retention), `OS-tier2-Daily` (daily at 20:00, same longer-term
  retention), `OS-tier3-short-term` (daily at 20:00, 30-day retention only, no monthly/yearly).
- **3 SQL workload backup policies**: `SQL-tier-1` (full + log backups, 30-day/12-month/7-year
  retention on the full policy), `SQL-tier-2` (full only, same long-term retention),
  `SQL-tier-short-term` (full only, no long-term retention).
- `diagnostic_settings.law` sends to `local.security_log_analytics_workspace.id`, same as the
  Key Vault above.

## Update Manager (Maintenance Configurations)

`main.update-manager.tf` creates 3 `Azure/avm-res-maintenance-maintenanceconfiguration/azurerm`
maintenance configurations (pinned `0.1.0`, see table above), all deployed into
`local.rg_identity_001.name` via the `azurerm.identity`/`azapi.identity` provider aliases:

| Configuration | Cadence | Scope | Classifications |
|---|---|---|---|
| `osupdate_001` | Every 4 weeks, Thursday, 22:00 NZT, 3h55m | `InGuestPatch` (`User` mode) | Windows/Linux: Critical, Security |
| `osupdate_002` | Every 4 weeks, Thursday, 22:00 NZT, 3h55m | `InGuestPatch` (`User` mode) | Windows/Linux: Critical, Security |
| `defupdate_001` | Daily, 20:00 NZT, 2h | `InGuestPatch` (`User` mode) | Windows: Definition only; Linux: none |

## Microsoft Defender for Cloud

`main.defender.tf`'s `module.defender_identity` calls
`app.terraform.io/padi-org/ta-res-azure-defender/azurerm` (pinned `1.0.0`, see table above) —
the same private-registry module used by `ta-alz-core`, `ta-alz-network`, and `ta-alz-security`
— applied to the **identity** subscription:

- `CloudPosture = { tier = "Free" }` — foundational CSPM.
- `VirtualMachines = { tier = "Free" }` — inline comment: "Servers" plan disabled per the ALZ
  design.
- `KeyVaults = { tier = "Standard" }`.
- A block of other plans (`AppServices`, `SqlServers`, `SqlServerVirtualMachines`,
  `OpenSourceRelationalDatabases`, `CosmosDbs`, `StorageAccounts`, `Containers`, `Arm`, `Api`) is
  present but fully commented out, each with an inline note on why it's off (e.g. "disabled per
  table", storage malware scanning "never enabled") — this reads as a deliberate, previously
  reviewed design decision rather than an oversight.

## Deploying

Same VCS-driven flow as the other stacks: push to the tracked branch, review the plan in the
HCP Terraform workspace `alz-identity` (org `padi-org`), approve the apply. Run this only after
`ta-alz-core`, `ta-alz-network`, and `ta-alz-security` have all applied successfully.

## Outputs

`outputs.tf` currently defines no outputs. No downstream stack currently consumes anything from
this stack via `terraform_remote_state`.

## Verifying a deployment

There's no application to smoke-test here — verification is at the Azure control-plane level:

```zsh
az keyvault show --name ta-kv-idn-prd-ae-001 --subscription <identity_subscription_id>
az keyvault key show --vault-name ta-kv-idn-prd-ae-001 --name ta-key-diskencryption-prd-ae-001
az disk-encryption-set show --name ta-des-idn-prd-ae-001 --resource-group <identity_rg_name> --subscription <identity_subscription_id>
az backup vault show --name ta-rsv-backup-prd-ae-001 --resource-group <identity_rg_name> --subscription <identity_subscription_id>
az maintenance configuration show --name ta-mc-osupdate-prd-ae-001 --resource-group <resource_group> --subscription <identity_subscription_id>
az security pricing show --name CloudPosture --subscription <identity_subscription_id>
```

Confirm the Key Vault key and Disk Encryption Set both exist and that the DES's
`encryption_type` shows customer-managed key encryption is actually active; confirm the Recovery
Services Vault shows its backup policies and Resource Guard association; and for the Defender
for Cloud check, confirm the output shows `"pricingTier": "Free"`.
