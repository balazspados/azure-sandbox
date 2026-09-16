# ### Create private DNS resolver

# resource "azurerm_monitor_diagnostic_setting" "private_dns_resolver" {
#   provider                   = azurerm.connectivity
#   name                       = "diag-${local.private_dns_resolver.name}"
#   target_resource_id         = module.private_dns_resolver.resource_id
#   log_analytics_workspace_id = local.platform_log_analytics_workspace_id

#   enabled_metric { category = "AllMetrics" }
# }


# ### DNS Private Resolver, tied to the platform vNet
# module "private_dns_resolver" {
#   source  = "Azure/avm-res-network-dnsresolver/azurerm"
#   version = "0.8.0" # https://registry.terraform.io/modules/Azure/avm-res-network-dnsresolver/azurerm/latest

#   providers = {
#     azurerm = azurerm.connectivity
#   }

#   name                        = local.private_dns_resolver.name
#   resource_group_name         = azurerm_resource_group.rg_nw_001.name
#   location                    = local.alz_config.azure_region_location
#   virtual_network_resource_id = module.platform_vnet_001.resource_id
#   enable_telemetry            = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
#   tags                        = local.common_tags

#   inbound_endpoints = {
#     inbound = {
#       name        = local.private_dns_resolver_endpoints.inbound.name
#       subnet_name = module.platform_vnet_001.subnets.dns_resolver_inbound.name
#     }
#   }

#   outbound_endpoints = {
#     outbound = {
#       name        = local.private_dns_resolver_endpoints.outbound.name
#       subnet_name = module.platform_vnet_001.subnets.dns_resolver_outbound.name

#       # Actual forwarding rules,
#       # once VPN/ExpressRoute is live and there's an on-prem DNS server to forward to.
#       forwarding_ruleset = {
#         onprem = {
#           name = local.private_dns_resolver_ruleset.name
#           
#           rules = {}
#         }
#       }
#     }
#   }
# }