locals {
  private_dns_zone = {
    rg_name = "${local.alz_config.org_prefix}-rg-pdnsz-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }

  private_dns_zone_vnet_link = {
    name_template = "${local.alz_config.org_prefix}-pdnszlink-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }
}
