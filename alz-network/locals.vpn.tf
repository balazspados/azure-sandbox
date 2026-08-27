locals {
  vpn_gateway_paramaters = {
    rg_name = "${local.alz_config.org_prefix}-rg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-003"
    name    = "${local.alz_config.org_prefix}-vpn-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
  }

  vpn_site_parameters = {
    # name      = "${local.org_prefix}-mitmanvpnlink-nw-${local.environment}-${local.azure_region_location_short}-001"
    link_name = "${local.alz_config.org_prefix}-mitmanvpnlink-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    remote_ip = null # TBA - on-prem public IP not yet confirmed
  }

  vpn_connection_parameters = {
    name = "${local.alz_config.org_prefix}-vpnconn-mitman-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    ipsec_policy = {
      dh_group                 = "DHGroup14"
      ike_encryption_algorithm = "AES256"
      ike_integrity_algorithm  = "SHA256"
      encryption_algorithm     = "AES256"
      integrity_algorithm      = "SHA256"
      pfs_group                = "PFS14"
      sa_data_size_kb          = "102400000"
      sa_lifetime_sec          = "28800"
    }
  }

}