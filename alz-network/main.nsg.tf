
### Shared NSG rules for mau-vnet-platform_nw-prd-ae-001
module "nsg_nw_prd_ae_001" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1" # https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup
  providers = {
    azurerm = azurerm.connectivity
  }
  location            = local.alz_config.azure_region_location
  name                = "${local.alz_config.org_prefix}-nsg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  resource_group_name = azurerm_resource_group.rg_nw_001.name
  security_rules      = local.nsg_nw_prd_ae_001_rules
  enable_telemetry    = local.alz_config.telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags                = local.common_tags
}

module "nsg_nw_prd_ae_002" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1" # https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup
  providers = {
    azurerm = azurerm.connectivity
  }
  location            = local.alz_config.azure_region_location
  name                = "${local.alz_config.org_prefix}-nsg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-002"
  resource_group_name = azurerm_resource_group.rg_nw_001.name
  security_rules      = local.nsg_nw_prd_ae_002_rules
  enable_telemetry    = local.alz_config.telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags                = local.common_tags
}

module "nsg_nw_bastion" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1" # https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup
  providers = {
    azurerm = azurerm.connectivity
  }
  location            = local.alz_config.azure_region_location
  name                = "${local.alz_config.org_prefix}-nsg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-003"
  resource_group_name = azurerm_resource_group.rg_nw_001.name
  security_rules      = local.nsg_nw_bastion_rules
  enable_telemetry    = local.alz_config.telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags                = local.common_tags
}