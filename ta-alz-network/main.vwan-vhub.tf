

# ###Create virtual hub
# module "virtual_wan_hub" {
#   source  = "Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm"
#   version = "0.17.1" # https://github.com/Azure/terraform-azurerm-avm-ptn-alz-connectivity-virtual-wan

#   providers = {
#     azurerm = azurerm.connectivity
#     azapi   = azapi.connectivity
#   }

#   enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
#   tags             = local.common_tags
#   default_naming_convention = {
#     ddos_protection_plan_name = local.vwan_parameters.ddos_protection_plan_name
#   }

#   virtual_wan_settings = {
#     enabled_resources = {
#       ddos_protection_plan = local.vwan_parameters.ddos_protection_plan
#     }
#     virtual_wan = {
#       name                           = local.vwan_parameters.name
#       location                       = local.alz_config.azure_region_location
#       type                           = local.vwan_parameters.type
#       allow_branch_to_branch_traffic = local.vwan_parameters.allow_branch_to_branch_traffic
#       resource_group_name            = resource.azurerm_resource_group.rg_nw_001.name
#     }
#   }

#   virtual_hubs = {
#     primary = {
#       location          = local.alz_config.azure_region_location
#       default_parent_id = resource.azurerm_resource_group.rg_nw_001.id
#       hub = {
#         name                   = local.vhub_parameters.name
#         address_prefix         = local.vhub_parameters.address_prefix
#         hub_routing_preference = local.vhub_parameters.hub_routing_preference
#         sku                    = local.vhub_parameters.sku
#       }
#       enabled_resources = {
#         firewall                              = false
#         firewall_policy                       = false
#         bastion                               = false
#         virtual_network_gateway_express_route = false
#         virtual_network_gateway_vpn           = false
#         private_dns_zones                     = false
#         private_dns_resolver                  = false
#         sidecar_virtual_network               = false
#       }
#       virtual_network_connections = {
#         # Platform 001 vNet peering
#         platform_vnet_001 = {
#           name                      = local.platform_vnet_001.hub_connection_name
#           remote_virtual_network_id = module.platform_vnet_001.resource_id
#           internet_security_enabled = false # Needs to be revisited after establishing VPN/ER connection
#         }
#         # Platform PEP vNet peering
#         platform_vnet_005 = {
#           name                      = local.platform_vnet_005.hub_connection_name
#           remote_virtual_network_id = module.platform_vnet_005.resource_id
#           internet_security_enabled = false # Needs to be revisited after establishing VPN/ER connection
#         }
#         # Identity vNet peering
#         identity_vnet_001 = {
#           name                      = local.identity_vnet_001.hub_connection_name
#           remote_virtual_network_id = module.identity_vnet_001.resource_id
#           internet_security_enabled = false # Needs to be revisited after establishing VPN/ER connection
#         }
#       }

#     }
#   }
# }

# ### vHUB monitoring
# resource "azurerm_monitor_diagnostic_setting" "virtual_hub" {
#   provider                   = azurerm.connectivity
#   name                       = "diag-${local.vhub_parameters.name}"
#   target_resource_id         = module.virtual_wan_hub.virtual_hub_resource_ids["primary"]
#   log_analytics_workspace_id = local.platform_log_analytics_workspace_id

#   enabled_metric { category = "AllMetrics" }
# }