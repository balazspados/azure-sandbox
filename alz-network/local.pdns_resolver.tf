
locals {
  private_dns_resolver = {
    rg_name = "${local.alz_config.org_prefix}-rg-dns-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    name    = "${local.alz_config.org_prefix}-dnspr-dns-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }

  private_dns_resolver_endpoints = {
    inbound = {
      name = "${local.alz_config.org_prefix}-dnsprin-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    }
    outbound = {
      name = "${local.alz_config.org_prefix}-dnsprout-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    }
  }

  private_dns_resolver_ruleset = {
    name = "${local.alz_config.org_prefix}-dnsfrs-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }
}