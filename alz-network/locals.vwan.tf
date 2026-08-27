locals {
  vwan_parameters = {
    rg_name                        = "${local.alz_config.org_prefix}-rg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    name                           = "${local.alz_config.org_prefix}-vwan-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    type                           = "Standard"
    allow_branch_to_branch_traffic = true
  }
  vwan_hub_parameters = {
    name                   = "${local.alz_config.org_prefix}-vhub-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    address_prefix         = "10.225.0.0/22"
    hub_routing_preference = "VpnGateway" #Options: "ExpressRoute" or "VpnGateway"
  }

}