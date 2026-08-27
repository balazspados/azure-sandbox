locals {
  ### nsg_nw_prd_ae_001 rules
  nsg_nw_prd_ae_001_rules = {
    "rule100" = {
      name                       = "AllowDnsFromVNet"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["53"]
      direction                  = "Inbound"
      priority                   = 100
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
    }
  }

  nsg_nw_prd_ae_002_rules = {
    "rule100" = {
      name                       = "AllowVNetHttpsInbound"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["443"]
      direction                  = "Inbound"
      priority                   = 100
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
    }
    # Add per-service rules as non-443 private endpoints land in this subnet, e.g.:
    # "rule200" = {
    #   name                       = "AllowVNetSqlInbound"
    #   access                     = "Allow"
    #   destination_address_prefix = "*"
    #   destination_port_ranges    = ["1433"]
    #   direction                  = "Inbound"
    #   priority                   = 200
    #   protocol                   = "Tcp"
    #   source_address_prefix      = "VirtualNetwork"
    #   source_port_range          = "*"
    # }
  }

  nsg_nw_bastion_rules = {
    "rule100" = {
      name                       = "AllowHttpsInbound"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["443"]
      direction                  = "Inbound"
      priority                   = 100
      protocol                   = "Tcp"
      source_address_prefix      = "Internet"
      source_port_range          = "*"
    }
    "rule200" = {
      name                       = "AllowGatewayManagerInbound"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["443"]
      direction                  = "Inbound"
      priority                   = 200
      protocol                   = "Tcp"
      source_address_prefix      = "GatewayManager"
      source_port_range          = "*"
    }
    "rule300" = {
      name                       = "AllowBastionHostCommunication"
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["8080", "5701"]
      direction                  = "Inbound"
      priority                   = 300
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
    }
    "rule400" = {
      name                       = "AllowAzureLoadBalancerInbound"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["443"]
      direction                  = "Inbound"
      priority                   = 400
      protocol                   = "Tcp"
      source_address_prefix      = "AzureLoadBalancer"
      source_port_range          = "*"
    }
    "rule500" = {
      name                       = "AllowSshRdpOutbound"
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["22", "3389"]
      direction                  = "Outbound"
      priority                   = 500
      protocol                   = "*"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
    "rule600" = {
      name                       = "AllowAzureCloudOutbound"
      access                     = "Allow"
      destination_address_prefix = "AzureCloud"
      destination_port_ranges    = ["443"]
      direction                  = "Outbound"
      priority                   = 600
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
    "rule700" = {
      name                       = "AllowBastionCommunication"
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["8080", "5701"]
      direction                  = "Outbound"
      priority                   = 700
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
    }
    "rule800" = {
      name                       = "AllowHttpOutbound"
      access                     = "Allow"
      destination_address_prefix = "Internet"
      destination_port_ranges    = ["80"]
      direction                  = "Outbound"
      priority                   = 800
      protocol                   = "*"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }



}