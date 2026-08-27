locals {
  platform_bastion = {
    rg_name                = "${local.alz_config.org_prefix}-rg-bastion-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    name                   = "${local.alz_config.org_prefix}-bastion-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    sku                    = "Basic"
    copy_paste_enabled     = true  # Default: true
    file_copy_enabled      = false # Default: false
    create_public_ip       = true  # This parameter prevents creating public IPs. Needs to be created separately and public_ip_address_id must be provided
    public_ip_address_name = "${local.alz_config.org_prefix}-pip-bastion-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    # scale_units            = "1"
  }
}