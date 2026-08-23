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

  #Assemble resource group name to be created

  vwan_parameters = {
    rg_name                        = "${local.org_prefix}-rg-nw-${local.environment}-${local.azure_region_location_short}-001"
    name                           = "${local.org_prefix}-vwan-nw-${local.environment}-${local.azure_region_location_short}-001"
    type                           = "Standard"
    allow_branch_to_branch_traffic = true
  }
  vwan_hub_parameters = {
    name                   = "${local.org_prefix}-vhub-nw-${local.environment}-${local.azure_region_location_short}-001"
    address_prefix         = "10.225.0.0/22"
    hub_routing_preference = "VpnGateway" #Options: "ExpressRoute" or "VpnGateway"
  }
  vpn_gateway_paramaters = {
    rg_name = "${local.org_prefix}-rg-nw-${local.environment}-${local.azure_region_location_short}-003"
    name    = "${local.org_prefix}-vpn-nw-${local.environment}-${local.azure_region_location_short}-001"
  }

  vpn_site_parameters = {
    # name      = "${local.org_prefix}-mitmanvpnlink-nw-${local.environment}-${local.azure_region_location_short}-001"
    link_name = "${local.org_prefix}-mitmanvpnlink-nw-${local.environment}-${local.azure_region_location_short}-001"
    remote_ip = null # TBA - on-prem public IP not yet confirmed
  }

  vpn_connection_parameters = {
    name = "${local.org_prefix}-vpnconn-mitman-${local.environment}-${local.azure_region_location_short}-001"
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

  expressroute_paramaters = {
    rg_name = "${local.org_prefix}-rg-nw-${local.environment}-${local.azure_region_location_short}-002"
    name    = "${local.org_prefix}-er-nw-${local.environment}-${local.azure_region_location_short}-001"
  }


  private_pdnsz_zone = {
    rg_name = "${local.org_prefix}-rg-pdnsz-${local.environment}-${local.azure_region_location_short}-001"
  }

  private_dns_resolver = {
    rg_name = "${local.org_prefix}-rg-dns-${local.environment}-${local.azure_region_location_short}-001"
  }
}