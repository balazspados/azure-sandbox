#!/usr/bin/env zsh
#
# add-hcp-workspace-oidc.sh
#
# Adds a new HCP Terraform workspace to the existing OIDC trust scope,
# without touching the app registration, service principal, or the
# Owner role assignment at Tenant Root Group scope created by
# bootstrap-hcp-oidc.sh. Safe to run repeatedly for each new workspace
# (alz-management, alz-network, alz-sub-vending, ...) as you split your
# ALZ Terraform configs across workspaces.
#
# Usage: ./add-hcp-workspace-oidc.sh <workspace-name> [<workspace-name> ...]

set -euo pipefail

# ---------------------------------------------------------------------------
# EDIT THESE to match bootstrap-hcp-oidc.sh
# ---------------------------------------------------------------------------

APP_DISPLAY_NAME="mau-hcp-terraform-oidc"
TFC_ISSUER="https://app.terraform.io"
TFC_ORG="padi-org"
TFC_PROJECT="MAU-ALZ"

# ---------------------------------------------------------------------------

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <workspace-name> [<workspace-name> ...]"
  exit 1
fi

echo "==> Looking up existing app registration: $APP_DISPLAY_NAME"
APP_OBJECT_ID=$(az ad app list --display-name "$APP_DISPLAY_NAME" --query "[0].id" -o tsv)

if [[ -z "$APP_OBJECT_ID" || "$APP_OBJECT_ID" == "null" ]]; then
  echo "Could not find an app registration named '$APP_DISPLAY_NAME'."
  echo "Run bootstrap-hcp-oidc.sh first, or check APP_DISPLAY_NAME here matches it exactly."
  exit 1
fi
echo "App object ID: $APP_OBJECT_ID"

for WORKSPACE_NAME in "$@"; do
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

cat <<SUMMARY

============================================================
Done. Workspace(s) added to the OIDC trust: $@

No changes needed on the Azure side beyond this — the same
client_id, tenant_id, and subscription_id from the original
bootstrap still apply. Set these on each new workspace in HCP
Terraform (Variables -> Environment variables):

  TFC_AZURE_PROVIDER_AUTH = true
  TFC_AZURE_RUN_CLIENT_ID = <same client_id as before>
  ARM_SUBSCRIPTION_ID     = <same subscription_id as before>
  ARM_TENANT_ID           = <same tenant_id as before>
============================================================
SUMMARY