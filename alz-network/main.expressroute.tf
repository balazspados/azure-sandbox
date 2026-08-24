### Create Expressroute resources
resource "azurerm_resource_group" "rg_nw_expressroute" {
  provider = azurerm.connectivity
  location = local.azure_region_location
  name     = local.expressroute_paramaters.rg_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}
