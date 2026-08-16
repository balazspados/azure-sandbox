# Include the additional policies and override archetypes
provider "alz" {
  library_overwrite_enabled = true
  library_references = [
    { path = "platform/alz"
      ref  = "2026.04.2" # check registry for current ref https://github.com/Azure/Azure-Landing-Zones-Library/releases
    },
    # Not in use currently
    # {
    #   "path" : "platform/amba",
    #   "ref" : "2026.06.2" # https://github.com/Azure/Azure-Landing-Zones-Library/releases#release-platform/amba/
    # },
    {
      custom_url = "${path.root}/lib"
    }
  ]
  suppress_warning_policy_role_assignments = true
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

provider "azurerm" {
  alias = "connectivity"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = var.connectivity_subscription.id
}

provider "azurerm" {
  alias = "identity"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = var.identity_subscription.id
}

provider "azurerm" {
  alias = "security"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = var.security_subscription.id
}

#This fetches the output of alz-management TF config
data "terraform_remote_state" "alz-management" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-terraform-state-nzn"
    storage_account_name = "sttfstateplatformnzn001"
    container_name       = "terraformstate"
    key                  = "alz-management/terraform.tfstate" # the other config's state key
    use_azuread_auth     = true
  }
}

# This allows us to get the tenant id
data "azapi_client_config" "current" {}

### Create private DNS zone
resource "azurerm_resource_group" "private_dns_zone" {
  provider = azurerm.connectivity
  location = local.azure_region_location
  name     = local.private_dns_name_rg
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

# module "private_dns_zones" {
#   source  = "Azure/avm-ptn-network-private-link-private-dns-zones/azurerm"
#   version = "0.23.2"

#   location  = local.azure_region_location
#   parent_id = azurerm_resource_group.private_dns_zone.id
#   enable_telemetry   = var.enable_telemetry # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
# }

### Create ALZ architecture
module "alz_architecture" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.21.0" # https://registry.terraform.io/modules/Azure/avm-ptn-alz/azurerm/latest

  architecture_name  = "custom_alz"
  location           = local.azure_region_location
  parent_resource_id = data.azapi_client_config.current.tenant_id
  enable_telemetry   = var.enable_telemetry # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/

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
