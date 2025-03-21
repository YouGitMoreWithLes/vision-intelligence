#!/usr/bin/env bash

echo "Starting bash script"

# Bash strict mode, stop on any error
set -euo pipefail

# Ensure all required environment variables are present
echo "Testing variables"
test -n "$DATABRICKS_WORKSPACE_RESOURCE_ID"
test -n "$KEY_VAULT"
test -n "$SECRET_NAME"
#test -n "$ARM_CLIENT_ID"
#test -n "$ARM_CLIENT_SECRET"
#test -n "$ARM_TENANT_ID"

# NOTE **********************************************************************
# This section must be enabled if this script will be running in a release pipeline like ADO Release
# Login
# echo "Logging SPN into Azure CLI" 
# az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" -t "$ARM_TENANT_ID"

# Get a token for the global Databricks application.
# The resource name is fixed and never changes.
echo "Getting global Databricks application token"
token=$(az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d | jq .accessToken -r)
echo "$token"

# Get a token for the Azure management API
echo "Getting Azure Management API token"
azToken=$(az account get-access-token --resource https://management.core.windows.net/ | jq .accessToken -r)
echo "$azToken"

echo "DATABRICKS_ENDPOINT"
echo "$DATABRICKS_ENDPOINT"
echo 

echo "DATABRICKS_WORKSPACE_RESOURCE_ID"
echo "$DATABRICKS_WORKSPACE_RESOURCE_ID"
echo 

# Generate a PAT token. Note the quota limit of 600 tokens.
echo "Getting PAT from Databricks"
pat_token=$(curl -sf "$DATABRICKS_ENDPOINT/api/2.0/token/create" \
  -H "Authorization: Bearer $token" \
  -H "X-Databricks-Azure-SP-Management-Token:$azToken" \
  -H "X-Databricks-Azure-Workspace-Resource-Id:$DATABRICKS_WORKSPACE_RESOURCE_ID" \
  -d '{ "comment": "Terraform-generated token" }' | jq .token_value -r)

echo "PAT:"
echo "$pat_token"

echo "Adding PAT to Azure Key Vault"
az keyvault secret set --vault-name "$KEY_VAULT" -n "$SECRET_NAME" --value "$pat_token" -o none

echo "Done setting Databricks PAT"
