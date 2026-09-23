

### Create Private Endpoint in endpoint subnet (lives in connectivity sub, same as LAW's PE)
resource "azurerm_private_endpoint" "pep_identity_recovery_vault" {
  provider            = azurerm.connectivity
  name                = local.identity_recovery_vault_parameters.private_endpoint_name
  location            = local.alz_config.azure_region_location
  resource_group_name = local.identity_recovery_vault_parameters.private_endpoints_subnet_resource_group_name
  subnet_id           = local.identity_recovery_vault_parameters.private_endpoints_subnet_id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-${local.identity_recovery_vault_parameters.private_endpoint_name}"
    private_connection_resource_id = module.identity_recovery_vault.resource_id
    subresource_names              = ["AzureBackup"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dnslinktovnet"
    private_dns_zone_ids = [local.identity_recovery_vault_parameters.private_dns_zone_id]
  }
}

### Create Recovery Services Vault
module "identity_recovery_vault" {
  source  = "Azure/avm-res-recoveryservices-vault/azurerm"
  version = "1.3.2" # https://github.com/Azure/terraform-azurerm-avm-res-recoveryservices-vault
  providers = {
    azurerm = azurerm.identity
    azapi   = azapi.identity
  }
  name                          = local.identity_recovery_vault_parameters.name
  resource_group_name           = local.rg_identity_001.name
  location                      = local.alz_config.azure_region_location
  sku                           = local.identity_recovery_vault_parameters.sku
  resource_guard_id             = local.identity_recovery_vault_parameters.resource_guard_deployment_id
  public_network_access_enabled = local.identity_recovery_vault_parameters.public_network_access_enabled
  storage_mode_type             = local.identity_recovery_vault_parameters.storage_mode_type
  cross_region_restore_enabled  = local.identity_recovery_vault_parameters.cross_region_restore_enabled
  soft_delete_enabled           = local.identity_recovery_vault_parameters.soft_delete_enabled
  vm_backup_policy              = local.identity_recovery_vault_parameters.vm_backup_policy
  workload_backup_policy        = local.identity_recovery_vault_parameters.workload_backup_policy
  diagnostic_settings = {
    law = {
      workspace_resource_id = local.security_log_analytics_workspace.id
    }
  }
  managed_identities = {
    system_assigned = true
  }
  enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags
}