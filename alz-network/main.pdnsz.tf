### Create private DNS zone
### Deployed in management subscription see design documentation page 15.
resource "azurerm_resource_group" "private_dns_zone" {
  provider = azurerm.management
  location = local.alz_config.azure_region_location
  name     = local.private_dns_zone.rg_name
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
  location         = local.alz_config.azure_region_location
  parent_id        = azurerm_resource_group.private_dns_zone.id
  enable_telemetry = local.alz_config.telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags

  virtual_network_link_default_virtual_networks = {
    platform_vnet = {
      virtual_network_resource_id                 = module.platform_vnet_001.resource_id
      virtual_network_link_name_template_override = local.private_dns_zone_vnet_link.name_template # overwrites default naming convention 
    }
  }
}