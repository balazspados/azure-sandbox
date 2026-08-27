provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}


resource "azurerm_resource_group" "rg_management" {
  location = var.azure_region.location
  name     = "${var.org_prefix}-rg-mgmt-${var.environment}-${var.azure_region.location_short}-${local.alz_resource_instance_number}"
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

module "alz_management" {
  source  = "Azure/avm-ptn-alz-management/azurerm"
  version = "0.9.0" # change this to your desired version, https://registry.terraform.io/modules/Azure/avm-ptn-alz-management/azurerm/latest

  location                                           = var.azure_region.location
  log_analytics_workspace_name                       = "${var.org_prefix}-law-mgmt-${var.environment}-${var.azure_region.location_short}-${local.alz_resource_instance_number}"
  log_analytics_workspace_internet_ingestion_enabled = false
  log_analytics_workspace_internet_query_enabled     = false
  resource_group_name                                = azurerm_resource_group.rg_management.name
  resource_group_creation_enabled                    = false

  automation_account_name                          = "${var.org_prefix}-aa-mgmt-${var.environment}-${var.azure_region.location_short}-${local.alz_resource_instance_number}" # not in use, mandatory parameter
  automation_account_public_network_access_enabled = false                                                                                                                   # prevent public access

  tags             = local.common_tags
  enable_telemetry = var.enable_telemetry # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
}
