### Create Bastion RG
resource "azurerm_resource_group" "platform_bastion" {
  provider = azurerm.connectivity
  location = local.alz_config.azure_region_location
  name     = local.platform_bastion.rg_name
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = false
  }
}

module "platform_bastionhost" {
  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "0.9.0" # https://github.com/Azure/terraform-azurerm-avm-res-network-bastionhost

  providers = {
    azurerm = azurerm.connectivity
  }
  name               = local.platform_bastion.name
  location           = local.alz_config.azure_region_location
  parent_id          = azurerm_resource_group.platform_bastion.id
  sku                = local.platform_bastion.sku
  copy_paste_enabled = local.platform_bastion.copy_paste_enabled
  file_copy_enabled  = local.platform_bastion.file_copy_enabled
  ip_configuration = {
    name                   = "${local.alz_config.org_prefix}-platform_bastion-config"
    subnet_id              = module.platform_vnet_001.subnets.azure_bastion.resource_id
    create_public_ip       = local.platform_bastion.create_public_ip
    public_ip_address_name = local.platform_bastion.public_ip_address_name
    
  }
  # scale_units      = local.platform_bastion.scale_units
  enable_telemetry = local.alz_config.telemery_enable # Disabled now, https://azure.github.io/Azure-Verified-Modules/help-support/telemetry/
  tags             = local.common_tags
}