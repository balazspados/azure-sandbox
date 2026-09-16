### vNet_003 NSG rules
locals {
  nsg_nw_vnet_idn_001 = {
    nsg_name = "${local.alz_config.org_id}-nsg-idn-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    rules = {
      "rule100" = {
        name        = "Allow-AD-Client-Services-TCP"
        description = "Domain member access to AD. Domain Trust from onprem AD from MIT/Unitec"
        access      = "Allow"
        direction   = "Inbound"
        priority    = 100
        protocol    = "Tcp"
        source_address_prefixes = concat(
          local.identity_vnet_001.subnets.snet_identity.address_prefixes,
          local.identity_vnet_001.subnets.snet_paw.address_prefixes,
          local.otara_vpn_site_parameters.address_cidrs,
          local.mtalbert_vpn_site_parameters.address_cidrs
        )
        source_port_range          = "*"
        destination_address_prefix = local.identity_vnet_001.subnets.snet_identity.address_prefixes[0]
        destination_port_ranges    = ["53", "88", "135", "137-139", "389", "445", "636", "49152-65535"]
      }
      "rule101" = {
        name        = "Allow-AD-Client-Services-UDP"
        description = "Domain member access to AD. Domain Trust from onprem AD from MIT/Unitec"
        access      = "Allow"
        direction   = "Inbound"
        priority    = 101
        protocol    = "Udp"
        source_address_prefixes = concat(
          local.identity_vnet_001.subnets.snet_identity.address_prefixes,
          local.identity_vnet_001.subnets.snet_paw.address_prefixes,
          local.otara_vpn_site_parameters.address_cidrs,
          local.mtalbert_vpn_site_parameters.address_cidrs
        )
        source_port_range          = "*"
        destination_address_prefix = local.identity_vnet_001.subnets.snet_identity.address_prefixes[0]
        destination_port_ranges    = ["53", "88", "135", "137-139", "389", "445", "636", "49152-65535"]
      }
      "rule110" = {
        name        = "Allow-AD-Replication-Infra"
        description = "Global Catalog lookups, SSL- encapsulated LDAP, AD Web Services (PowerShell), and inter-site replication"
        access      = "Allow"
        direction   = "Inbound"
        priority    = 110
        protocol    = "Tcp"
        source_address_prefixes = concat(
          local.identity_vnet_001.subnets.snet_identity.address_prefixes,
          local.identity_vnet_001.subnets.snet_paw.address_prefixes,
          local.otara_vpn_site_parameters.address_cidrs,
          local.mtalbert_vpn_site_parameters.address_cidrs
        )
        source_port_range          = "*"
        destination_address_prefix = local.identity_vnet_001.subnets.snet_identity.address_prefixes[0]
        destination_port_ranges    = ["636", "3268", "3269", "9389"]
      }
      "rule120" = {
        name                       = "Allow-outbound_resolver_DNS"
        description                = "DNS Resolution"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 120
        protocol                   = "Udp"
        source_address_prefixes    = local.platform_vnet_001.subnets.dns_resolver_outbound.address_prefixes
        source_port_range          = "*"
        destination_address_prefix = local.identity_vnet_001.subnets.snet_identity.address_prefixes[0]
        destination_port_ranges    = ["53"]
      }
      "rule130" = {
        name                    = "Allow-RDP"
        description             = "Allow RDP to the DCs from Bastion only"
        access                  = "Allow"
        direction               = "Inbound"
        priority                = 130
        protocol                = "Tcp"
        source_address_prefixes = local.platform_vnet_001.subnets.azure_bastion.address_prefixes
        source_port_range       = "*"
        destination_address_prefixes = [
          local.identity_vnet_001.subnets.snet_identity.address_prefixes[0],
          local.identity_vnet_001.subnets.snet_paw.address_prefixes[0]]
        

        destination_port_ranges = ["3389"]
      }
      "rule4096" = {
        name                       = "Block-All-Inbound"
        description                = "Override Azure default rules to block all inbound traffic"
        access                     = "Deny"
        direction                  = "Inbound"
        priority                   = 4096
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_range    = "*"
      }
    }
  }


}
