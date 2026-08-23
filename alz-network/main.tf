
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

resource "azurerm_vpn_gateway" "nw_vpngw" {
  provider            = azurerm.connectivity
  name                = local.vpn_gateway_paramaters.name
  resource_group_name = azurerm_resource_group.rg_nw_vpngw.name
  location            = local.azure_region_location
  virtual_hub_id      = module.avm-ptn-alz-connectivity-virtual-wan.virtual_hub_resource_ids["primary"]
  tags                = local.common_tags
}

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

### Create private DNS zone
# Deployed in management subscription see design documentation page 15.
resource "azurerm_resource_group" "private_pdnsz_zone" {
  provider = azurerm.management
  location = local.azure_region_location
  name     = local.private_pdnsz_zone.rg_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

module "private_dns_zones" {
  source  = "Azure/avm-ptn-network-private-link-private-dns-zones/azurerm"
  version = "0.23.2" # https://registry.terraform.io/modules/Azure/avm-ptn-network-private-link-private-dns-zones/azurerm/latest
  providers = {
    azurerm = azurerm.management
  }
  location         = local.azure_region_location
  parent_id        = azurerm_resource_group.private_pdnsz_zone.id
  enable_telemetry = local.avm_telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags
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