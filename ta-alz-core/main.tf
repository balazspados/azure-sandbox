
### Create ALZ-management resources
resource "azurerm_resource_group" "rg_management" {
  provider = azurerm.management
  location = local.alz_config.azure_region_location
  name     = local.platform_base_parameters.rg_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

### Set Resource lock on RG. All resources inherits it down in the resource group.
resource "azurerm_management_lock" "rg_management" {
  provider   = azurerm.management
  count      = local.alz_config.resource_lock_kind != null ? 1 : 0
  name       = "lock-${azurerm_resource_group.rg_management.name}"
  scope      = azurerm_resource_group.rg_management.id
  lock_level = coalesce(local.alz_config.resource_lock_kind, "CanNotDelete")
}

module "alz_management" {
  source  = "Azure/avm-ptn-alz-management/azurerm"
  version = "0.9.0" # change this to your desired version, https://registry.terraform.io/modules/Azure/avm-ptn-alz-management/azurerm/latest
  providers = {
    azurerm = azurerm.management
    azapi   = azapi.management
  }

  location                                           = local.alz_config.azure_region_location
  log_analytics_workspace_name                       = local.platform_base_parameters.law_name
  log_analytics_workspace_internet_ingestion_enabled = local.platform_base_parameters.log_analytics_workspace_internet_ingestion_enabled
  log_analytics_workspace_internet_query_enabled     = local.platform_base_parameters.log_analytics_workspace_internet_query_enabled
  log_analytics_workspace_retention_in_days          = local.platform_base_parameters.log_analytics_workspace_retention_in_days
  resource_group_name                                = azurerm_resource_group.rg_management.name
  resource_group_creation_enabled                    = false                                                                                                                    # Default: true
  automation_account_name                            = "${local.alz_config.org_id}-aa-mgmt-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001" # not in use, mandatory parameter
  automation_account_public_network_access_enabled   = false                                                                                                                    # Default: true                                                                                                         # prevent public access
  tags                                               = local.common_tags
  enable_telemetry                                   = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/

  data_collection_rules = {
    change_tracking = {
      name = "${local.alz_config.org_id}-dcr-changetracking-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    }
    vm_insights = {
      name = "${local.alz_config.org_id}-dcr-vminsights-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    }
    defender_sql = {
      name = "${local.alz_config.org_id}-dcr-defendersql-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    }
  }

  user_assigned_managed_identities = {
    "ama" = {
      "name" = "${local.alz_config.org_id}-uami-ama-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    }
  }

}


### This allows us to get the tenant id
data "azapi_client_config" "current" {}

### Create ALZ architecture
module "alz_architecture" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.21.0" # https://registry.terraform.io/modules/Azure/avm-ptn-alz/azurerm/latest

  architecture_name  = "custom_alz"
  location           = local.alz_config.azure_region_location
  parent_resource_id = data.azapi_client_config.current.tenant_id
  enable_telemetry   = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/

  subscription_placement = {
    management = {
      subscription_id       = module.subscription_management.subscription_id
      management_group_name = local.alz_config.management_subscription_MG_name
    },
    connectivity = {
      subscription_id       = module.subscription_connectivity.subscription_id
      management_group_name = local.alz_config.connectivity_subscription_MG_name
    },
    identity = {
      subscription_id       = module.subscription_identity.subscription_id
      management_group_name = local.alz_config.identity_subscription_MG_name
    }
    security = {
      subscription_id       = module.subscription_security.subscription_id
      management_group_name = local.alz_config.security_subscription_MG_name
    }
  }


  # retries = {
  #   management_groups = {
  #     error_message_regex  = ["AuthorizationFailed", "NotFound", "ResourceNotFound"]
  #     interval_seconds     = 15
  #     max_interval_seconds = 180
  #   }
  #   policy_definitions = {
  #     error_message_regex  = ["NotFound", "ResourceNotFound"]
  #     interval_seconds     = 10
  #     max_interval_seconds = 120
  #   }
  #   policy_assignments = {
  #     error_message_regex  = ["NotFound", "ResourceNotFound", "PolicyDefinitionNotFound"]
  #     interval_seconds     = 10
  #     max_interval_seconds = 120
  #   }
  #   policy_role_assignments = {
  #     error_message_regex  = ["NotFound", "ResourceNotFound"]
  #     interval_seconds     = 10
  #     max_interval_seconds = 120
  #   }
  # }
}

