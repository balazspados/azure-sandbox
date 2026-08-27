locals {
  expressroute_paramaters = {
    rg_name = "${local.alz_config.org_prefix}-rg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-002"
    name    = "${local.alz_config.org_prefix}-er-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }

}