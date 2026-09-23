locals {

  private_dns_zone_vnet_link = {
    platform_vnet_001_name = "${local.alz_config.org_id}-pdnszlink-platform-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    platform_vnet_005_name = "${local.alz_config.org_id}-pdnszlink-platform-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-005"
    identity_vnet_001_name = "${local.alz_config.org_id}-pdnszlink-identity-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }
}
