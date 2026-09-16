output "group_object_id" {
  description = "Object ID of the Entra ID group."
  value       = azuread_group.this.object_id
}

output "group_display_name" {
  description = "Display name of the Entra ID group."
  value       = azuread_group.this.display_name
}

output "role_assignment_id" {
  description = "ID of the RBAC role assignment (permanent or PIM-eligible, whichever applies) granted to the group."
  value       = var.assignment == "Permanent" ? azurerm_role_assignment.permanent[0].id : azurerm_pim_eligible_role_assignment.eligible[0].id
}
