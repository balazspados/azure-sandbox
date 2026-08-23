variable "rbac_group_definitions" {
  description = <<-EOT
    Table-driven RBAC deployment definitions — one entry per row of the RBAC
    Deployment table in the ALZ IAM design. Add a new group by adding a new
    entry here; no other .tf file needs to change. scope_key must match a key
    present in the alz workspace's management_group_resource_ids output (when
    scope_type = "management_group") or one of its subscription id outputs
    (when scope_type = "subscription") — see locals.tf.
  EOT

  type = list(object({
    group_name        = string
    builtin_rbac_role = string
    scope_type        = string # "management_group" OR "subscription"
    scope_key         = string
    membership_type   = string # "Assigned" (only supported value)
    group_type        = string # "Security" (only role-assignable-eligible value)
    assignment        = string # "Eligible" OR "Permanent"
  }))

  validation {
    condition = alltrue([
      for g in var.rbac_group_definitions : contains(["management_group", "subscription"], g.scope_type)
    ])
    error_message = "scope_type must be either \"management_group\" or \"subscription\"."
  }

  validation {
    condition = alltrue([
      for g in var.rbac_group_definitions : contains(["Eligible", "Permanent"], g.assignment)
    ])
    error_message = "assignment must be either \"Eligible\" or \"Permanent\"."
  }

  validation {
    condition     = length(distinct([for g in var.rbac_group_definitions : g.group_name])) == length(var.rbac_group_definitions)
    error_message = "group_name values must be unique across rbac_group_definitions."
  }
}
