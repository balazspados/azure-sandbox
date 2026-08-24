### Create Platform network
### Create vNet RG
resource "azurerm_resource_group" "platform_vnet" {
  provider = azurerm.connectivity
  location = local.azure_region_location
  name     = local.platform_vnet.rg_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

module "platform_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.22.1" # https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest

  providers = {
    azurerm = azurerm.connectivity
    azapi   = azapi.connectivity
  }

  name             = local.platform_vnet.name
  parent_id        = azurerm_resource_group.platform_vnet.id
  location         = local.azure_region_location
  address_space    = local.platform_vnet.address_space
  enable_telemetry = local.avm_telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags

  subnets = {
    shared = {
      name             = local.platform_vnet_subnets.shared.name
      address_prefixes = local.platform_vnet_subnets.shared.address_prefixes
    }
    dns_resolver_inbound = {
      name             = local.platform_vnet_subnets.dns_resolver_inbound.name
      address_prefixes = local.platform_vnet_subnets.dns_resolver_inbound.address_prefixes
      network_security_group = {
        id = module.nsg_dns_resolver_inbound.resource_id
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
      name             = local.platform_vnet_subnets.dns_resolver_outbound.name
      address_prefixes = local.platform_vnet_subnets.dns_resolver_outbound.address_prefixes
      network_security_group = {
        id = module.nsg_dns_resolver_outbound.resource_id
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
  }
}