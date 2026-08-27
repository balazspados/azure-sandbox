
# This allows us to get the tenant id
data "azapi_client_config" "current" {}

### Create ALZ architecture
module "alz_architecture" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.21.0" # https://registry.terraform.io/modules/Azure/avm-ptn-alz/azurerm/latest

  architecture_name  = "custom_alz"
  location           = local.alz_config.azure_region_location
  parent_resource_id = data.azapi_client_config.current.tenant_id
  enable_telemetry   = local.alz_config.telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/

  subscription_placement = {
    management = {
      subscription_id       = local.alz_config.management_subscription_id
      management_group_name = local.alz_config.management_subscription_MG_name
    },
    connectivity = {
      subscription_id       = local.alz_config.connectivity_subscription_id
      management_group_name = local.alz_config.connectivity_subscription_MG_name
    },
    identity = {
      subscription_id       = local.alz_config.identity_subscription_id
      management_group_name = local.alz_config.identity_subscription_MG_name
    }
    security = {
      subscription_id       = local.alz_config.security_subscription_id
      management_group_name = local.alz_config.security_subscription_MG_name
    }
  }


  retries = {
    management_groups = {
      error_message_regex  = ["AuthorizationFailed", "NotFound", "ResourceNotFound"]
      interval_seconds     = 15
      max_interval_seconds = 180
    }
    policy_definitions = {
      error_message_regex  = ["NotFound", "ResourceNotFound"]
      interval_seconds     = 10
      max_interval_seconds = 120
    }
    policy_assignments = {
      error_message_regex  = ["NotFound", "ResourceNotFound", "PolicyDefinitionNotFound"]
      interval_seconds     = 10
      max_interval_seconds = 120
    }
    policy_role_assignments = {
      error_message_regex  = ["NotFound", "ResourceNotFound"]
      interval_seconds     = 10
      max_interval_seconds = 120
    }
  }
}
