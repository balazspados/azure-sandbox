locals {
  #Assemble common tags
  common_tags = {
    description      = "${upper(local.alz_config.org_id)} ALZ Platform network services"
    costCenter       = local.alz_config.platform_costcenter
    environment      = local.alz_config.environment
    function         = "Network services"
    application      = "Network services"
    deploymentMethod = "terraform"
    gitRepository    = ""
    deployedBy       = ""
    updateSchedule   = ""
  }

  ### Fetech all alz_config values
  alz_config = data.terraform_remote_state.alz.outputs.alz_config


  platform_log_analytics_workspace_id = data.terraform_remote_state.alz.outputs.platform_log_analytics_workspace_id


  platform_rg_nw_001_name = "${local.alz_config.org_id}-rg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  platform_rg_nw_002_name = "${local.alz_config.org_id}-rg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-002"
  platform_rg_nw_003_name = "${local.alz_config.org_id}-rg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-003"
  platform_rg_nw_004_name = "${local.alz_config.org_id}-rg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-004"
  platform_rg_nw_005_name = "${local.alz_config.org_id}-rg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-005"
  platform_rg_nw_006_name = "${local.alz_config.org_id}-rg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-006"
  

  identity_rg_001_name = "${local.alz_config.org_id}-rg-idn-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
}