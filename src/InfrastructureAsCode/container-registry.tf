## Enable the following code to create a customer managed key vault key for the ACR encryption. 
## Requires ACR Premium sku.

# resource "azurerm_key_vault_key" "acr-key" {
#   name         = format("%s-%s", local.base-name, "acr-key")
#   key_vault_id = azurerm_key_vault.key-vault.id
#   key_type     = "RSA"
#   key_size     = 2048
#   key_opts     = ["decrypt", "encrypt", "sign", "verify", "wrapKey", "unwrapKey"]
# }

resource "azurerm_container_registry" "acr" {
  depends_on = [ azurerm_role_assignment.crnt_usr_kv_admin ]

  name                = format("%s%s", local.short-name, "acr")
  resource_group_name = azurerm_resource_group.deployment-rg[0].name
  location            = azurerm_resource_group.deployment-rg[0].location
  sku                 = "Standard"
  admin_enabled       = true

  identity {
    type = "SystemAssigned"
  }

  # encryption {
  #   key_vault_key_id = azurerm_key_vault_key.acr-key.id
  # }

  # georeplications {
  #   location = "West US"
  #   zone_redundancy_enabled = true
  # }
}

resource "azurerm_key_vault_secret" "acr-secret-server" {
  name         = "acr-server"
  value        = azurerm_container_registry.acr.login_server

  key_vault_id = azurerm_key_vault.key-vault.id
}

resource "azurerm_key_vault_secret" "acr-secret-user" {
  name         = "acr-username"
  value        = azurerm_container_registry.acr.admin_username
  
  key_vault_id = azurerm_key_vault.key-vault.id
}

resource "azurerm_key_vault_secret" "acr-secret-password" {
  name         = "acr-password"
  value        = azurerm_container_registry.acr.admin_password
  
  key_vault_id = azurerm_key_vault.key-vault.id
}