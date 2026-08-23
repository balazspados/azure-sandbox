variable "group_name" {
  description = "Microsoft Entra ID group display name (e.g. \"azure-root-owner\")."
  type        = string
}

variable "description" {
  description = "Group description shown in Entra ID. Defaults to a generated description if not set."
  type        = string
  default     = null
}

variable "builtin_rbac_role" {
  description = "Azure built-in RBAC role name to assign to this group (e.g. \"Owner\", \"Contributor\", \"Reader\")."
  type        = string
}

variable "scope_id" {
  description = "Fully-qualified Azure scope ID the role is assigned at — a management group ID (/providers/Microsoft.Management/managementGroups/<name>) or a subscription ID (/subscriptions/<guid>)."
  type        = string
}

variable "scope_key" {
  description = "Human-readable scope key (e.g. \"root\", \"connectivity\") used only in the group's auto-generated description. Not used to resolve the actual role assignment scope — that comes from var.scope_id. Defaults to showing scope_id if not set."
  type        = string
  default     = null
}

variable "membership_type" {
  description = "How members are added to the group. Only \"Assigned\" (static membership) is currently supported by this module."
  type        = string
  default     = "Assigned"

  validation {
    condition     = var.membership_type == "Assigned"
    error_message = "Only statically-assigned (\"Assigned\") membership is supported for role-assignable PIM groups. Dynamic membership rules are not supported on groups with assignable_to_role = true by Microsoft Entra ID."
  }
}

variable "assignment" {
  description = "Whether the RBAC role assignment to this group is \"Eligible\" (requires PIM activation) or \"Permanent\" (standing, always-on access)."
  type        = string

  validation {
    condition     = contains(["Eligible", "Permanent"], var.assignment)
    error_message = "assignment must be either \"Eligible\" or \"Permanent\"."
  }
}

variable "owners" {
  description = "Object IDs of the initial owners of the role-assignable group. Microsoft Entra ID requires at least one owner on a group with assignable_to_role = true. Defaults to the identity running Terraform."
  type        = list(string)
  default     = []
}

variable "eligible_assignment_justification_required" {
  description = "Whether activating this eligible role assignment requires the requester to supply a justification. Ignored when assignment = \"Permanent\"."
  type        = bool
  default     = true
}

variable "eligible_assignment_duration_days" {
  description = "For an \"Eligible\" assignment, how many days the eligibility itself lasts before it must be renewed. Set to null for a non-expiring (permanent) eligibility, which is the recommended default for standing platform-admin groups. Ignored when assignment = \"Permanent\"."
  type        = number
  default     = null
}
