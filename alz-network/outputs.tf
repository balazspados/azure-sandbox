output "private_dns_resolver_inbound_ip" {
  description = "Private IP of the DNS Private Resolver's inbound endpoint. Point any new spoke vNet's dns_servers at this so its VMs/private endpoints can resolve privatelink.* names."
  value       = module.private_dns_resolver.inbound_endpoint_ips["inbound"]
}

output "bastion_fqdn" {
  description = "FQDN of the Azure Bastion host"
  value       = module.platform_bastionhost.dns_name
}