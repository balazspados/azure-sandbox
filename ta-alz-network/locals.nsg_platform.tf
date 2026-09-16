locals {
  ### nsg_nw_prd_ae_001 rules
  nsg_nw_001 = {
    nsg_name = "${local.alz_config.org_id}-nsg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-001"
    rules = {
      "rule100" = {
        name                       = "Allow-Dns-From-VNet"
        description                = "Allow DNS from vNet"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 100
        protocol                   = "*"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_ranges    = ["53"]
      }
    }
  }


  nsg_nw_004_bastion = {
    nsg_name = "${local.alz_config.org_id}-nsg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-004"
    rules = {
      "rule100" = {
        name                       = "Allow-Https-Inbound"
        description                = "Allow-Https-Inbound"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 100
        protocol                   = "Tcp"
        source_address_prefix      = "Internet"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_ranges    = ["443"]
      }
      "rule200" = {
        name                       = "Allow-Gateway-Manager-Inbound"
        description                = "Allow-Gateway-Manager-Inbound"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 200
        protocol                   = "Tcp"
        source_address_prefix      = "GatewayManager"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_ranges    = ["443"]
      }
      "rule300" = {
        name                       = "Allow-Bastion-Host-Communication"
        description                = "Allow-Bastion-Host-Communication"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 300
        protocol                   = "*"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
        destination_address_prefix = "VirtualNetwork"
        destination_port_ranges    = ["8080", "5701"]
      }
      "rule400" = {
        name                       = "Allow-Azure-LoadBalancer-Inbound"
        description                = "Allow-Azure-LoadBalancer-Inbound"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 400
        protocol                   = "Tcp"
        source_address_prefix      = "AzureLoadBalancer"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_ranges    = ["443"]
      }
      "rule500" = {
        name                       = "Allow-Ssh-Rdp-Outbound"
        description                = "Allow-Ssh-Rdp-Outbound"
        access                     = "Allow"
        direction                  = "Outbound"
        priority                   = 500
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "VirtualNetwork"
        destination_port_ranges    = ["22", "3389"]
      }
      "rule600" = {
        name                       = "Allow-Azure-Cloud-Outbound"
        description                = "Allow-Azure-Cloud-Outbound"
        access                     = "Allow"
        direction                  = "Outbound"
        priority                   = 600
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "AzureCloud"
        destination_port_ranges    = ["443"]
      }
      "rule700" = {
        name                       = "Allow-Bastion-Communication"
        description                = "Allow-Bastion-Communication"
        access                     = "Allow"
        direction                  = "Outbound"
        priority                   = 700
        protocol                   = "*"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
        destination_address_prefix = "VirtualNetwork"
        destination_port_ranges    = ["8080", "5701"]
      }
      "rule800" = {
        name                       = "Allow-Http-Outbound"
        description                = "Allow-Http-Outbound"
        access                     = "Allow"
        direction                  = "Outbound"
        priority                   = 800
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
        destination_address_prefix = "Internet"
        destination_port_ranges    = ["80"]
      }
    }
  }


  nsg_nw_005 = {
    nsg_name = "${local.alz_config.org_id}-nsg-nw-${local.alz_config.environment}-${local.alz_config.azure_region_location_short}-005"
    rules = {
      "rule100" = {
        name                       = "Allow-VNet-Https-Inbound"
        description                = "Allow DNS from vNet"
        access                     = "Allow"
        direction                  = "Inbound"
        priority                   = 100
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_ranges    = ["443"]
      }
    }
  }


}