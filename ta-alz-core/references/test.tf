resource "azurerm_resource_group" "rg_test" {
  location = var.azure_region.location
  name     = "${var.org_id}-rg-test-${var.environment}-${var.azure_region.location_short}-${local.alz_resource_instance_number}"
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_management_lock" "rg_test" {
  count      = var.resource_lock.kind != null ? 1 : 0
  name       = coalesce(var.resource_lock.name, "lock-${azurerm_resource_group.rg_test.name}")
  scope      = azurerm_resource_group.rg_test.id
  lock_level = var.resource_lock.kind
}