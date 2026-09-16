
### Create LAW Security RG
resource "azurerm_resource_group" "rg_law_security" {
  provider = azurerm.security
  location = local.alz_config.azure_region_location
  name     = local.security_law_rg_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

### Set Resource lock on RG. All resources inherits it down in the resource group.
resource "azurerm_management_lock" "rg_law_security" {
  provider   = azurerm.security
  count      = local.alz_config.resource_lock_kind != null ? 1 : 0
  name       = "lock-${azurerm_resource_group.rg_law_security.name}"
  scope      = azurerm_resource_group.rg_law_security.id
  lock_level = local.alz_config.resource_lock_kind
}