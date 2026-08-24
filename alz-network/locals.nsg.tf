locals {
  platform_dnsin_nsg_rules = {
    "rule100" = {
      name                       = "AllowDnsFromVNet"
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["53"]
      direction                  = "Inbound"
      priority                   = 100
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
    }
  }
  platform_dnsout_nsg_rules = {
    "rule100" = {
      name                       = "AllowDnsToVNet"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["53"]
      direction                  = "Outbound"
      priority                   = 100
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
    }
  }
}