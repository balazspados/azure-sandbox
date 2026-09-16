locals {
  law_security_parameters = {
    law_name                                           = "${local.alz_config.org_id}-log-seclaw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    log_analytics_workspace_internet_ingestion_enabled = false       # Default: true
    log_analytics_workspace_internet_query_enabled     = false       # Default: true
    log_analytics_workspace_retention_in_days          = "365"       # Default: 30
    log_analytics_workspace_sku                        = "PerGB2018" # Default: "PerGB2018" OR "Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation"
    private_endpoints_subnet_id                        = data.terraform_remote_state.alz_network.outputs.private_endpoints_subnet.id
    private_endpoint_name                              = "pep-${local.alz_config.org_id}-log-seclaw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"

    private_endpoints_subnet_resource_group_name = data.terraform_remote_state.alz_network.outputs.private_endpoints_subnet.resource_group

    private_dns_zone_ids = [
      data.terraform_remote_state.alz_network.outputs.private_dns_zone_resource_ids["azure_monitor"],
      data.terraform_remote_state.alz_network.outputs.private_dns_zone_resource_ids["azure_log_analytics"],
      data.terraform_remote_state.alz_network.outputs.private_dns_zone_resource_ids["azure_log_analytics_data"],
      data.terraform_remote_state.alz_network.outputs.private_dns_zone_resource_ids["azure_monitor_agent"],
      data.terraform_remote_state.alz_network.outputs.private_dns_zone_resource_ids["azure_storage_blob"],
    ]
    monitor_private_link_scope_name          = "pls-${local.alz_config.org_id}-log-seclaw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    monitor_private_link_scoped_service_name = "pls-svc-${local.alz_config.org_id}-log-seclaw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }
}