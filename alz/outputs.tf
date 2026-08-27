output "management_group_resource_ids" {
  description = "Map of management group id (e.g. \"alz\", \"platform\", \"connectivity\", \"identity\") to its fully-qualified Azure resource ID, as created by the alz_architecture module."
  value       = module.alz_architecture.management_group_resource_ids
}

