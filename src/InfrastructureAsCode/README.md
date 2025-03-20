# Insight Vision Intelligence IaC

This section provides details information and instructions to deploy your specialized version of Insight's Vision Intelligence Platform.

## Insight's Vision Intelligence Platform for Azure

### Creating Azure Service Principal for GitHub Action Access

Check out the [Azure CLI Installation documenttion](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

Log into the tenant/subscription using the Azure CLI.

```bash
az login --tenant 00000000-0000-0000-0000-000000000000

az account set -s 00000000-0000-0000-0000-000000000000
```

Create your GHA Service Principal

```bash
az ad sp create-for-rbac --name "Vision-Intelligence-GitHub-Actions" --role Owner --scopes /subscriptions/{00000000-0000-0000-0000-000000000000}/resourceGroups/gdr_vision_intelligence --sdk-auth
```

Output should look something like this:

```json
{
  "clientId": "00000000-0000-0000-0000-000000000000",
  "clientSecret": "",
  "subscriptionId": "00000000-0000-0000-0000-000000000000",
  "tenantId": "00000000-0000-0000-0000-000000000000",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Create the required GitHub Actions Secrets to support the GHA Workflows

Check out the [Create GitHub Action Secrets documentation](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions)

```text
ARM_CLIENT_ID         = {00000000-0000-0000-0000-000000000000}      # clientId
ARM_CLIENT_SECRET     = ""                                          # clientSecret
ARM_SUBSCRIPTION_ID   = {00000000-0000-0000-0000-000000000000}      # subsctiptionId
ARM_TENANT_ID         = {00000000-0000-0000-0000-000000000000}      # tenantId
```

### Configure Terraform State Storage

Be sure to update the Azure Provider Backend in the [terraform.tf](./terraform.tf) file. This will ensure you have CI/CD for your infrastructure.

You will need an existing Azure Storage Account with a container already created. The Terraform CLI will create the "key" as a file in the container and will have the Terraform State of your IaC in Json format.

**NOTE: Terraform State is stored in plain text format and can contain confidential data such as secrets and passwords. Take appropriate steps to safegaurd this information.**

```terraform
backend "azurerm" {
  resource_group_name  = "tf-state-rg"
  storage_account_name = "ghatfstatesa"
  container_name       = "insight-vi-tfstate"
  key                  = "dev.tfstate"
}
```

### Azure Resource Group Management

This IaC can use an existing Azure Resource Group to deploy the resources or it can create a new one if desired. Configure the "should_create_rg" variable in the [variables.tf](./variables.tf) file to false if you have an existing resource group you are deploying to, otherwise configure the variable to true and this IaC will create a new Azure Resource Group.

### Azure Container Instance Special Case

This IaC creates both an Azure Container Registry and a Azure Container Instance. However, since the Azure Container Instance is configured to point to the VisionIntelligenceAPI container the deployment of this IaC will fail initially.

To prevent this initial failure configure the "should_deploy_container_resources" variable flag in the [variables.tf](./variables.tf) file to false the first time this IaC is deployed.

This will prevent both the Azure Container Instance and the Azure Application Gateway from being depoyed. Once the Azure Container Registry has been deployed and the VisionIntelligenceAPI has been built and pushed to the Azure Container Registry yo cn reconfigure the "should_deploy_container_resources" variable to true and allow the web API resources to be deployed as well.

### Cleaning Up Previous Installations

Azure/Terraform doesn't always clean up all related/child resources when deleting items. For example Diagnostic Settings are not automatically deleted. Be sure to clean up your resources appropriately.

```bash
# NOTE: These are examples and the specific subscriptionId, resource group name, and resource name need to be applied.

az keyvault key delete --vault-name vi-dev-kv -n acr-server
az keyvault key delete --vault-name vi-dev-kv -n acr-username
az keyvault key delete --vault-name vi-dev-kv -n acr-password

az keyvault key purge --vault-name vi-dev-kv -n acr-server
az keyvault key purge --vault-name vi-dev-kv -n acr-username
az keyvault key purge --vault-name vi-dev-kv -n acr-password


az resource delete --ids "/subscriptions/{00000000-0000-0000-0000-000000000000}/resourceGroups/ivi-dev1-rg/providers/Microsoft.KeyVault/vaults/vi-dev-kv|vi-dev-kv-ds"
az resource delete --ids "/subscriptions/{00000000-0000-0000-0000-000000000000}/resourceGroups/ivi-dev1-rg/providers/Microsoft.Network/virtualNetworks/ivi-dev1-vnet|ivi-dev1-vnet-ds"
```
