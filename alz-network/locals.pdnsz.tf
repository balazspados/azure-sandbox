locals {
  private_dns_zone = {
    rg_name = "${local.org_prefix}-rg-pdnsz-${local.environment}-${local.azure_region_location_short}-001"
  }

  private_dns_zone_vnet_link = {
    name_template = "${local.org_prefix}-pdnszlink-${local.environment}-${local.azure_region_location_short}-001"
  }
}
