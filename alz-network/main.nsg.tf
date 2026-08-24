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

### DNS resolver outbound NSG rules
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