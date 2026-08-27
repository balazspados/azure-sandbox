terraform {
  required_version = ">= 1.15.8, <2.0.0"

  required_providers {
    alz = {
      source  = "azure/alz"
      version = "~> 0.22"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.12"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81"
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
  subscription_id = local.alz_config.connectivity_subscription_id
}

provider "azurerm" {
  alias = "management"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = local.alz_config.management_subscription_id
}

provider "azapi" {
  alias           = "connectivity"
  subscription_id = local.alz_config.connectivity_subscription_id
}