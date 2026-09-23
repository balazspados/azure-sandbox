# ta-alz-iam

Terraform root module that deploys the platform's privileged-access model: one role-assignable
Microsoft Entra ID security group plus one Azure RBAC role assignment per row of a table-driven
definition (`var.rbac_group_definitions` in `terraform.tfvars`). Each row is expanded by
`module.rbac_groups` (`main.tf`) into a call of the reusable `ta-res-iam-rbac-group` module,
which creates the group and either a standing (`Permanent`) or PIM-eligible (`Eligible`) role
assignment at the scope given by the row.

This stack depends on `ta-alz-core` having applied first: `remote_state.tf` reads the `alz`
workspace's outputs (`management_group_resource_ids`, `alz_config`) to resolve `scope_key` values
like `root`, `platform`, `connectivity`, `management`, `identity`, `security` into real management
group / subscription IDs (`locals.tf`'s `scope_id_by_ref` map).

## Prerequisites

- **HCP Terraform workspace `alz-iam`** (org `padi-org`, `backend.tf`), with OIDC auth configured
  for the `azurerm`/`azuread` providers against the management subscription and tenant
  (`terraform.tf`).
- **Entra ID Premium licensing — only required once `Eligible` rows are enabled** (see next
  section). Not required for the current all-`Permanent` configuration.

## Assignment model: `Permanent` vs `Eligible`, and today's state

Every row in `terraform.tfvars` currently sets `assignment = "Permanent"` — a standing,
always-on RBAC role assignment (`azurerm_role_assignment`, in the `ta-res-iam-rbac-group`
module's `main.tf` — see Module versions below). For the ten `-owner`/`-contributor` rows (root,
core-networking, management, Identity, security — each at Owner and Contributor), the intended
stricter alternative is already sketched in the file as a **commented-out** line directly above
the active one, e.g.:

```hcl
# assignment        = "Eligible"
assignment        = "Permanent"
```

`Eligible` switches that row to a PIM-eligible assignment
(`azurerm_pim_eligible_role_assignment`, same module) — members must activate the role through
Privileged Identity Management rather than holding it standing. The `-reader` rows and the
`azure-identity-backup-operator` /
`azure-platform-kv-*` rows have no such commented alternative; they're only ever `Permanent` in
this table today.

**Why it's `Permanent` everywhere right now:** a PIM-eligible assignment requires a
role-assignable Entra ID group (`assignable_to_role = true` in the module, wired from
`var.assignment == "Eligible"`), which in turn requires **Microsoft Entra ID Premium P1** as a
floor, and **P2** specifically for PIM for Groups (i.e. any row actually using `Eligible`) — see
`alz-bootstrap/root-binding/bootstrap-oidc.md`'s "Entra ID Premium licensing" section for the full
three-part breakdown (Azure RBAC, the Graph `RoleManagement.ReadWrite.Directory` permission, and
tenant licensing are three independent requirements that each fail with a different 403). That
licensing isn't in place yet for this tenant, so every row stays `Permanent` for now.

## Action required once the AAD Premium license is available in prod

Once Entra ID Premium P2 licensing has been procured for the production tenant, uncomment
`assignment = "Eligible"` (and remove/comment out the `assignment = "Permanent"` line above it) for
the `-owner` and `-contributor` rows in `terraform.tfvars` — this is the intended least-privilege
end state for those higher-privileged roles, with the `-reader` rows staying `Permanent`.

**Before doing that, be aware of the consequence:** `assignable_to_role` is a `ForceNew` attribute
on `azuread_group` (Microsoft Graph does not allow changing whether an existing group is
role-assignable). Flipping a row from `Permanent` to `Eligible` will force Terraform to **destroy
and recreate the Entra ID group**, not just swap the role assignment — the group gets a new object
ID, and any existing membership or external references to the old group are lost and must be
re-added after the recreate. Plan this as a deliberate cutover (per group, or a change window for
all ten rows at once), not a routine `tfvars` edit.

## Module versions

As of 2026-09-23:

| Module | Registry | Pinned version | Latest available (2026-09-23) |
|---|---|---|---|
| `ta-res-iam-rbac-group/azurerm` | Private (`app.terraform.io/padi-org`) | 1.0.0 | 1.0.0 (only release published) |

**Pre-production TODO:** `app.terraform.io/padi-org` is a dev-only private registry — the
production private registry hasn't been decided yet. `ta-res-iam-rbac-group`'s `source` in
`main.tf` will need to point at that production registry before this stack is applied to
production.

## Configuration

`terraform.tfvars`'s `rbac_group_definitions` is the single source of truth — adding a new
privileged-access group means adding a new entry there; no other `.tf` file needs to change
(`variables.tf`'s description). Each row:

| Field | Meaning |
|---|---|
| `group_name` | Entra ID group display name, e.g. `azure-root-owner` |
| `builtin_rbac_role` | Azure built-in role to assign, e.g. `Owner`, `Contributor`, `Reader` |
| `scope_type` | `"management_group"` or `"subscription"` |
| `scope_key` | Looked up against the `alz` workspace's `management_group_resource_ids` output (for `management_group`) or its subscription-id outputs (for `subscription`) — see `locals.tf`'s `scope_id_by_ref` |
| `membership_type` | Only `"Assigned"` is supported (Entra ID disallows dynamic membership on role-assignable groups) |
| `assignment` | `"Permanent"` (standing) or `"Eligible"` (PIM activation required) |

`variables.tf` enforces `scope_type ∈ {management_group, subscription}`, `assignment ∈ {Eligible,
Permanent}`, and unique `group_name` values via `validation` blocks — a bad row fails
`terraform plan` before anything is created.

**Planned convention change:** the RBAC group/role table should be defined in `locals.tf`
instead of `terraform.tfvars` — the current `rbac_group_definitions` variable, set in
`terraform.tfvars`, should move to a `locals` value instead (with `main.tf`'s `for_each` and
`locals.tf`'s `rbac_groups` updated to reference the local rather than `var.rbac_group_definitions`,
and `variables.tf`'s declaration/validation either dropped or reworked as a local's `validation`
via a `check` block, since plain `locals` don't support inline `validation`). This isn't done yet
in this codebase — noting it here as the intended direction.

## Deploying

Same VCS-driven flow as `ta-alz-core`: push to the tracked branch, review the HCP Terraform plan
(workspace `alz-iam`), approve the apply. Run this only after `ta-alz-core` has applied
successfully, since its remote-state outputs are the source of every scope ID used here.

## Outputs

- `group_object_ids` — map of `group_name` → Entra ID object ID, for every group defined.
- `role_assignment_ids` — map of `group_name` → RBAC role assignment ID (permanent or PIM-eligible,
  whichever applies).

