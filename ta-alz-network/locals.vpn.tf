locals {
  vpn_gateway_parameters = {
    name               = "${local.alz_config.org_id}-vpn-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    scale_unit         = "2"
    routing_preference = "Microsoft Network" # Options: Default "Microsoft Network" or "Internet"
  }

  ### MIT Otara VPN Connection (temporary)
  otara_vpn_site_parameters = {
    site_name     = "${local.alz_config.org_id}-vpn-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-100"
    link_name     = "${local.alz_config.org_id}-otlink-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-100"
    vpn_public_ip = "1.1.1.1"
    address_cidrs = ["10.10.10.0/24"]
    provider_name = "REANNZ"
    speed_in_mbps = "1024"
  }

  otara_vpn_connection_parameters = {
    conn_name     = "${local.alz_config.org_id}-otvpncon-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-100"
    vpn_link_name = "${local.alz_config.org_id}-otvpnlink-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-100"
    protocol      = "IKEv2"
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

  ### Unitec Mt. Albert VPN Connection (temporary)
  mtalbert_vpn_site_parameters = {
    site_name     = "${local.alz_config.org_id}-vpn-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-101"
    link_name     = "${local.alz_config.org_id}-malink-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-101"
    vpn_public_ip = "2.2.2.2"
    address_cidrs = ["20.20.20.0/24"]
    provider_name = "REANNZ"
    speed_in_mbps = "1024"
  }

  mtalbert_vpn_connection_parameters = {
    conn_name     = "${local.alz_config.org_id}-mavpncon-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-101"
    vpn_link_name = "${local.alz_config.org_id}-mavpnlink-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-101"
    protocol      = "IKEv2"
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