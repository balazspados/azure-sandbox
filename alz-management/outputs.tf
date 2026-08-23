output "resource_group_management_terraform" {
  description = "name of terraform management resource group"
  value       = azurerm_resource_group.management.name
}

output "org_prefix" {
  description = "Organization prefix"
  value       = var.org_prefix
}

output "azure_region_location_short" {
  value = var.azure_region.location_short
}

output "azure_region_location" {
  value = var.azure_region.location
}

output "platform_costcenter" {
  description = "Platform costcenter"
  value       = var.platform_costcenter
}

output "environment" {
  description = "Platform environment name"
  value       = var.environment
}

output "avm_telemery_enable" {
  description = "AVM telemetry status: false - disabled; true - enabled"
  value       = var.enable_telemetry
}
