locals {
  des_identity_parameters = {
    des_name = "${local.alz_config.org_id}-des-idn-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }
}