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