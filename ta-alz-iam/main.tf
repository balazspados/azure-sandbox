# One role-assignable Entra ID group + one RBAC role assignment per row of
# var.rbac_group_definitions (see variables.tf for the table itself, locals.tf
# for how each row's scope is resolved).
module "rbac_groups" {
  source   = "./modules/iam-rbac-group"
  for_each = local.rbac_groups

  group_name        = each.value.group_name
  builtin_rbac_role = each.value.builtin_rbac_role
  scope_key         = each.value.scope_key
  scope_id          = each.value.scope_id
  membership_type   = each.value.membership_type
  assignment        = each.value.assignment
}
