locals {


  #Assemble common tags
  common_tags = {
    description      = "${upper(local.alz_config.org_id)} ALZ Platform Shared services"
    costCenter       = local.alz_config.platform_costcenter
    environment      = local.alz_config.environment
    function         = "Shared services"
    application      = "Shared services"
    deploymentMethod = "terraform"
    gitRepository    = ""
    deployedBy       = ""
    updateSchedule   = ""
  }

  ### Fetech all alz_config values
  alz_config = data.terraform_remote_state.alz.outputs.alz_config

  rg_identity_001 = {
    name = data.terraform_remote_state.alz_network.outputs.rg_identity.name
  }

  rg_management = {
    name = data.terraform_remote_state.alz.outputs.rg_management.name
  }

  security_log_analytics_workspace_id = module.law_security.resource_id
  security_law_rg_name                = "${local.alz_config.org_id}-rg-sec-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"

}