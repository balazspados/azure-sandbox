
### Create Resource Guard Deployment resource
module "resource_guard_deployment" {
  source  = "Azure/avm-res-dataprotection-resourceguard/azurerm"
  version = "0.1.0" # https://github.com/Azure/terraform-azurerm-avm-res-dataprotection-resourceguard
  providers = {
    azurerm = azurerm.security
    azapi   = azapi.security
  }
  tags                                    = local.common_tags
  enable_telemetry                        = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  location                                = local.alz_config.azure_region_location
  name                                    = local.resource_guard_deployment.rgd_name
  resource_group_id                       = azurerm_resource_group.rg_management.id
  vault_critical_operation_exclusion_list = [] # Mandatory attribute, otherwise TF keeps updating RGD resources states
}
