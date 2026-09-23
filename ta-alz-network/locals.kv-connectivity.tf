locals {
  key_vault_connectivity_parameters = {
    kv_name = "${local.alz_config.org_id}kvcon${local.alz_config.environment}${local.alz_config.azure_region_location_short}001"
    sku     = "standard" # Possible values are "standard" and "premium"
    # public_network_access_enabled = false      # Default: "true"
    public_network_access_enabled = true  # TEMPORARY: revert to false once vWAN/vHub peering exists (no network path to the private endpoint yet)
    purge_protection_enabled      = true  # Default: "true"
    soft_delete_retention_days    = 7     # Value can be between 7 and 90 (the default) days.
    enabled_for_disk_encryption   = false # Default: false  Description: Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.

    # private_endpoint_name                        = "pep-${local.alz_config.org_id}-kv-connectivity-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    # private_endpoints_subnet_id                  = data.terraform_remote_state.alz_network.outputs.private_endpoints_subnet.id
    # private_endpoints_subnet_resource_group_name = data.terraform_remote_state.alz_network.outputs.private_endpoints_subnet.resource_group
    # private_dns_zone_id                          = data.terraform_remote_state.alz_network.outputs.private_dns_zone_resource_ids["azure_key_vault"]

    vpn_psk_secret_name_otara    = "vpn-psk-otara"
    vpn_psk_secret_name_mtalbert = "vpn-psk-mtalbert"
    vpn_psk_secret_version       = 1 # leave unchanged to preserve manual edits


  }
}