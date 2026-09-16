
# resource "azurerm_monitor_diagnostic_setting" "platform_bastion" {
#   provider                   = azurerm.connectivity
#   name                       = "diag-${local.platform_bastion.name}"
#   target_resource_id         = module.platform_bastionhost.resource_id
#   log_analytics_workspace_id = local.platform_log_analytics_workspace_id

#   enabled_log { category_group = "allLogs" }
#   enabled_metric { category = "AllMetrics" }
# }

# module "platform_bastionhost" {
#   source  = "Azure/avm-res-network-bastionhost/azurerm"
#   version = "0.9.0" # https://github.com/Azure/terraform-azurerm-avm-res-network-bastionhost

#   providers = {
#     azurerm = azurerm.connectivity
#   }
#   name               = local.platform_bastion.name
#   location           = local.alz_config.azure_region_location
#   parent_id          = azurerm_resource_group.rg_nw_004.id
#   sku                = local.platform_bastion.sku
#   copy_paste_enabled = local.platform_bastion.copy_paste_enabled
#   file_copy_enabled  = local.platform_bastion.file_copy_enabled
#   ip_configuration = {
#     name                   = "${local.alz_config.org_id}-platform_bastion-config"
#     subnet_id              = module.platform_vnet_001.subnets.azure_bastion.resource_id
#     create_public_ip       = local.platform_bastion.create_public_ip
#     public_ip_address_name = local.platform_bastion.public_ip_address_name

#   }
#   # scale_units      = local.platform_bastion.scale_units
#   enable_telemetry = local.alz_config.telemetry_enabled # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
#   tags             = local.common_tags
# }