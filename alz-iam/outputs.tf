output "avm_telemery_enable" {
  value = local.avm_telemery_enable
}

output "group_object_ids" {
  description = "Map of group_name => Entra ID object ID, for every group defined in var.rbac_group_definitions."
  value       = { for k, m in module.rbac_groups : k => m.group_object_id }
}

output "role_assignment_ids" {
  description = "Map of group_name => RBAC role assignment ID (permanent or PIM-eligible, whichever applies)."
  value       = { for k, m in module.rbac_groups : k => m.role_assignment_id }
}
