terraform {
  required_version = "~> 1.15.8"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.35" # https://registry.terraform.io/providers/hashicorp/azurerm/latest
    }
  }
}


