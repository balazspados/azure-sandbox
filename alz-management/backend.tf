terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-nzn"
    storage_account_name = "sttfstateplatformnzn001"
    container_name       = "terraformstate"
    key                  = "alz-management/terraform.tfstate"
    use_azuread_auth     = true # use AAD/OIDC instead of access keys
  }
}