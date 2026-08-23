#!/usr/bin/env zsh
#
# bootstrap-hcp-oidc.sh
#
# One-time bootstrap: creates the Azure AD app registration, federated OIDC
# credentials, management group, and RBAC role assignment that HCP Terraform
# needs to authenticate to a brand-new Azure tenant via workload identity
# federation (no client secret, ever).
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

# The "Intermediate Root" management group in canonical ALZ terms — sits
# directly under the Tenant Root Group. Your ALZ Terraform creates the
# standard children under this (Platform, Landing Zones, Decommissioned;
# and Platform's own children Identity/Management/Connectivity) — do not
# name this one "Platform", that's a specific child MG one level lower.
TENANT_MG_ID="mau-mg-root"
TENANT_MG_DISPLAY_NAME="MAU Intermediate Root"

# App registration that represents HCP Terraform in this tenant.
APP_DISPLAY_NAME="mau-hcp-terraform-oidc"

# HCP Terraform (Terraform Cloud) issuer. Change only if you run a
# self-hosted Terraform Enterprise instance with its own hostname.
TFC_ISSUER="https://app.terraform.io"

# HCP Terraform org / project / workspace this identity should trust.
# If you run one workspace per environment, add extra WORKSPACE_NAMES
# entries and the script will create a plan+apply credential pair for each.
TFC_ORG="<TFC_ORG>"
TFC_PROJECT="<TFC_PROJECT>"
WORKSPACE_NAMES=("<WORKSPACE_NAME>")   # e.g. ("mau-alz-prd" "mau-alz-tst")

# RBAC role granted to the service principal at the management group scope.
RBAC_ROLE="Contributor"

# The subscription that already exists in the new tenant, which will be
# moved under $TENANT_MG_ID. Leave empty to auto-detect the current
# subscription from `az account show`.
INITIAL_SUBSCRIPTION_ID=""

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
read -r -p "Proceed with these values? [y/N] " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

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
# 3. Create the intermediate management group and move the subscription in
# ---------------------------------------------------------------------------

echo "==> Creating management group: $TENANT_MG_ID"
az account management-group create \
  --name "$TENANT_MG_ID" \
  --display-name "$TENANT_MG_DISPLAY_NAME" \
  || echo "  (management group may already exist — continuing)"

echo "==> Moving subscription $INITIAL_SUBSCRIPTION_ID under $TENANT_MG_ID"
az account management-group subscription add \
  --name "$TENANT_MG_ID" \
  --subscription "$INITIAL_SUBSCRIPTION_ID"

# ---------------------------------------------------------------------------
# 4. Create the app registration + service principal
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
# 5. Create federated credentials (plan + apply) per workspace
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
# 6. Grant RBAC role at the management group scope
# ---------------------------------------------------------------------------
# Use --assignee-object-id / --assignee-principal-type to avoid a Graph
# lookup on a service principal that may not have finished replicating yet.

MG_SCOPE="/providers/Microsoft.Management/managementGroups/${TENANT_MG_ID}"

echo "==> Assigning role '$RBAC_ROLE' to service principal at $MG_SCOPE"
for attempt in 1 2 3 4 5; do
  if az role assignment create \
      --assignee-object-id "$SP_OBJECT_ID" \
      --assignee-principal-type ServicePrincipal \
      --role "$RBAC_ROLE" \
      --scope "$MG_SCOPE"; then
    break
  fi
  echo "  Role assignment failed (attempt $attempt/5) — service principal may still be replicating, retrying in 15s..."
  sleep 15
done

# ---------------------------------------------------------------------------
# 7. Summary — set these as HCP Terraform workspace environment variables
# ---------------------------------------------------------------------------

cat <<SUMMARY

============================================================
Bootstrap complete. Set these in the HCP Terraform workspace
(Variables -> Environment variables, not Terraform variables):

  TFC_AZURE_PROVIDER_AUTH = true
  TFC_AZURE_RUN_CLIENT_ID = ${APP_ID}
  ARM_SUBSCRIPTION_ID     = ${INITIAL_SUBSCRIPTION_ID}
  ARM_TENANT_ID           = ${TENANT_ID}

Management group scope: ${MG_SCOPE}
Role granted:            ${RBAC_ROLE}

Next: run a plan-only apply in that workspace to confirm the
Azure provider authenticates via OIDC with no static secret.

Then, do not forget step 8: de-elevate the Global Admin's root
access (Entra ID -> Properties -> Access management for Azure
resources -> No), so it doesn't remain standing.
============================================================
SUMMARY