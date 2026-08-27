locals {

  common_tags = {
    description      = "${upper(local.alz_config.org_prefix)} ALZ Platform core service"
    costCenter       = local.alz_config.platform_costcenter
    environment      = local.alz_config.environment
    function         = "Core service"
    application      = "Core service"
    deploymentMethod = "terraform"
    gitRepository    = ""
  }

  alz_config = {
    platform_costcenter               = data.terraform_remote_state.alz-management.outputs.alz_config.platform_costcenter
    org_prefix                        = data.terraform_remote_state.alz-management.outputs.alz_config.org_prefix
    azure_region_location             = data.terraform_remote_state.alz-management.outputs.alz_config.azure_region_location
    azure_region_location_short       = data.terraform_remote_state.alz-management.outputs.alz_config.azure_region_location_short
    environment                       = data.terraform_remote_state.alz-management.outputs.alz_config.environment
    telemery_enable                   = data.terraform_remote_state.alz-management.outputs.alz_config.telemery_enable
    azure_tenant_id                   = data.terraform_remote_state.alz-management.outputs.alz_config.azure_tenant_id
    connectivity_subscription_MG_name = data.terraform_remote_state.alz-management.outputs.alz_config.connectivity_subscription_MG_name
    connectivity_subscription_id      = data.terraform_remote_state.alz-management.outputs.alz_config.connectivity_subscription_id
    identity_subscription_MG_name     = data.terraform_remote_state.alz-management.outputs.alz_config.identity_subscription_MG_name
    identity_subscription_id          = data.terraform_remote_state.alz-management.outputs.alz_config.identity_subscription_id
    management_subscription_MG_name   = data.terraform_remote_state.alz-management.outputs.alz_config.management_subscription_MG_name
    management_subscription_id        = data.terraform_remote_state.alz-management.outputs.alz_config.management_subscription_id
    security_subscription_MG_name     = data.terraform_remote_state.alz-management.outputs.alz_config.security_subscription_MG_name
    security_subscription_id          = data.terraform_remote_state.alz-management.outputs.alz_config.security_subscription_id
  }

}