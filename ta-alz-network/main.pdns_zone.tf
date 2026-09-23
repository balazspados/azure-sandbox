### Create private DNS zone

module "private_dns_zones" {
  source  = "Azure/avm-ptn-network-private-link-private-dns-zones/azurerm"
  version = "0.23.2" # https://registry.terraform.io/modules/Azure/avm-ptn-network-private-link-private-dns-zones/azurerm/latest
  providers = {
    azapi = azapi.connectivity
  }
  location         = local.alz_config.azure_region_location
  parent_id        = azurerm_resource_group.rg_nw_006.id
  enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags

    virtual_network_link_default_virtual_networks = {
      platform_vnet_001 = {
        virtual_network_resource_id                 = module.platform_vnet_001.resource_id
        virtual_network_link_name_template_override = local.private_dns_zone_vnet_link.platform_vnet_001_name # overwrites default naming convention 
      }
      platform_vnet_005 = {
        virtual_network_resource_id                 = module.platform_vnet_005.resource_id
        virtual_network_link_name_template_override = local.private_dns_zone_vnet_link.platform_vnet_005_name # overwrites default naming convention 
      }
      identity_vnet_001 = {
        virtual_network_resource_id                 = module.identity_vnet_001.resource_id
        virtual_network_link_name_template_override = local.private_dns_zone_vnet_link.identity_vnet_001_name # overwrites default naming convention        
      }
    }
}

