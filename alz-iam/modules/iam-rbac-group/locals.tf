locals {
  owners = length(var.owners) > 0 ? var.owners : [data.azuread_client_config.current.object_id]

  default_description = "Privileged Access Group — grants ${var.builtin_rbac_role} at scope ${coalesce(var.scope_key, var.scope_id)} (${var.assignment == "Eligible" ? "PIM eligible, activation required" : "permanent, standing access"}). Managed by Terraform (alz-iam)."
}