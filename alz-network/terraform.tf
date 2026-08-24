terraform {
  required_version = "~> 1.15.8"

  required_providers {
    alz = {
      source  = "azure/alz"
      version = "~> 0.21"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.12"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.80"
    }
  }
}

provider "azurerm" {
  # resource_provider_registrations = "none"
  alias = "connectivity"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = local.connectivity_subscription_id
}

provider "azurerm" {
  # resource_provider_registrations = "none"
  alias = "management"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = local.management_subscription_id
}
