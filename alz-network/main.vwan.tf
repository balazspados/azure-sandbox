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
module "virtual_wan_hub" {
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
