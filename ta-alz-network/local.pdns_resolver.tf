
locals {
  private_dns_resolver = {
    rg_name = "${local.alz_config.org_id}-rg-dns-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    name    = "${local.alz_config.org_id}-dnspr-dns-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }

  private_dns_resolver_endpoints = {
    inbound = {
      name = "${local.alz_config.org_id}-dnsprin-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    }
    outbound = {
      name = "${local.alz_config.org_id}-dnsprout-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    }
  }

  private_dns_resolver_ruleset = {
    name = "${local.alz_config.org_id}-dnsfrs-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }
}