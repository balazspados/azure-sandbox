locals {
  vwan_parameters = {
    name                           = "${local.alz_config.org_id}-vwan-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    type                           = "Standard" # Options: "Basic" or "Standard"
    allow_branch_to_branch_traffic = true
    ddos_protection_plan           = true
    ddos_protection_plan_name      = "${local.alz_config.org_id}-ddosprotection-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }
  vhub_parameters = {
    name                   = "${local.alz_config.org_id}-vhub-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    address_prefix         = "10.225.0.0/22"
    hub_routing_preference = "VpnGateway" #Options: "ExpressRoute" or "VpnGateway" or "ASPath"
    sku                    = "Standard"   # Options: "Basic" or Default: "Standard"
  }

  # vwan_firewall_parameters = {
  #   name                 = "${local.alz_config.org_id}-afw-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  #   sku_tier             = "Standard" #Options: "Basic", "Standard" or "Premium"
  #   vhub_public_ip_count = "5"
  # }
  # vwan_firewall_policy_parameters = {
  #   name = "${local.alz_config.org_id}-afwp-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  #   sku  = local.vwan_firewall_parameters.sku_tier
  # }

}