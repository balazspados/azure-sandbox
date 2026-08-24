locals {

  platform_vnet = {
    rg_name       = "${local.org_prefix}-rg-vnet-${local.environment}-${local.azure_region_location_short}-001"
    name          = "${local.org_prefix}-vnet-nw-${local.environment}-${local.azure_region_location_short}-001"
    address_space = ["10.225.4.0/25"]
  }

  platform_vnet_subnets = {
    shared = {
      name             = "${local.org_prefix}-snet-shared-${local.environment}-${local.azure_region_location_short}-001"
      address_prefixes = ["10.225.4.0/27"]
    }
    dns_resolver_inbound = {
      name             = "${local.org_prefix}-snet-dnsin-${local.environment}-${local.azure_region_location_short}-001"
      address_prefixes = ["10.225.4.32/27"]
    }
    dns_resolver_outbound = {
      name             = "${local.org_prefix}-snet-dnsout-${local.environment}-${local.azure_region_location_short}-001"
      address_prefixes = ["10.225.4.64/27"]
    }
  }

  platform_vnet_hub_connection = {
    name = "${local.org_prefix}-vhubconn-nw-${local.environment}-${local.azure_region_location_short}-001"
  }

}