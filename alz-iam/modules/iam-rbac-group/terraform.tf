terraform {
  required_version = ">= 1.15, < 2.0"

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
