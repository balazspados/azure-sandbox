module "defender_management" {
  source    = "./modules/DefenderForCloud"
  providers = { azurerm = azurerm.management }

  plans = {
    CloudPosture = { tier = "Free" }
  }
}
