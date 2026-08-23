locals {
  avm_telemery_enable = data.terraform_remote_state.alz-management.outputs.avm_telemery_enable

  common_tags = {
    description      = "${upper(local.org_prefix)} ALZ Platform core service"
    costCenter       = local.platform_costcenter
    environment      = local.environment
    function         = "Core service"
    application      = "Core service"
    deploymentMethod = "terraform"
    gitRepository    = ""
  }

  platform_costcenter         = data.terraform_remote_state.alz-management.outputs.platform_costcenter
  org_prefix                  = data.terraform_remote_state.alz-management.outputs.org_prefix
  azure_region_location       = data.terraform_remote_state.alz-management.outputs.azure_region_location
  azure_region_location_short = data.terraform_remote_state.alz-management.outputs.azure_region_location_short
  environment                 = data.terraform_remote_state.alz-management.outputs.environment

  azure_tenant_id = data.terraform_remote_state.alz.outputs.azure_tenant_id

  # Resolves each scope_key used in var.rbac_group_definitions to a real Azure
  # resource ID, sourced entirely from the alz workspace's remote state.
  management_group_ids = data.terraform_remote_state.alz.outputs.management_group_resource_ids

  subscription_ids = {
    connectivity = data.terraform_remote_state.alz.outputs.connectivity_subscription_id
    management   = data.terraform_remote_state.alz.outputs.management_subscription_id
    identity     = data.terraform_remote_state.alz.outputs.identity_subscription_id
    security     = data.terraform_remote_state.alz.outputs.security_subscription_id
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