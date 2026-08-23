output "connectivity_subscription_id" {
  description = "Connectivity subscription ID"
  value       = var.connectivity_subscription.id
}

output "management_subscription_id" {
  description = "Management subscription ID"
  value       = var.management_subscription.id
}

output "identity_subscription_id" {
  description = "Identity subscription ID"
  value       = var.identity_subscription.id
}

output "security_subscription_id" {
  description = "Security subscription ID"
  value       = var.security_subscription.id
}

output "azure_tenant_id" {
  description = "Azure tenant ID"
  value       = var.azure_tenant.id
}

output "management_group_resource_ids" {
  description = "Map of management group id (e.g. \"alz\", \"platform\", \"connectivity\", \"identity\") to its fully-qualified Azure resource ID, as created by the alz_architecture module."
  value       = module.alz_architecture.management_group_resource_ids
}