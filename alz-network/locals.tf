locals {
  avm_telemery_enable = data.terraform_remote_state.alz-management.outputs.avm_telemery_enable

  #Assemble common tags
  common_tags = {
    description      = "${upper(local.org_prefix)} ALZ Platform core service"
    costCenter       = local.platform_costcenter
    environment      = local.environment
    function         = "Core service"
    application      = "Core service"
    deploymentMethod = "terraform"
    gitRepository    = ""
  }

  connectivity_subscription_id = data.terraform_remote_state.alz.outputs.connectivity_subscription_id
  management_subscription_id   = data.terraform_remote_state.alz.outputs.management_subscription_id

  platform_costcenter         = data.terraform_remote_state.alz-management.outputs.platform_costcenter
  org_prefix                  = data.terraform_remote_state.alz-management.outputs.org_prefix
  azure_region_location       = data.terraform_remote_state.alz-management.outputs.azure_region_location
  azure_region_location_short = data.terraform_remote_state.alz-management.outputs.azure_region_location_short
  environment                 = data.terraform_remote_state.alz-management.outputs.environment

}