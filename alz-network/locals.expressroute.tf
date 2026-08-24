locals {
  expressroute_paramaters = {
    rg_name = "${local.org_prefix}-rg-nw-${local.environment}-${local.azure_region_location_short}-002"
    name    = "${local.org_prefix}-er-nw-${local.environment}-${local.azure_region_location_short}-001"
  }

}