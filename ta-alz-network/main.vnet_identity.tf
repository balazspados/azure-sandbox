


### Create Identity network

module "identity_vnet_001" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.1" # https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest

  providers = {
    # azurerm = azurerm.identity
    azapi = azapi.identity
  }
  diagnostic_settings = {
    law = {
      workspace_resource_id = local.platform_log_analytics_workspace_id
    }
  }
  name             = local.identity_vnet_001.name
  parent_id        = azurerm_resource_group.rg_identity_001.id
  location         = local.alz_config.azure_region_location
  address_space    = local.identity_vnet_001.address_space
  enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags

  subnets = {
    snet_identity = {
      name             = local.identity_vnet_001.subnets.snet_identity.name
      address_prefixes = local.identity_vnet_001.subnets.snet_identity.address_prefixes
      network_security_group = {
        id = module.nsg_nw_vnet_idn_001.resource_id
      }
    }
    snet_paw = {
      name             = local.identity_vnet_001.subnets.snet_paw.name
      address_prefixes = local.identity_vnet_001.subnets.snet_paw.address_prefixes
      network_security_group = {
        id = module.nsg_nw_vnet_idn_001.resource_id
      }
    }
  }
}