
module "defender_security" {
  source    = "./modules/DefenderForCloud"
  providers = { azurerm = azurerm.security }

  plans = {
    CloudPosture = { tier = "Free" }
  }
}

