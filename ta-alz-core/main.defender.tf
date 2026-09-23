module "defender_management" {
  source  = "app.terraform.io/padi-org/ta-res-azure-defender/azurerm"
  version = "1.0.0"  
  providers = { azurerm = azurerm.management }

  plans = {
    CloudPosture = { tier = "Free" }
  }
}
