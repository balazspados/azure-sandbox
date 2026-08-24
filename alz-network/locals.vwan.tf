locals {
  vwan_parameters = {
    rg_name                        = "${local.org_prefix}-rg-nw-${local.environment}-${local.azure_region_location_short}-001"
    name                           = "${local.org_prefix}-vwan-nw-${local.environment}-${local.azure_region_location_short}-001"
    type                           = "Standard"
    allow_branch_to_branch_traffic = true
  }
  vwan_hub_parameters = {
    name                   = "${local.org_prefix}-vhub-nw-${local.environment}-${local.azure_region_location_short}-001"
    address_prefix         = "10.225.0.0/22"
    hub_routing_preference = "VpnGateway" #Options: "ExpressRoute" or "VpnGateway"
  }

}