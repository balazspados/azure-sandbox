

module "defender_identity" {
  source    = "./modules/DefenderForCloud"
  providers = { azurerm = azurerm.identity }

  plans = {
    CloudPosture    = { tier = "Free" } # Foundational CSPM
    VirtualMachines = { tier = "Free" } # "Servers" — disabled as per ALZ design
    KeyVaults       = { tier = "Standard" }
    ### Not applicable for this subscription
    ### Possible resource_type values are AI, Api, AppServices, ContainerRegistry, KeyVaults, KubernetesService, SqlServers, SqlServerVirtualMachines, StorageAccounts, VirtualMachines, Arm, Dns, OpenSourceRelationalDatabases, Containers, CosmosDbs and CloudPosture
    ### https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing
    # AppServices                   = { tier = "Standard" }
    # SqlServers                    = { tier = "Standard" } # "Azure SQL Database"
    # SqlServerVirtualMachines      = { tier = "Free" }     # "SQL Servers on Machines" — disabled per table
    # OpenSourceRelationalDatabases = { tier = "Standard" }
    # CosmosDbs                     = { tier = "Standard" }
    # StorageAccounts               = { tier = "Standard", subplan = "DefenderForStorageV2" } # malware scanning stays off (never enabled)
    # Containers                    = { tier = "Standard" }
    # Arm                           = { tier = "Standard" } # "Resource Manager"
    # Api                           = { tier = "Free" }     # disabled per table
  }
}
