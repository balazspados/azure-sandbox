
module "nsg_nw_vnet_idn_001" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1" # https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup
  providers = {
    azurerm = azurerm.identity
  }
  diagnostic_settings = {
    law = {
      workspace_resource_id = local.platform_log_analytics_workspace_id
    }
  }
  location            = local.alz_config.azure_region_location
  name                = local.nsg_nw_vnet_idn_001.nsg_name
  resource_group_name = azurerm_resource_group.rg_identity_001.name
  security_rules      = local.nsg_nw_vnet_idn_001.rules
  enable_telemetry    = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags                = local.common_tags
}
