# resource "random_id" "id" {
#   byte_length = 2
# }


resource "azurerm_resource_group" "management" {
  location = local.azure_region.name
  # name     = "rg-terraform-${var.azure_region.short_name}-${random_id.id.hex}"
  name = "rg-terraform-${local.azure_region.short_name}-${local.resource_postfix.id}"
  tags = local.common_tags
}

module "avm-ptn-alz-management" {
  source  = "Azure/avm-ptn-alz-management/azurerm"
  version = "0.9.0" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  automation_account_name         = "aa-terraform-${local.azure_region.short_name}-${local.resource_postfix.id}"
  location                        = local.azure_region.name
  log_analytics_workspace_name    = "law-terraform-${local.azure_region.short_name}-${local.resource_postfix.id}"
  resource_group_name             = azurerm_resource_group.management.name
  resource_group_creation_enabled = false

  tags = local.common_tags
}


# module "management" {
#   source = "../.."

#   automation_account_name      = "aa-terraform-nzn-${random_id.id.hex}"
#   location                     = "eastus"
#   resource_group_name          = "rg-terraform-nzn-${random_id.id.hex}"
#   log_analytics_workspace_name = "law-terraform-nzn-${random_id.id.hex}"
# }

# resource "azurerm_resource_group" "management" {
#   location = "newzealandnorth"
#   name     = "rg-terraform-${random_id.id.hex}"
# }

# resource "azurerm_user_assigned_identity" "management" {
#   location            = azurerm_resource_group.management.location
#   name                = "id-terraform-${random_id.id.hex}"
#   resource_group_name = azurerm_resource_group.management.name
# }

# module "management" {
#   source = "../../azure-lz-templates/terraform-azurerm-avm-ptn-alz-management/"

#   automation_account_name = "aa-terraform-azure"
#   location                = "newzealandnorth"
#   resource_group_name     = azurerm_resource_group.management.name
#   automation_account_identity = {
#     type         = "SystemAssigned, UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.management.id]
#   }
#   automation_account_local_authentication_enabled  = true
#   automation_account_public_network_access_enabled = true
#   automation_account_sku_name                      = "Basic"
# data_collection_rules = {
#   change_tracking = {
#     name     = "dcr-change-tracking-${random_id.id.hex}"
#     location = azurerm_resource_group.management.location
#     tags = {
#       testing = "123"
#     }
#   }
#   vm_insights = {
#     name = "dcr-vm-insights-${random_id.id.hex}"
#   }
#   defender_sql = {
#     name = "dcr-defender-sql-${random_id.id.hex}"
#   }
# }
# linked_automation_account_creation_enabled = true
# log_analytics_solution_plans = [
#   {
#     product   = "OMSGallery/AgentHealthAssessment"
#     publisher = "Microsoft"
#   },
#   {
#     product   = "OMSGallery/AntiMalware"
#     publisher = "Microsoft"
#   },
#   {
#     product   = "OMSGallery/ChangeTracking"
#     publisher = "Microsoft"
#   },
#   {
#     product   = "OMSGallery/ContainerInsights"
#     publisher = "Microsoft"
#   },
# ]
# log_analytics_workspace_allow_resource_only_permissions    = true
# log_analytics_workspace_cmk_for_query_forced               = true
# log_analytics_workspace_daily_quota_gb                     = 1
# log_analytics_workspace_internet_ingestion_enabled         = true
# log_analytics_workspace_internet_query_enabled             = true
# log_analytics_workspace_name                               = "law-terraform-azure"
# log_analytics_workspace_reservation_capacity_in_gb_per_day = 200
# log_analytics_workspace_retention_in_days                  = 50
# log_analytics_workspace_sku                                = "CapacityReservation"
# resource_group_creation_enabled                            = false
# #sentinel_onboarding                                        = {}
# tags = {
#   environment = "sandbox"
# }
# user_assigned_managed_identities = {
#   ama = {
#     name = "uami-ama-${random_id.id.hex}"
#   }
# }
# }
