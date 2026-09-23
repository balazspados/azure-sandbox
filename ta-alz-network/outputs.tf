output "private_dns_resolver_inbound_ip" {
  description = "Private IP of the DNS Private Resolver's inbound endpoint. Point any new spoke vNet's dns_servers at this so its VMs/private endpoints can resolve privatelink.* names."
  value       = module.private_dns_resolver.inbound_endpoint_ips["inbound"]
}

output "private_endpoints_subnet" {
  value = {
    id             = module.platform_vnet_005.subnets.private_endpoints.resource_id
    resource_group = azurerm_resource_group.rg_nw_005.name
  }
}

output "rg_identity" {
  value = {
    name = azurerm_resource_group.rg_identity_001.name
  }
}

output "private_dns_zone_resource_ids" {
  value = module.private_dns_zones.private_dns_zone_resource_ids
}

output "bastion_parameters" {
  description = "FQDN of the Azure Bastion host"
  value = {
    fqdn = module.platform_bastionhost.dns_name
  }
}

