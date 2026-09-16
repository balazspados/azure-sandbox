
### Create RG for platform network 001
resource "azurerm_resource_group" "rg_nw_001" {
  provider = azurerm.connectivity
  location = local.alz_config.azure_region_location
  name     = local.platform_rg_nw_001_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

### Set Resource lock on RG. All resources inherits it down in the resource group.
resource "azurerm_management_lock" "rg_nw_001" {
  provider   = azurerm.connectivity
  count      = local.alz_config.resource_lock_kind != null ? 1 : 0
  name       = "lock-${azurerm_resource_group.rg_nw_001.name}"
  scope      = azurerm_resource_group.rg_nw_001.id
  lock_level = local.alz_config.resource_lock_kind
}

### Create platform network 002 RG for Expressroute Circuits

resource "azurerm_resource_group" "rg_nw_002" {
  provider = azurerm.connectivity
  location = local.alz_config.azure_region_location
  name     = local.platform_rg_nw_002_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

### Set Resource lock on RG. All resources inherits it down in the resource group.
resource "azurerm_management_lock" "rg_nw_002" {
  provider   = azurerm.connectivity
  count      = local.alz_config.resource_lock_kind != null ? 1 : 0
  name       = "lock-${azurerm_resource_group.rg_nw_002.name}"
  scope      = azurerm_resource_group.rg_nw_002.id
  lock_level = local.alz_config.resource_lock_kind
}

### Create platform network 003 RG for VPN Sites & Connections
resource "azurerm_resource_group" "rg_nw_003" {
  provider = azurerm.connectivity
  location = local.alz_config.azure_region_location
  name     = local.platform_rg_nw_003_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

### Set Resource lock on RG. All resources inherits it down in the resource group.
resource "azurerm_management_lock" "rg_nw_003" {
  provider   = azurerm.connectivity
  count      = local.alz_config.resource_lock_kind != null ? 1 : 0
  name       = "lock-${azurerm_resource_group.rg_nw_003.name}"
  scope      = azurerm_resource_group.rg_nw_003.id
  lock_level = local.alz_config.resource_lock_kind
}

### Create platform network 004 RG for Azure Bastion
resource "azurerm_resource_group" "rg_nw_004" {
  provider = azurerm.connectivity
  location = local.alz_config.azure_region_location
  name     = local.platform_rg_nw_004_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

### Set Resource lock on RG. All resources inherits it down in the resource group.
resource "azurerm_management_lock" "rg_nw_004" {
  provider   = azurerm.connectivity
  count      = local.alz_config.resource_lock_kind != null ? 1 : 0
  name       = "lock-${azurerm_resource_group.rg_nw_004.name}"
  scope      = azurerm_resource_group.rg_nw_004.id
  lock_level = local.alz_config.resource_lock_kind
}

### Create platform network 005 RG for Azure Bastion
resource "azurerm_resource_group" "rg_nw_005" {
  provider = azurerm.connectivity
  location = local.alz_config.azure_region_location
  name     = local.platform_rg_nw_005_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

### Set Resource lock on RG. All resources inherits it down in the resource group.
resource "azurerm_management_lock" "rg_nw_005" {
  provider   = azurerm.connectivity
  count      = local.alz_config.resource_lock_kind != null ? 1 : 0
  name       = "lock-${azurerm_resource_group.rg_nw_005.name}"
  scope      = azurerm_resource_group.rg_nw_005.id
  lock_level = local.alz_config.resource_lock_kind
}

### Create platform network 006 RG for Private DNS Zone
resource "azurerm_resource_group" "rg_nw_006" {
  provider = azurerm.connectivity
  location = local.alz_config.azure_region_location
  name     = local.platform_rg_nw_006_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

### Set Resource lock on RG. All resources inherits it down in the resource group.
resource "azurerm_management_lock" "rg_nw_006" {
  provider   = azurerm.connectivity
  count      = local.alz_config.resource_lock_kind != null ? 1 : 0
  name       = "lock-${azurerm_resource_group.rg_nw_006.name}"
  scope      = azurerm_resource_group.rg_nw_006.id
  lock_level = local.alz_config.resource_lock_kind
}


### Create identity 001 RG for identity tooling
resource "azurerm_resource_group" "rg_identity_001" {
  provider = azurerm.identity
  location = local.alz_config.azure_region_location
  name     = local.identity_rg_001_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

### Set Resource lock on RG. All resources inherits it down in the resource group.
resource "azurerm_management_lock" "rg_identity_001" {
  provider   = azurerm.identity
  count      = local.alz_config.resource_lock_kind != null ? 1 : 0
  name       = "lock-${azurerm_resource_group.rg_identity_001.name}"
  scope      = azurerm_resource_group.rg_identity_001.id
  lock_level = local.alz_config.resource_lock_kind
}