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

  security_log_analytics_workspace = data.terraform_remote_state.alz_security.outputs.security_log_analytics_workspace

}