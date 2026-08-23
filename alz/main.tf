
# This allows us to get the tenant id
data "azapi_client_config" "current" {}

### Create ALZ architecture
module "alz_architecture" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.21.0" # https://registry.terraform.io/modules/Azure/avm-ptn-alz/azurerm/latest

  architecture_name  = "custom_alz"
  location           = local.azure_region_location
  parent_resource_id = data.azapi_client_config.current.tenant_id
  enable_telemetry   = local.avm_telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/

  subscription_placement = {
    management = {
      subscription_id       = var.management_subscription.id
      management_group_name = var.management_subscription.MG_name
    },
    connectivity = {
      subscription_id       = var.connectivity_subscription.id
      management_group_name = var.connectivity_subscription.MG_name
    },
    identity = {
      subscription_id       = var.identity_subscription.id
      management_group_name = var.identity_subscription.MG_name
    }
    security = {
      subscription_id       = var.security_subscription.id
      management_group_name = var.security_subscription.MG_name
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
