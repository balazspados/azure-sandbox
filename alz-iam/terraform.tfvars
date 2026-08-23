rbac_group_definitions = [
  # --- Tier 0: Tenancy level (root management group) ---
  {
    group_name        = "azure-root-owner"
    builtin_rbac_role = "Owner"
    scope_type        = "management_group"
    scope_key         = "root"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Eligible"
  },
  {
    group_name        = "azure-root-contributor"
    builtin_rbac_role = "Contributor"
    scope_type        = "management_group"
    scope_key         = "root"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Eligible"
  },
  {
    group_name        = "azure-root-reader"
    builtin_rbac_role = "Reader"
    scope_type        = "management_group"
    scope_key         = "root"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Permanent"
  },

  # --- Tier 1: Subscription level (Core Networking / connectivity) ---
  {
    group_name        = "azure-core-networking-owner"
    builtin_rbac_role = "Owner"
    scope_type        = "subscription"
    scope_key         = "connectivity"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Eligible"
  },
  {
    group_name        = "azure-core-networking-contributor"
    builtin_rbac_role = "Contributor"
    scope_type        = "subscription"
    scope_key         = "connectivity"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Eligible"
  },
  {
    group_name        = "azure-core-networking-reader"
    builtin_rbac_role = "Reader"
    scope_type        = "subscription"
    scope_key         = "connectivity"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Permanent"
  },
  {
    group_name        = "azure-management-owner"
    builtin_rbac_role = "Owner"
    scope_type        = "subscription"
    scope_key         = "management"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Eligible"
  },
  {
    group_name        = "azure-management-contributor"
    builtin_rbac_role = "Contributor"
    scope_type        = "subscription"
    scope_key         = "management"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Eligible"
  },
  {
    group_name        = "azure-management-reader"
    builtin_rbac_role = "Reader"
    scope_type        = "subscription"
    scope_key         = "management"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Permanent"
  },
  {
    group_name        = "azure-Identity-owner"
    builtin_rbac_role = "Owner"
    scope_type        = "subscription"
    scope_key         = "identity"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Eligible"
  },
  {
    group_name        = "azure-Identity-contributor"
    builtin_rbac_role = "Contributor"
    scope_type        = "subscription"
    scope_key         = "identity"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Eligible"
  },
  {
    group_name        = "azure-Identity-reader"
    builtin_rbac_role = "Reader"
    scope_type        = "subscription"
    scope_key         = "identity"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Permanent"
  },
  {
    group_name        = "azure-security-owner"
    builtin_rbac_role = "Owner"
    scope_type        = "subscription"
    scope_key         = "security"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Eligible"
  },
  {
    group_name        = "azure-security-contributor"
    builtin_rbac_role = "Contributor"
    scope_type        = "subscription"
    scope_key         = "security"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Eligible"
  },
  {
    group_name        = "azure-security-reader"
    builtin_rbac_role = "Reader"
    scope_type        = "subscription"
    scope_key         = "security"
    membership_type   = "Assigned"
    group_type        = "Security"
    assignment        = "Permanent"
  },
]
