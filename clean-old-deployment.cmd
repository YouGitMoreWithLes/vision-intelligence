call az login

call az keyvault  secret delete --vault-name vi-dev-kv -n "acr-server"
call az keyvault  secret delete --vault-name vi-dev-kv -n acr-username
call az keyvault  secret delete --vault-name vi-dev-kv -n acr-password
call az keyvault  secret delete --vault-name vi-dev-kv -n content-primary-blob-connection-string
call az keyvault  secret delete --vault-name vi-dev-kv -n content-primary-connection-string
call az keyvault  secret delete --vault-name vi-dev-kv -n datalake-primary-blob-connection-string
call az keyvault  secret delete --vault-name vi-dev-kv -n datalake-primary-connection-string
call az keyvault  secret delete --vault-name vi-dev-kv -n sec-databricks-access-token

call az keyvault  secret purge --vault-name vi-dev-kv -n acr-server
call az keyvault  secret purge --vault-name vi-dev-kv -n acr-username
call az keyvault  secret purge --vault-name vi-dev-kv -n acr-password
call az keyvault  secret purge --vault-name vi-dev-kv -n content-primary-blob-connection-string
call az keyvault  secret purge --vault-name vi-dev-kv -n content-primary-connection-string
call az keyvault  secret purge --vault-name vi-dev-kv -n datalake-primary-blob-connection-string
call az keyvault  secret purge --vault-name vi-dev-kv -n datalake-primary-connection-string
call az keyvault  secret purge --vault-name vi-dev-kv -n sec-databricks-access-token

call az keyvault  delete -n vi-dev-kv
call az keyvault  purge -n vi-dev-kv

az monitor diagnostic-settings delete --name vi-dev-kv-ds --resource "/subscriptions/e669defe-f19a-4012-8e5b-6ac0529e0639/resourceGroups/vi-dev-rg/providers/Microsoft.KeyVault/vaults/vi-dev-kv"
az monitor diagnostic-settings delete --name vi-dev-vnet-ds --resource "/subscriptions/e669defe-f19a-4012-8e5b-6ac0529e0639/resourceGroups/vi-dev-rg/providers/Microsoft.Network/virtualNetworks/vi-dev-vnet"
