locals {
  expressroute_paramaters = {
    name = "${local.alz_config.org_id}-er-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }

}