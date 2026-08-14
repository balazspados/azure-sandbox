provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


resource "azurerm_resource_group" "management" {
  location = var.azure_region.location
  name     = "${var.org_prefix}-rg-ALZ-${var.environment}-${var.azure_region.location_short}-${local.alz_resource_instace_number}"
  tags     = local.common_tags
}

module "avm-ptn-alz-management" {
  source  = "Azure/avm-ptn-alz-management/azurerm"
  version = "0.9.0" # change this to your desired version, https://registry.terraform.io/modules/Azure/avm-ptn-alz-management/azurerm/latest

  location                        = var.azure_region.location
  log_analytics_workspace_name    = "${var.org_prefix}-law-ALZ-${var.environment}-${var.azure_region.location_short}--${local.alz_resource_instace_number}"
  resource_group_name             = azurerm_resource_group.management.name
  resource_group_creation_enabled = false

  automation_account_name = "${var.org_prefix}-aa-ALZ-${var.azure_region.location_short}--${local.alz_resource_instace_number}" # not in use, mandatory parameter


  tags = local.common_tags
}

