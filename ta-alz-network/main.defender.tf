module "defender_connectivity" {
  source    = "./modules/DefenderForCloud"
  providers = { azurerm = azurerm.connectivity }

  plans = {
    CloudPosture = { tier = "Free" } # Foundational CSPM
    KeyVaults       = { tier = "Standard" }
  }
  
}
