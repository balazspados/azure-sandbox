module "defender_connectivity" {
  source  = "app.terraform.io/padi-org/ta-res-azure-defender/azurerm"
  version = "1.0.0"  
  providers = { azurerm = azurerm.connectivity }

  plans = {
    CloudPosture = { tier = "Free" } # Foundational CSPM
    KeyVaults       = { tier = "Standard" }
  }
  
}
