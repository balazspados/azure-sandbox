
### Create RG for vWAN network 
resource "azurerm_resource_group" "rg_nw_vwan" {
  provider = azurerm.connectivity
  location = local.azure_region_location
  name     = local.vwan_parameters.rg_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}


###Create virtual hub
module "avm-ptn-alz-connectivity-virtual-wan" {
  source  = "Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm"
  version = "0.17.1"      # https://github.com/Azure/terraform-azurerm-avm-ptn-alz-connectivity-virtual-wan

  providers = {
    azurerm = azurerm.connectivity
  }

  enable_telemetry = local.avm_telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags

  virtual_wan_settings = {
    enabled_resources = {
      ddos_protection_plan = false
    }
    virtual_wan = {
      name                           = local.vwan_parameters.name
      type                           = local.vwan_parameters.type
      allow_branch_to_branch_traffic = local.vwan_parameters.allow_branch_to_branch_traffic
    }
  }

  virtual_hubs = {
    primary = {
      location = local.azure_region_location
      # default_hub_address_space = "10.225.0.0/22"
      default_parent_id = resource.azurerm_resource_group.rg_nw_vwan.id
      hub = {
        name                   = local.vwan_hub_parameters.name
        address_prefix         = local.vwan_hub_parameters.address_prefix
        hub_routing_preference = local.vwan_hub_parameters.hub_routing_preference
      }
      enabled_resources = {
        firewall                              = false
        firewall_policy                       = false
        bastion                               = false
        virtual_network_gateway_express_route = false
        virtual_network_gateway_vpn           = false
        private_dns_zones                     = false
        private_dns_resolver                  = false
        sidecar_virtual_network               = false
      }
      virtual_network_connections = {
        platform_vnet = {
          name                      = local.platform_vnet_hub_connection.name
          remote_virtual_network_id = module.platform_vnet.resource_id
          internet_security_enabled = false          # Needs to be revisited after establishing VPN/ER connection
        }
      }
    }
  }
}

### Create VPN gateway resources
resource "azurerm_resource_group" "rg_nw_vpngw" {
  provider = azurerm.connectivity
  location = local.azure_region_location
  name     = local.vpn_gateway_paramaters.rg_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

# resource "azurerm_vpn_gateway" "nw_vpngw" {
#   provider            = azurerm.connectivity
#   name                = local.vpn_gateway_paramaters.name
#   resource_group_name = azurerm_resource_group.rg_nw_vpngw.name
#   location            = local.azure_region_location
#   virtual_hub_id      = module.avm-ptn-alz-connectivity-virtual-wan.virtual_hub_resource_ids["primary"]
#   tags                = local.common_tags
# }

### Create Expressroute resources
resource "azurerm_resource_group" "rg_nw_expressroute" {
  provider = azurerm.connectivity
  location = local.azure_region_location
  name     = local.expressroute_paramaters.rg_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

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

### DNS resolver inbound NSG rules
module "nsg_dns_resolver_inbound" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1" # https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup
  providers = {
    azurerm = azurerm.connectivity
  }
  location            = local.azure_region_location
  name                = "${local.org_prefix}-nsg-dnsin-${local.environment}-${local.azure_region_location_short}-001"
  resource_group_name = azurerm_resource_group.platform_vnet.name
  security_rules      = local.platform_dnsin_nsg_rules
  enable_telemetry    = local.avm_telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags                = local.common_tags
}

module "nsg_dns_resolver_outbound" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1" # https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup
  providers = {
    azurerm = azurerm.connectivity
  }
  location            = local.azure_region_location
  name                = "${local.org_prefix}-nsg-dnsout-${local.environment}-${local.azure_region_location_short}-001"
  resource_group_name = azurerm_resource_group.platform_vnet.name
  security_rules      = local.platform_dnsout_nsg_rules
  enable_telemetry    = local.avm_telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags                = local.common_tags
}

### Create private DNS resolver
resource "azurerm_resource_group" "private_dns" {
provider = azurerm.connectivity
location = local.azure_region_location
name     = local.private_dns_resolver.rg_name
tags     = local.common_tags

lifecycle {
prevent_destroy = false
}
}

### DNS Private Resolver, tied to the platform vNet
module "private_dns_resolver" {
source  = "Azure/avm-res-network-dnsresolver/azurerm"
version = "0.8.0" # https://registry.terraform.io/modules/Azure/avm-res-network-dnsresolver/azurerm/latest

providers = {
azurerm = azurerm.connectivity
}

name                        = local.private_dns_resolver.name
resource_group_name         = azurerm_resource_group.private_dns.name
location                    = local.azure_region_location
virtual_network_resource_id = module.platform_vnet.resource_id
enable_telemetry            = local.avm_telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
tags                        = local.common_tags

inbound_endpoints = {
inbound = {
name        = local.private_dns_resolver_endpoints.inbound.name
subnet_name = module.platform_vnet.subnets.dns_resolver_inbound.name
}
}

outbound_endpoints = {
outbound = {
name        = local.private_dns_resolver_endpoints.outbound.name
subnet_name = module.platform_vnet.subnets.dns_resolver_outbound.name

# Actual forwarding rules (on-prem domains) get added under `rules` in Step 8,
# once VPN/ExpressRoute is live and there's an on-prem DNS server to forward to.
forwarding_ruleset = {
onprem = {
name = local.private_dns_resolver_ruleset.name
# Must be an explicit empty map, not omitted — see the fix note below.
rules = {}
# link_with_outbound_endpoint_virtual_network defaults to true — the module
# links this ruleset to the platform vNet automatically, no separate
# azurerm_private_dns_resolver_virtual_network_link resource needed.
}
      }
    }
  }
}

### Create private DNS zone
# Deployed in management subscription see design documentation page 15.
# resource "azurerm_resource_group" "private_dns_zone" {
#   provider = azurerm.management
#   location = local.azure_region_location
#   name     = local.private_dns_zone.rg_name
#   tags     = local.common_tags

#   lifecycle {
#     prevent_destroy = false
#   }
# }

# module "private_dns_zones" {
#   source  = "Azure/avm-ptn-network-private-link-private-dns-zones/azurerm"
#   version = "0.23.2" # https://registry.terraform.io/modules/Azure/avm-ptn-network-private-link-private-dns-zones/azurerm/latest
#   providers = {
#     azurerm = azurerm.management
#   }
#   location         = local.azure_region_location
#   parent_id        = azurerm_resource_group.private_dns_zone.id
#   enable_telemetry = local.avm_telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
#   tags             = local.common_tags

#   virtual_network_link_default_virtual_networks = {
#     platform_vnet = {
#       virtual_network_resource_id                 = azurerm_virtual_network.platform_vnet.id
#       virtual_network_link_name_template_override = local.private_dns_zone_vnet_link.name_template        # due to naming convention
#     }
#   }
# }

