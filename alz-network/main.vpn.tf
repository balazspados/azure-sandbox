### Create VPN gateway resources
resource "azurerm_resource_group" "rg_nw_vpngw" {
  provider = azurerm.connectivity
  location = local.azure_region_location
  name     = local.vpn_gateway_paramaters.rg_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

# resource "azurerm_vpn_gateway" "nw_vpngw" {
#   provider            = azurerm.connectivity
#   name                = local.vpn_gateway_paramaters.name
#   resource_group_name = azurerm_resource_group.rg_nw_vpngw.name
#   location            = local.azure_region_location
#   virtual_hub_id      = module.avm-ptn-alz-connectivity-virtual-wan.virtual_hub_resource_ids["primary"]
#   tags                = local.common_tags
# }