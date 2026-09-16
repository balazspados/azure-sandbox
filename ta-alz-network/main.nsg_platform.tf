
### NSG rules for ta-vnet-platform_nw-prd-ae-001
module "nsg_nw_001" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1" # https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup
  providers = {
    azurerm = azurerm.connectivity
  }
  diagnostic_settings = {
    law = {
      workspace_resource_id = local.platform_log_analytics_workspace_id
    }
  }
  location            = local.alz_config.azure_region_location
  name                = local.nsg_nw_001.nsg_name
  resource_group_name = azurerm_resource_group.rg_nw_001.name
  security_rules      = local.nsg_nw_001.rules
  enable_telemetry    = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags                = local.common_tags
}

### Azure Bastion NSG 
module "nsg_nw_004_bastion" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1" # https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup
  providers = {
    azurerm = azurerm.connectivity
  }
  diagnostic_settings = {
    law = {
      workspace_resource_id = local.platform_log_analytics_workspace_id
    }
  }
  location            = local.alz_config.azure_region_location
  name                = local.nsg_nw_004_bastion.nsg_name
  resource_group_name = azurerm_resource_group.rg_nw_004.name
  security_rules      = local.nsg_nw_004_bastion.rules
  enable_telemetry    = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags                = local.common_tags
}


module "nsg_nw_005" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1" # https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup
  providers = {
    azurerm = azurerm.connectivity
  }
  diagnostic_settings = {
    law = {
      workspace_resource_id = local.platform_log_analytics_workspace_id
    }
  }
  location            = local.alz_config.azure_region_location
  name                = local.nsg_nw_005.nsg_name
  resource_group_name = azurerm_resource_group.rg_nw_005.name
  security_rules      = local.nsg_nw_005.rules
  enable_telemetry    = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags                = local.common_tags
}