# Reusable building block: one role-assignable Microsoft Entra ID security group,
# statically membered ("Assigned"), plus one Azure RBAC role assignment at a given
# scope — either a standing ("Permanent") assignment or a PIM ("Eligible") one that
# requires activation.
#
# Called once per row of the RBAC deployment table from the ALZ IAM design, via
# the root module's for_each over `var.rbac_group_definitions`.

data "azuread_client_config" "current" {}

# Role-assignable security group. "assignable_to_role = true" is what lets this
# group be targeted by an Azure RBAC role assignment (and is the Entra ID
# requirement for a group to be used as a Privileged Access Group under PIM).
resource "azuread_group" "this" {
  display_name       = var.group_name
  description        = coalesce(var.description, local.default_description)
  security_enabled   = true
  assignable_to_role = true

  # "Assigned" membership type = static membership, i.e. no dynamic_membership
  # block. Entra ID does not allow dynamic membership on role-assignable groups,
  # which is why var.membership_type only accepts "Assigned" (enforced above).
  owners = local.owners

  lifecycle {
    # Membership itself (who's actually in the group) is intentionally left out
    # of this module — the platform team manages group membership operationally
    # (or via a separate members module), not the group definition / role grant.
    ignore_changes = [members]
  }
}

# Standing, always-on RBAC assignment — used for rows marked "Permanent" in the
# RBAC deployment table (e.g. azure-root-reader).
resource "azurerm_role_assignment" "permanent" {
  count = var.assignment == "Permanent" ? 1 : 0

  scope                = var.scope_id
  role_definition_name = var.builtin_rbac_role
  principal_id         = azuread_group.this.object_id
}

# PIM eligible RBAC assignment — used for rows marked "Eligible". Members of the
# group must activate the role through PIM before it takes effect; this resource
# only grants eligibility, not standing access. Requires Entra ID P2 / PIM for
# Groups on the tenant.
resource "azurerm_pim_eligible_role_assignment" "eligible" {
  count = var.assignment == "Eligible" ? 1 : 0

  scope              = var.scope_id
  role_definition_id = "${var.scope_id}${data.azurerm_role_definition.this[0].id}"
  principal_id       = azuread_group.this.object_id

  schedule {
    start_date_time = null

    dynamic "expiration" {
      for_each = var.eligible_assignment_duration_days == null ? [] : [1]
      content {
        duration_days = var.eligible_assignment_duration_days
      }
    }
  }

  justification = var.eligible_assignment_justification_required ? "Provisioned by Terraform (alz-iam) as a standing PIM-eligible platform role." : null
}

# Built-in role definitions are tenant-wide, so this is looked up by name only
# (no scope) — the unscoped ID returned here gets prefixed with var.scope_id
# above to build the fully-qualified role_definition_id that
# azurerm_pim_eligible_role_assignment expects. (azurerm_role_assignment, used
# for "Permanent" rows, is simpler and accepts role_definition_name directly.)
data "azurerm_role_definition" "this" {
  count = var.assignment == "Eligible" ? 1 : 0

  name = var.builtin_rbac_role
}
