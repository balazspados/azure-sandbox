#!/usr/bin/env zsh
#
# bootstrap-hcp-oidc.sh
#
# One-time bootstrap: creates the Azure AD app registration, federated OIDC
# credentials, and an Owner role assignment at Tenant Root Group scope ("/")
# that HCP Terraform needs to authenticate to a brand-new Azure tenant via
# workload identity federation (no client secret, ever) and to build the
# entire ALZ management group hierarchy from there.
#
# This is deliberately a plain Azure CLI script, NOT Terraform. It is run
# once, by a human signed in via `az login` as a Global Administrator, before
# HCP Terraform has any way to reach Azure. Do not import these resources
# into Terraform state afterward — keep this identity out-of-band so no ALZ
# Terraform run can ever modify or delete its own trust relationship.
#
# Requires: Azure CLI >= 2.50 (for `az ad app federated-credential`).
# Run `az upgrade` first if that subcommand is missing.

set -euo pipefail

# ---------------------------------------------------------------------------
# 1. EDIT THESE before running
# ---------------------------------------------------------------------------

# App registration that represents HCP Terraform in this tenant.
APP_DISPLAY_NAME="mau-hcp-terraform-oidc"

# HCP Terraform (Terraform Cloud) issuer. Change only if you run a
# self-hosted Terraform Enterprise instance with its own hostname.
TFC_ISSUER="https://app.terraform.io"

# HCP Terraform org / project / workspace this identity should trust.
# If you run one workspace per environment, add extra WORKSPACE_NAMES
# entries and the script will create a plan+apply credential pair for each.
TFC_ORG="padi-org"
TFC_PROJECT="MAU-ALZ"
WORKSPACE_NAMES=("alz" "alz-management" "alz-network" "alz-iam")   # e.g. ("mau-alz-prd" "mau-alz-tst")

# RBAC role granted to the service principal at Tenant Root Group scope ("/").
# Owner (not just Contributor) because your ALZ Terraform will create the
# Intermediate Root management group and its children itself, and will also
# assign RBAC roles during subscription vending / landing zone setup —
# both require rights beyond plain Contributor. This matches the ALZ
# accelerator's own documented requirement: "Owner on your chosen parent
# management group."
RBAC_ROLE="Owner"

# The subscription that already exists in the new tenant. Not moved
# anywhere by this script — your ALZ Terraform places it under whatever
# management group hierarchy it creates. Leave empty to auto-detect the
# current subscription from `az account show`; printed below purely as a
# reference value for the HCP Terraform workspace variables.
# INITIAL_SUBSCRIPTION_ID="8b7867e2-e2b3-468e-b0ee-68da980c2eee"

# ---------------------------------------------------------------------------
# 0. Preconditions
# ---------------------------------------------------------------------------

echo "==> Confirming signed-in identity and tenant"
az account show -o table
CALLER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

if [[ -z "$INITIAL_SUBSCRIPTION_ID" ]]; then
  INITIAL_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
fi

echo "Tenant ID:               $TENANT_ID"
echo "Signed-in user object ID: $CALLER_OBJECT_ID"
echo "Initial subscription ID:  $INITIAL_SUBSCRIPTION_ID"
# read -r -p "Proceed with these values? [y/N] " CONFIRM
# [[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

# ---------------------------------------------------------------------------
# 2. Elevate Global Admin to User Access Administrator at root scope ("/")
# ---------------------------------------------------------------------------
# A brand-new tenant's Global Admin has no Azure RBAC rights by default.
# This one-time action grants the caller User Access Administrator at "/".
# Safe to call even if already elevated (idempotent no-op / harmless error).

echo "==> Elevating access to manage all subscriptions and management groups"
az rest --method post \
  --url "https://management.azure.com/providers/Microsoft.Authorization/elevateAccess?api-version=2016-07-01" \
  || echo "  (already elevated, or elevation failed — continuing; verify manually if the next steps fail)"

# ---------------------------------------------------------------------------
# 3. Create the app registration + service principal
# ---------------------------------------------------------------------------

echo "==> Creating app registration: $APP_DISPLAY_NAME"
APP_ID=$(az ad app create --display-name "$APP_DISPLAY_NAME" --query appId -o tsv)
APP_OBJECT_ID=$(az ad app show --id "$APP_ID" --query id -o tsv)

echo "==> Creating service principal for app $APP_ID"
SP_OBJECT_ID=$(az ad sp create --id "$APP_ID" --query id -o tsv 2>/dev/null \
  || az ad sp show --id "$APP_ID" --query id -o tsv)

echo "App (client) ID:     $APP_ID"
echo "App object ID:       $APP_OBJECT_ID"
echo "Service principal ID: $SP_OBJECT_ID"

# ---------------------------------------------------------------------------
# 4. Create federated credentials (plan + apply) per workspace
# ---------------------------------------------------------------------------

for WORKSPACE_NAME in "${WORKSPACE_NAMES[@]}"; do
  for PHASE in plan apply; do
    CRED_NAME="hcp-tf-${WORKSPACE_NAME}-${PHASE}"
    SUBJECT="organization:${TFC_ORG}:project:${TFC_PROJECT}:workspace:${WORKSPACE_NAME}:run_phase:${PHASE}"

    echo "==> Creating federated credential: $CRED_NAME"
    echo "    subject: $SUBJECT"

    az ad app federated-credential create \
      --id "$APP_OBJECT_ID" \
      --parameters "$(cat <<JSON
{
  "name": "${CRED_NAME}",
  "issuer": "${TFC_ISSUER}",
  "subject": "${SUBJECT}",
  "description": "HCP Terraform ${PHASE} phase for workspace ${WORKSPACE_NAME}",
  "audiences": ["api://AzureADTokenExchange"]
}
JSON
)" || echo "  (credential may already exist — continuing)"
  done
done

# ---------------------------------------------------------------------------
# 5. Grant RBAC role at the Tenant Root Group scope ("/")
# ---------------------------------------------------------------------------
# This is the broad option we discussed: granting at true root scope means
# this identity holds standing rights over EVERY subscription and management
# group in the tenant, present and future, not just ones related to this ALZ.
# Deliberately chosen here (per ALZ accelerator's own default pattern) so
# your ALZ Terraform is free to create the Intermediate Root management
# group and everything below it itself, rather than treating an
# out-of-band anchor MG as a pre-existing parent.
#
# Use --assignee-object-id / --assignee-principal-type to avoid a Graph
# lookup on a service principal that may not have finished replicating yet.

ROOT_SCOPE="/"

echo "==> Assigning role '$RBAC_ROLE' to service principal at Tenant Root Group scope ($ROOT_SCOPE)"
for attempt in 1 2 3 4 5; do
  if az role assignment create \
      --assignee-object-id "$SP_OBJECT_ID" \
      --assignee-principal-type ServicePrincipal \
      --role "$RBAC_ROLE" \
      --scope "$ROOT_SCOPE"; then
    break
  fi
  echo "  Role assignment failed (attempt $attempt/5) — service principal may still be replicating, retrying in 15s..."
  sleep 15
done

# ---------------------------------------------------------------------------
# 5b. Grant Microsoft Graph permission to manage role-assignable groups
# ---------------------------------------------------------------------------
# Azure RBAC (granted above) and Entra ID directory/Graph permissions are
# separate privilege planes. Creating a role-assignable Entra ID group
# (assignable_to_role = true, used by alz-iam's PIM-eligible groups) is a
# Graph operation that Owner-at-"/" does not cover, no matter how broad.
# This grants the app-only equivalent of the Privileged Role Administrator
# directory role, scoped to exactly this one capability.

GRAPH_API_ID="00000003-0000-0000-c000-000000000000"          # Microsoft Graph
ROLE_MGMT_RW_DIRECTORY="9e3f62cf-ca93-4989-b6ce-bf83c28f9fe8" # RoleManagement.ReadWrite.Directory (app role)

echo "==> Granting Microsoft Graph application permission: RoleManagement.ReadWrite.Directory"
az ad app permission add \
  --id "$APP_ID" \
  --api "$GRAPH_API_ID" \
  --api-permissions "${ROLE_MGMT_RW_DIRECTORY}=Role"

echo "==> Admin-consenting the permission (requires Global Administrator / Privileged Role Administrator)"
az ad app permission admin-consent --id "$APP_ID"

# ---------------------------------------------------------------------------
# 5c. Check for Entra ID Premium licensing (separate from the grant above)
# ---------------------------------------------------------------------------
# The Graph permission granted in 5b lets the identity attempt to create
# role-assignable groups — but the tenant itself also needs Microsoft Entra
# ID Premium licensing for that operation to succeed at all. Without it,
# alz-iam's apply fails later with a different 403: "Only companies who have
# purchased AAD Premium may perform this operation." P1 is the floor for
# role-assignable groups; P2 is required if any row uses assignment =
# "Eligible" (PIM for Groups). This is a tenant licensing state — nothing
# this script or Terraform can grant — so this step only warns, it can't fix it.

echo "==> Checking tenant for Microsoft Entra ID Premium licensing"
AAD_PREMIUM_SKUS=$(az rest --method get \
  --url "https://graph.microsoft.com/v1.0/subscribedSkus" \
  --query "value[?contains(skuPartNumber, 'AAD_PREMIUM')].skuPartNumber" -o tsv 2>/dev/null || true)

if [[ -z "$AAD_PREMIUM_SKUS" ]]; then
  echo "  WARNING: no Microsoft Entra ID Premium (P1/P2) license detected in this tenant."
  echo "  Role-assignable groups (assignable_to_role = true, used by alz-iam) require at least P1;"
  echo "  PIM-eligible assignments (assignment = \"Eligible\") require P2. Enable a free trial at"
  echo "  entra.microsoft.com -> Billing -> Licenses -> All products -> Microsoft Entra ID P2 -> Try/Buy."
  echo "  Continuing bootstrap anyway — alz-iam's apply will fail until this is resolved."
else
  echo "  Found: $AAD_PREMIUM_SKUS"
fi

# ---------------------------------------------------------------------------
# 6. Summary — set these as HCP Terraform workspace environment variables
# ---------------------------------------------------------------------------

cat <<SUMMARY

============================================================
Bootstrap complete. Set these in the HCP Terraform workspace
(Variables -> Environment variables, not Terraform variables):

  TFC_AZURE_PROVIDER_AUTH = true
  TFC_AZURE_RUN_CLIENT_ID = ${APP_ID}
  ARM_SUBSCRIPTION_ID     = ${INITIAL_SUBSCRIPTION_ID}
  ARM_TENANT_ID           = ${TENANT_ID}

Scope:        Tenant Root Group (${ROOT_SCOPE})
Role granted: ${RBAC_ROLE}
Graph grant:  RoleManagement.ReadWrite.Directory (admin-consented)
AAD Premium:  ${AAD_PREMIUM_SKUS:-NOT DETECTED — see warning above, alz-iam apply will fail until licensed}

Next: run a plan-only apply in that workspace to confirm the
Azure provider authenticates via OIDC with no static secret.

Then, do not forget step 7: de-elevate the Global Admin's root
access (Entra ID -> Properties -> Access management for Azure
resources -> No), so it doesn't remain standing. The service
principal's own Owner role at "/" is unaffected by this — it's
only your personal elevated access being removed.
============================================================
SUMMARY