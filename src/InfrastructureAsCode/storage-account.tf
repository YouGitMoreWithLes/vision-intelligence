resource "azurerm_private_dns_zone" "privatelink_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_blob_vnet_link" {
  name                  = "privatelink-blob-vnet-link"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

## NOTE: Cusomter managed keys are commented out for now. Both Purge Protection and Soft Delete are required to be enabled on the Key Vault for the customer managed keys to work.

# resource "azurerm_key_vault_key" "content-key"{
#   name = format("%s-%s", local.base-name, "content-key")
#   key_vault_id = azurerm_key_vault.key-vault.id
#   key_type = "RSA"
#   key_size = 2048
#   key_opts = ["decrypt", "encrypt", "sign", "verify", "wrapKey", "unwrapKey"]
# }

###################################################################### Content Storage Account ######################################################################
resource "azurerm_storage_account" "content-sa" {
  name                     = format("%s%s%s", local.short-name, "content","sa")
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }

  // Networking and access control
  # public_network_access_enabled = false
  shared_access_key_enabled = true
  https_traffic_only_enabled = true
  min_tls_version = "TLS1_2"

  network_rules {
    default_action = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet[7].id]
  }
}

resource "azurerm_private_endpoint" "content-pe" {
  name                = format("%s-%s", local.base-name, "content-sa-pe")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet[7].id

  private_service_connection {
    name                           = format("%s-%s", local.base-name, "content-sa-pe-sc")
    private_connection_resource_id = azurerm_storage_account.content-sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = format("%s-%s", local.base-name, "content-sa-pe-zg")
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob.id]
  }
}

resource "azurerm_key_vault_secret" "content-primary-connection-string" {
  depends_on = [ azurerm_role_assignment.crnt_usr_kv_admin ]
  
  name         = "content-primary-connection-string"
  value        = azurerm_storage_account.content-sa.primary_connection_string

  key_vault_id = azurerm_key_vault.key-vault.id
}

resource "azurerm_key_vault_secret" "content-primary-blob-connection-string" {
  depends_on = [ azurerm_role_assignment.crnt_usr_kv_admin ]
  
  name         = "content-primary-blob-connection-string"
  value        = azurerm_storage_account.content-sa.primary_blob_connection_string

  key_vault_id = azurerm_key_vault.key-vault.id
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

###################################################################### Datalake Storage Account ######################################################################
# resource "azurerm_key_vault_key" "datalake-key"{
#   name = format("%s-%s", local.base-name, "datalake-key")
#   key_vault_id = azurerm_key_vault.key-vault.id
#   key_type = "RSA"
#   key_size = 2048
#   key_opts = ["decrypt", "encrypt", "sign", "verify", "wrapKey", "unwrapKey"]
# }

resource "azurerm_storage_account" "datalake-sa" {
  depends_on = [ azurerm_virtual_network.vnet ]

  name                     = format("%s%s%s", local.short-name, "datalake","sa")
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  identity {
    type = "SystemAssigned"
  }

  // Networking and access control
  # public_network_access_enabled = false
  shared_access_key_enabled = true
  https_traffic_only_enabled = true
  min_tls_version = "TLS1_2"

  network_rules {
    default_action = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet[7].id]
  }

  // Datalake Gen2 settings
  is_hns_enabled = true
  nfsv3_enabled = false
}

resource "azurerm_private_endpoint" "datalake-pe" {
  name                = format("%s-%s", local.base-name, "datalake-sa-pe")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet[7].id

  private_service_connection {
    name                           = format("%s-%s", local.base-name, "datalake-sa-pe-sc")
    private_connection_resource_id = azurerm_storage_account.datalake-sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = format("%s-%s", local.base-name, "datalake-sa-pe-zg")
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_blob.id]
  }
}

resource "azurerm_key_vault_secret" "datalake-primary-connection-string" {
  depends_on = [ azurerm_role_assignment.crnt_usr_kv_admin ]
  
  name         = "datalake-primary-connection-string"
  value        = azurerm_storage_account.datalake-sa.primary_connection_string

  key_vault_id = azurerm_key_vault.key-vault.id
}

resource "azurerm_key_vault_secret" "datalake-primary-blob-connection-string" {
  depends_on = [ azurerm_role_assignment.crnt_usr_kv_admin ]
  
  name         = "datalake-primary-blob-connection-string"
  value        = azurerm_storage_account.datalake-sa.primary_blob_connection_string

  key_vault_id = azurerm_key_vault.key-vault.id
}

# resource "azurerm_key_vault_secret" "datalake-secret-user" {
#  depends_on = [ azurerm_role_assignment.crnt_usr_kv_admin ]
  
#   name         = "datalake-username"
#   value        = azurerm_container_registry.acr.admin_username
  
#   key_vault_id = azurerm_key_vault.key-vault.id
# }

# resource "azurerm_key_vault_secret" "datalake-secret-password" {
#  depends_on = [ azurerm_role_assignment.crnt_usr_kv_admin ]
  
#   name         = "datalake-password"
#   value        = azurerm_container_registry.acr.admin_password
  
#   key_vault_id = azurerm_key_vault.key-vault.id
# }


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
