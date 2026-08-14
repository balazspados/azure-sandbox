locals {
  common_tags = {
    description      = "${upper(local.org_prefix)} ALZ Platform"
    costCenter       = local.platform_costcenter
    environment      = local.environment
    function         = "${upper(local.org_prefix)} ALZ Platform"
    application      = "${upper(local.org_prefix)} ALZ Platform"
    deploymentMethod = "terraform"
    gitRepository    = ""
  }

  private_dns_name_rg = "${local.org_prefix}-rg-private_dns-${local.environment}-${local.azure_region_location_short}-001"

  platform_costcenter         = data.terraform_remote_state.alz-management.outputs.platform_costcenter
  org_prefix                  = data.terraform_remote_state.alz-management.outputs.org_prefix
  azure_region_location       = data.terraform_remote_state.alz-management.outputs.azure_region_location
  azure_region_location_short = data.terraform_remote_state.alz-management.outputs.azure_region_location_short
  environment                 = data.terraform_remote_state.alz-management.outputs.environment
}