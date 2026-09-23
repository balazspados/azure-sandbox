
module "defender_security" {
  source  = "app.terraform.io/padi-org/ta-res-azure-defender/azurerm"
  version = "1.0.0"  
  providers = { azurerm = azurerm.security }

  plans = {
    CloudPosture = { tier = "Free" }
  }
}

