locals {
  common_tags = {
    description      = "${upper(local.alz_config.org_id)} ALZ Platform IAM "
    costCenter       = local.alz_config.platform_costcenter
    environment      = local.alz_config.environment
    function         = "Platform IAM"
    application      = "Platform IAM"
    deploymentMethod = "terraform"
    gitRepository    = ""
    deployedBy       = ""
    updateSchedule   = ""
  }

  # Get values from upstream alz module
  management_group_ids = data.terraform_remote_state.alz.outputs.management_group_resource_ids

  subscription_ids = {
    connectivity = local.alz_config.connectivity_subscription_id
    management   = local.alz_config.management_subscription_id
    identity     = local.alz_config.identity_subscription_id
    security     = local.alz_config.security_subscription_id
  }

  # Get all alz_config values from upstream alz module
  alz_config = data.terraform_remote_state.alz.outputs.alz_config

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