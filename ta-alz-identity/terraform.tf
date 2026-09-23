terraform {
  required_version = ">= 1.15.8, <2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81" # https://github.com/hashicorp/terraform-provider-azurerm
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12.0" # https://github.com/Azure/terraform-provider-azapi
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

provider "azurerm" {
  alias = "security"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = local.alz_config.security_subscription_id
}

provider "azapi" {
  alias           = "security"
  subscription_id = local.alz_config.security_subscription_id
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