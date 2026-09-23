

data "azurerm_client_config" "identity" {
  provider = azurerm.identity
}


resource "azurerm_private_endpoint" "pep_key_vault_identity" {
  provider            = azurerm.connectivity
  name                = local.key_vault_identity_parameters.private_endpoint_name
  location            = local.alz_config.azure_region_location
  resource_group_name = local.key_vault_identity_parameters.private_endpoints_subnet_resource_group_name
  subnet_id           = local.key_vault_identity_parameters.private_endpoints_subnet_id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-${local.key_vault_identity_parameters.private_endpoint_name}"
    private_connection_resource_id = module.key_vault_identity.resource_id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dnslinktovnet"
    private_dns_zone_ids = [local.key_vault_identity_parameters.private_dns_zone_id]
  }
}


module "key_vault_identity" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.11.0" # https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault
  providers = {
    azapi   = azapi.identity
    azurerm = azurerm.identity
  }
  location            = local.alz_config.azure_region_location
  name                = local.key_vault_identity_parameters.kv_name
  resource_group_name = local.rg_identity_001.name
  tenant_id           = local.alz_config.azure_tenant_id

  sku_name                      = local.key_vault_identity_parameters.sku
  public_network_access_enabled = local.key_vault_identity_parameters.public_network_access_enabled
  purge_protection_enabled      = local.key_vault_identity_parameters.purge_protection_enabled
  soft_delete_retention_days    = local.key_vault_identity_parameters.soft_delete_retention_days
  enabled_for_disk_encryption   = local.key_vault_identity_parameters.enabled_for_disk_encryption
  network_acls = {
    ### Mandatory to be set if disk encryption is enabled
    bypass = "AzureServices"
    # default_action = "Deny"
    default_action = "Allow" # TEMPORARY: revert to "Deny" once vWAN/vHub peering exists (no static IP to allowlist for the TFC run)
  }
  role_assignments = {
    deployment_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.identity.object_id
    }
  }
  diagnostic_settings = {
    law = {
      workspace_resource_id = local.security_log_analytics_workspace_id
    }
  }

  enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags

  keys = {
    cmk_for_disk_encryption = {
      key_opts = ["unwrapKey", "wrapKey"]
      key_type = "RSA"
      name     = local.key_vault_identity_parameters.cmk_disk_encryption_key_name
      key_size = 2048

      rotation_policy = {
        automatic = {
          time_before_expiry = "P365D"
        }
        expire_after         = "P2Y"
        notify_before_expiry = "P30D"
      }
    }

  }

}

module "des_identity" {
  source  = "Azure/avm-res-compute-diskencryptionset/azurerm"
  version = "0.1.1" # https://github.com/Azure/terraform-azurerm-avm-res-compute-diskencryptionset
  providers = {
    azurerm = azurerm.identity
    azapi   = azapi.identity
  }
  key_vault_key_id      = module.key_vault_identity.keys.cmk_for_disk_encryption.versionless_id
  key_vault_resource_id = module.key_vault_identity.resource_id
  location              = local.alz_config.azure_region_location
  name                  = local.des_identity_parameters.des_name
  resource_group_name   = local.rg_identity_001.name
  encryption_type       = "EncryptionAtRestWithCustomerKey"

  enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags

  auto_key_rotation_enabled = true
  managed_identities = {
    system_assigned = true
  }

}
