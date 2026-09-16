locals {


  # Identity subscription vNet and subnets
  identity_vnet_001 = {
    name                = "${local.alz_config.org_id}-vnet-idn-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    address_space       = ["10.225.32.0/24"]
    hub_connection_name = "${local.alz_config.org_id}-vhubconn-idnnw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"

    subnets = {
      snet_identity = {
        name             = "snet-identity"
        address_prefixes = ["10.225.32.0/27"]
      }
      snet_paw = {
        name             = "snet-paw"
        address_prefixes = ["10.225.32.32/27"]
      }
    }
  }
}