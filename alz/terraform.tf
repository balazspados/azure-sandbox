terraform {
  required_version = "~> 1.15.8"

  required_providers {
    alz = {
      source  = "azure/alz"
      version = "~> 0.22"     # https://github.com/Azure/terraform-provider-alz
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.12"    # https://github.com/Azure/terraform-provider-azapi
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.2"    # https://github.com/hashicorp/terraform-provider-azurerm
    }
  }
}

# Include the additional policies and override archetypes
provider "alz" {
  library_overwrite_enabled = true
  library_references = [
    { path = "platform/alz"
      ref  = "2026.08.0" # check registry for current ref https://github.com/Azure/Azure-Landing-Zones-Library/releases
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