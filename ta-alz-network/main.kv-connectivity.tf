

data "azurerm_client_config" "connectivity" {
  provider = azurerm.connectivity
}


# resource "azurerm_private_endpoint" "pep_key_vault_connectivity" {
#   provider            = azurerm.connectivity
#   name                = local.key_vault_connectivity_parameters.private_endpoint_name
#   location            = local.alz_config.azure_region_location
#   resource_group_name = local.key_vault_connectivity_parameters.private_endpoints_subnet_resource_group_name
#   subnet_id           = local.key_vault_connectivity_parameters.private_endpoints_subnet_id
#   tags                = local.common_tags

#   private_service_connection {
#     name                           = "psc-${local.key_vault_connectivity_parameters.private_endpoint_name}"
#     private_connection_resource_id = module.key_vault_identity.resource_id
#     subresource_names              = ["vault"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "dnslinktovnet"
#     private_dns_zone_ids = [local.key_vault_connectivity_parameters.private_dns_zone_id]
#   }
# }

module "key_vault_connectivity" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.11.0" # https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault
  providers = {
    # azapi   = azapi.connectivity
    # azurerm = azurerm.connectivity
    azapi   = azapi.management
    azurerm = azurerm.management
  }
  location = local.alz_config.azure_region_location
  name     = local.key_vault_connectivity_parameters.kv_name
  # resource_group_name = local.rg_connectivity_001.name
  resource_group_name = azurerm_resource_group.rg_management.name
  tenant_id           = local.alz_config.azure_tenant_id

  sku_name                      = local.key_vault_connectivity_parameters.sku
  public_network_access_enabled = local.key_vault_connectivity_parameters.public_network_access_enabled
  purge_protection_enabled      = local.key_vault_connectivity_parameters.purge_protection_enabled
  soft_delete_retention_days    = local.key_vault_connectivity_parameters.soft_delete_retention_days
  enabled_for_disk_encryption   = local.key_vault_connectivity_parameters.enabled_for_disk_encryption
  network_acls = {
    ### Mandatory to be set if disk encryption is enabled
    bypass = "AzureServices"
    # default_action = "Deny"
    default_action = "Allow" # TEMPORARY: revert to "Deny" once vWAN/vHub peering exists (no static IP to allowlist for the TFC run)
  }
  role_assignments = {
    deployment_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.connectivity.object_id
    }  
  }
  # diagnostic_settings = {
  #   law = {
  #     workspace_resource_id = local.security_log_analytics_workspace_id
  #   }
  # }

  enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags

  secrets = {
    vpn_psk_otara = {
      name         = local.key_vault_connectivity_parameters.vpn_psk_secret_name
      # content_type = "text/plain"
    }
  }
  secrets_value_wo = {
    vpn_psk_otara = "Initial secret, do not use"
  }
  secrets_value_wo_version = {
    vpn_psk_otara = local.key_vault_connectivity_parameters.vpn_psk_secret_version
  }

}

