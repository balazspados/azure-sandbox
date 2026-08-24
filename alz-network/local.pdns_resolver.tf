
locals {
  private_dns_resolver = {
    rg_name = "${local.org_prefix}-rg-dns-${local.environment}-${local.azure_region_location_short}-001"
    name    = "${local.org_prefix}-dnspr-${local.environment}-${local.azure_region_location_short}-001"
  }

  private_dns_resolver_endpoints = {
    inbound = {
      name = "${local.org_prefix}-dnsprin-${local.environment}-${local.azure_region_location_short}-001"
    }
    outbound = {
      name = "${local.org_prefix}-dnsprout-${local.environment}-${local.azure_region_location_short}-001"
    }
  }

  private_dns_resolver_ruleset = {
    name = "${local.org_prefix}-dnsfrs-${local.environment}-${local.azure_region_location_short}-001"
  }
}