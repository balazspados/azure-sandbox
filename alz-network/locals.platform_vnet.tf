locals {

  platform_vnet_001 = {
    name                = "${local.alz_config.org_prefix}-vnet-platform_nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    address_space       = ["10.225.4.0/24"]
    hub_connection_name = "${local.alz_config.org_prefix}-vhubconn-platform_nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }

  platform_vnet_001_subnets = {
    dns_resolver_inbound = {
      name             = "snet-dns-resolver-inbound"
      address_prefixes = ["10.225.4.0/27"]
    }
    dns_resolver_outbound = {
      name             = "snet-dns-resolver-outbound"
      address_prefixes = ["10.225.4.32/27"]
    }
    azure_bastion = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.225.4.64/27"]
    }
  }

  platform_vnet_002 = {
    name                = "${local.alz_config.org_prefix}-vnet-platform_nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-002"
    address_space       = ["10.225.8.0/21"]
    hub_connection_name = "${local.alz_config.org_prefix}-vhubconn-platform_nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-002"
  }
  platform_vnet_002_subnets = {
    private_endpoints = {
      name             = "snet-private-endpoints"
      address_prefixes = ["10.225.8.0/21"]
    }
  }
}