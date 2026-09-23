locals {
  platform_bastion = {
    name                   = "${local.alz_config.org_id}-bastion-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    sku                    = "Standard"
    copy_paste_enabled     = true  # Default: true
    file_copy_enabled      = false # Default: false
    create_public_ip       = true
    public_ip_address_name = "${local.alz_config.org_id}-pip-bastion-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    # scale_units            = "1"
  }
}