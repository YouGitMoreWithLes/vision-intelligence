## NOTE: Cusomter managed keys are commented out for now. Both Purge Protection and Soft Delete are required to be enabled on the Key Vault for the customer managed keys to work.

# resource "azurerm_key_vault_key" "content-key"{
#   name = format("%s-%s", local.base-name, "content-key")
#   key_vault_id = azurerm_key_vault.key-vault.id
#   key_type = "RSA"
#   key_size = 2048
#   key_opts = ["decrypt", "encrypt", "sign", "verify", "wrapKey", "unwrapKey"]
# }

resource "azurerm_storage_account" "content-sa" {
  name                     = format("%s%s%s", local.short-name, "content","sa")
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }
}

# resource "azurerm_storage_account_customer_managed_key" "content-sa-cmk" {
#   storage_account_id = azurerm_storage_account.content-sa.id
#   key_vault_id       = azurerm_key_vault.key-vault.id
#   key_name           = azurerm_key_vault_key.content-key.name
# }

# resource "azuread_role_assignment" "content-sa-role" {
#   principal_id = azurerm_storage_account.content-sa.identity[0].principal_id
#   role_definition_name = "Key Vault Crypto User"
#   scope = azurerm_key_vault.key-vault.id
# }

# resource "azurerm_key_vault_key" "datalake-key"{
#   name = format("%s-%s", local.base-name, "datalake-key")
#   key_vault_id = azurerm_key_vault.key-vault.id
#   key_type = "RSA"
#   key_size = 2048
#   key_opts = ["decrypt", "encrypt", "sign", "verify", "wrapKey", "unwrapKey"]
# }

resource "azurerm_storage_account" "datalake-sa" {
  name                     = format("%s%s%s", local.short-name, "datalake","sa")
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }

  # Networking and access control
  public_network_access_enabled = false
  shared_access_key_enabled = true
  https_traffic_only_enabled = true
  min_tls_version = "TLS1_2"

  # Datalake Gen2 settings
  is_hns_enabled = true
  nfsv3_enabled = false
}

# resource "azurerm_storage_account_customer_managed_key" "datalake-sa-cmk" {
#   storage_account_id = azurerm_storage_account.datalake-sa.id
#   key_vault_id       = azurerm_key_vault.key-vault.id
#   key_name           = azurerm_key_vault_key.datalake-key.name
# }

# resource "azuread_role_assignment" "datalake-sa-role" {
#   principal_id = azurerm_storage_account.datalake-sa.identity[0].principal_id
#   role_definition_name = "Key Vault Crypto User"
#   scope = azurerm_key_vault.key-vault.id
# }
