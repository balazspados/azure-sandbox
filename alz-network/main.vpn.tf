### Create VPN gateway resources
resource "azurerm_resource_group" "rg_platform_vpngw" {
  provider = azurerm.connectivity
  location = local.alz_config.azure_region_location
  name     = local.vpn_gateway_paramaters.rg_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_vpn_gateway" "platform_vpngw" {
  provider            = azurerm.connectivity
  name                = local.vpn_gateway_paramaters.name
  resource_group_name = azurerm_resource_group.rg_platform_vpngw.name
  location            = local.alz_config.azure_region_location
  virtual_hub_id      = module.virtual_wan_hub.virtual_hub_resource_ids["primary"]
  tags                = local.common_tags
}

# module "platform_vpn" {
#   source  = "Azure/avm-res-network-connection/azurerm"
#   version = "0.2.0"
#   providers = {
#     azurerm = azurerm.connectivity
#   }
#   name                = local.vpn_gateway_paramaters.name
#   location            = local.azure_region_location
#   resource_group_name = azurerm_resource_group.rg_nw_vpngw.name
#   type                = "Vpn"
#   virtual_network_gateway_resource_id = 
#   enable_telemetry = local.avm_telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
#   tags             = local.common_tags
# }
