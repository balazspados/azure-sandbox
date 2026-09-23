
resource "azurerm_monitor_diagnostic_setting" "platform_vpngw" {
  provider                   = azurerm.connectivity
  name                       = "diag-${local.vpn_gateway_parameters.name}"
  target_resource_id         = resource.azurerm_vpn_gateway.platform_vpngw.id
  log_analytics_workspace_id = local.platform_log_analytics_workspace_id

  enabled_log { category_group = "allLogs" }
  enabled_metric { category = "AllMetrics" }
}


resource "azurerm_vpn_gateway" "platform_vpngw" {
  provider            = azurerm.connectivity
  name                = local.vpn_gateway_parameters.name
  resource_group_name = azurerm_resource_group.rg_nw_001.name
  location            = local.alz_config.azure_region_location
  virtual_hub_id      = module.virtual_wan_hub.virtual_hub_resource_ids["primary"]
  scale_unit          = local.vpn_gateway_parameters.scale_unit
  routing_preference  = local.vpn_gateway_parameters.routing_preference
  tags                = local.common_tags
}

### Temporary VPN connection to MIT Orata site
resource "azurerm_vpn_site" "otara" {
  provider            = azurerm.connectivity
  name                = local.otara_vpn_site_parameters.site_name
  resource_group_name = azurerm_resource_group.rg_nw_003.name
  location            = local.alz_config.azure_region_location
  virtual_wan_id      = module.virtual_wan_hub.resource_id
  address_cidrs       = local.otara_vpn_site_parameters.address_cidrs
  tags                = local.common_tags

  link {
    name          = local.otara_vpn_site_parameters.link_name
    ip_address    = local.otara_vpn_site_parameters.vpn_public_ip
    speed_in_mbps = local.otara_vpn_site_parameters.speed_in_mbps
    provider_name = local.otara_vpn_site_parameters.provider_name
  }
}

resource "azurerm_vpn_gateway_connection" "otara" {
  provider           = azurerm.connectivity
  name               = local.otara_vpn_connection_parameters.conn_name
  vpn_gateway_id     = azurerm_vpn_gateway.platform_vpngw.id
  remote_vpn_site_id = azurerm_vpn_site.otara.id

  vpn_link {
    name             = local.otara_vpn_connection_parameters.vpn_link_name
    vpn_site_link_id = azurerm_vpn_site.otara.link[0].id
    protocol         = local.otara_vpn_connection_parameters.protocol
    shared_key       = data.azurerm_key_vault_secret.vpn_psk_otara.value

    ipsec_policy {
      dh_group                 = local.otara_vpn_connection_parameters.ipsec_policy.dh_group
      ike_encryption_algorithm = local.otara_vpn_connection_parameters.ipsec_policy.ike_encryption_algorithm
      ike_integrity_algorithm  = local.otara_vpn_connection_parameters.ipsec_policy.ike_integrity_algorithm
      encryption_algorithm     = local.otara_vpn_connection_parameters.ipsec_policy.encryption_algorithm
      integrity_algorithm      = local.otara_vpn_connection_parameters.ipsec_policy.integrity_algorithm
      pfs_group                = local.otara_vpn_connection_parameters.ipsec_policy.pfs_group
      sa_data_size_kb          = local.otara_vpn_connection_parameters.ipsec_policy.sa_data_size_kb
      sa_lifetime_sec          = local.otara_vpn_connection_parameters.ipsec_policy.sa_lifetime_sec
    }
  }
}


### Temporary VPN connection to Unitec Mt. Albert site
resource "azurerm_vpn_site" "mtalbert" {
  provider            = azurerm.connectivity
  name                = local.mtalbert_vpn_site_parameters.site_name
  resource_group_name = azurerm_resource_group.rg_nw_003.name
  location            = local.alz_config.azure_region_location
  virtual_wan_id      = module.virtual_wan_hub.resource_id
  address_cidrs       = local.mtalbert_vpn_site_parameters.address_cidrs
  tags                = local.common_tags

  link {
    name          = local.mtalbert_vpn_site_parameters.link_name
    ip_address    = local.mtalbert_vpn_site_parameters.vpn_public_ip
    speed_in_mbps = local.mtalbert_vpn_site_parameters.speed_in_mbps
    provider_name = local.mtalbert_vpn_site_parameters.provider_name
  }
}

resource "azurerm_vpn_gateway_connection" "mtalbert" {
  provider           = azurerm.connectivity
  name               = local.mtalbert_vpn_connection_parameters.conn_name
  vpn_gateway_id     = azurerm_vpn_gateway.platform_vpngw.id
  remote_vpn_site_id = azurerm_vpn_site.mtalbert.id

  vpn_link {
    name             = local.mtalbert_vpn_connection_parameters.vpn_link_name
    vpn_site_link_id = azurerm_vpn_site.mtalbert.link[0].id
    protocol         = local.mtalbert_vpn_connection_parameters.protocol
    shared_key       = data.azurerm_key_vault_secret.vpn_psk_mtalbert.value

    ipsec_policy {
      dh_group                 = local.mtalbert_vpn_connection_parameters.ipsec_policy.dh_group
      ike_encryption_algorithm = local.mtalbert_vpn_connection_parameters.ipsec_policy.ike_encryption_algorithm
      ike_integrity_algorithm  = local.mtalbert_vpn_connection_parameters.ipsec_policy.ike_integrity_algorithm
      encryption_algorithm     = local.mtalbert_vpn_connection_parameters.ipsec_policy.encryption_algorithm
      integrity_algorithm      = local.mtalbert_vpn_connection_parameters.ipsec_policy.integrity_algorithm
      pfs_group                = local.mtalbert_vpn_connection_parameters.ipsec_policy.pfs_group
      sa_data_size_kb          = local.mtalbert_vpn_connection_parameters.ipsec_policy.sa_data_size_kb
      sa_lifetime_sec          = local.mtalbert_vpn_connection_parameters.ipsec_policy.sa_lifetime_sec
    }
  }
}