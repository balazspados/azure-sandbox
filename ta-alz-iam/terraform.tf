terraform {
  required_version = ">= 1.15.8, <2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.2" # https://github.com/hashicorp/terraform-provider-azurerm
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.9.0" # https://github.com/hashicorp/terraform-provider-azuread
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = local.alz_config.management_subscription_id
  tenant_id       = local.alz_config.azure_tenant_id

}

provider "azuread" {
  tenant_id = local.alz_config.azure_tenant_id
}
