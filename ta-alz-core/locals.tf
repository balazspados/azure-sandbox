locals {
  alz_config = {
    platform_costcenter               = "XXX"
    environment                       = "prd"
    org_id                            = "ta"
    azure_region_location_short       = "ae"
    azure_region_location             = "australiaeast"
    telemetry_enabled                 = false
    management_subscription_id        = "8b7867e2-e2b3-468e-b0ee-68da980c2eee"
    management_subscription_MG_name   = "management" # Management Group ID
    connectivity_subscription_id      = "c7cf7d65-b00e-411a-b252-1394a56b3b5f"
    connectivity_subscription_MG_name = "connectivity" # Management Group ID
    identity_subscription_id          = "701ff494-fc7f-4e23-8849-9220a67c8a5e"
    identity_subscription_MG_name     = "identity" # Management Group ID
    security_subscription_id          = "ce7da240-b2de-4cb5-a68b-ab14af2f4764"
    security_subscription_MG_name     = "security" # Management Group ID
    azure_tenant_id                   = "1c91a700-acbd-4ace-9ace-cb0c30144b54"
    resource_lock_kind                = null # "CanNotDelete" (locked, can't be deleted), "ReadOnly" (locked, fully read-only), or null for no lock (default)
    # resource_lock_kind = "CanNotDelete"
  }
  common_tags = {
    description      = "${upper(local.alz_config.org_id)} ALZ Platform core services"
    costCenter       = local.alz_config.platform_costcenter
    environment      = local.alz_config.environment
    function         = "Core services"
    application      = "Core services"
    deploymentMethod = "terraform"
    gitRepository    = ""
    deployedBy       = ""
    updateSchedule   = ""
  }

  platform_base_parameters = {
    rg_name                                            = "${local.alz_config.org_id}-rg-mgmt-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    law_name                                           = "${local.alz_config.org_id}-log-mgmtlaw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    log_analytics_workspace_internet_ingestion_enabled = false # Default: true
    log_analytics_workspace_internet_query_enabled     = false # Default: true
    log_analytics_workspace_retention_in_days          = "365" # Default: 30
  }

}
