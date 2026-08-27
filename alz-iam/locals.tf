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

  # Get values from upstream alz module
  management_group_ids = data.terraform_remote_state.alz.outputs.management_group_resource_ids

  subscription_ids = {
    connectivity = local.alz_config.connectivity_subscription_id
    management   = local.alz_config.management_subscription_id
    identity     = local.alz_config.identity_subscription_id
    security     = local.alz_config.security_subscription_id
  }

  # Get values from upstream alz-management module
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

  scope_id_by_ref = merge(
    { for k, v in local.management_group_ids : "management_group:${k}" => v },
    { for k, v in local.subscription_ids : "subscription:${k}" => "/subscriptions/${v}" },
  )

  rbac_groups = {
    for def in var.rbac_group_definitions :
    def.group_name => merge(def, {
      scope_id = local.scope_id_by_ref["${def.scope_type}:${def.scope_key}"]
    })
  }
}