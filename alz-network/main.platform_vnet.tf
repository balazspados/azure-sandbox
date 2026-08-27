### Create Platform network

module "platform_vnet_001" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.1" # https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest

  providers = {
    azurerm = azurerm.connectivity
    azapi   = azapi.connectivity
  }

  name             = local.platform_vnet_001.name
  parent_id        = azurerm_resource_group.rg_nw_001.id
  location         = local.alz_config.azure_region_location
  address_space    = local.platform_vnet_001.address_space
  enable_telemetry = local.alz_config.telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags

  subnets = {
    dns_resolver_inbound = {
      name             = local.platform_vnet_001_subnets.dns_resolver_inbound.name
      address_prefixes = local.platform_vnet_001_subnets.dns_resolver_inbound.address_prefixes
      network_security_group = {
        id = module.nsg_nw_prd_ae_001.resource_id
      }
      delegations = [
        {
          name = "dnsResolverInbound"
          service_delegation = {
            name = "Microsoft.Network/dnsResolvers"
          }
        }
      ]
    }
    dns_resolver_outbound = {
      name             = local.platform_vnet_001_subnets.dns_resolver_outbound.name
      address_prefixes = local.platform_vnet_001_subnets.dns_resolver_outbound.address_prefixes
      network_security_group = {
        id = module.nsg_nw_prd_ae_001.resource_id
      }
      delegations = [
        {
          name = "dnsResolverOutbound"
          service_delegation = {
            name = "Microsoft.Network/dnsResolvers"
          }
        }
      ]
    }
    azure_bastion = {
      name             = local.platform_vnet_001_subnets.azure_bastion.name
      address_prefixes = local.platform_vnet_001_subnets.azure_bastion.address_prefixes
      network_security_group = {
        id = module.nsg_nw_bastion.resource_id
      }
    }
  }
}

module "platform_vnet_002" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.1" # https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest

  providers = {
    azurerm = azurerm.connectivity
    azapi   = azapi.connectivity
  }

  name             = local.platform_vnet_002.name
  parent_id        = azurerm_resource_group.rg_nw_001.id
  location         = local.alz_config.azure_region_location
  address_space    = local.platform_vnet_002.address_space
  enable_telemetry = local.alz_config.telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags

  subnets = {
    private_endpoints = {
      name                              = local.platform_vnet_002_subnets.private_endpoints.name
      address_prefixes                  = local.platform_vnet_002_subnets.private_endpoints.address_prefixes
      private_endpoint_network_policies = "Enabled" # explicit: required for the NSG below to apply to PE NICs
      network_security_group = {
        id = module.nsg_nw_prd_ae_002.resource_id
      }
    }
  }
}