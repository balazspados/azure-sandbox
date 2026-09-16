terraform {
  required_version = ">= 1.15.8, <2.0.0"

  required_providers {
    alz = {
      source  = "azure/alz"
      version = "~> 0.22" # https://github.com/Azure/terraform-provider-alz
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.12" # https://github.com/Azure/terraform-provider-azapi
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81" # https://github.com/hashicorp/terraform-provider-azurerm
    }
  }
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
  subscription_id = local.alz_config.connectivity_subscription_id
}

provider "azapi" {
  alias           = "connectivity"
  subscription_id = local.alz_config.connectivity_subscription_id
}

provider "azurerm" {
  alias = "identity"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = local.alz_config.identity_subscription_id
}

provider "azapi" {
  alias           = "identity"
  subscription_id = local.alz_config.identity_subscription_id
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
  alias           = "management"
  subscription_id = local.alz_config.management_subscription_id
}


