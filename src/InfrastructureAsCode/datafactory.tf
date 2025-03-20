resource "azurerm_data_factory" "adf" {
    name                = format("%s-%s", local.base-name, "adf")
    resource_group_name = data.azurerm_resource_group.rg.name
    location            = data.azurerm_resource_group.rg.location

    tags = data.azurerm_resource_group.rg.tags

    identity {
      type = "SystemAssigned"
    }
}

resource "azurerm_key_vault_access_policy" "adf-kv-ap" {
    key_vault_id = azurerm_key_vault.key-vault.id
    tenant_id    = data.azurerm_client_config.usr.tenant_id
    object_id    = azurerm_data_factory.adf.identity[0].principal_id

    key_permissions = [
        "Get","List"
    ]

    secret_permissions = [
        "Get","List"
    ]
}

resource "azurerm_data_factory_linked_service_key_vault" "adf-kv-link" {
  name                = format("%s-%s", local.base-name, "adf-kv-link")
  data_factory_id     = azurerm_data_factory.adf.id
  key_vault_id        = azurerm_key_vault.key-vault.id
}

resource "azurerm_role_assignment" "dfdl" {
    scope                               = azurerm_storage_account.datalake-sa.id
    role_definition_name                = "Storage Blob Data Contributor"
    principal_id                        = azurerm_data_factory.adf.identity[0].principal_id
    skip_service_principal_aad_check    = true
}
