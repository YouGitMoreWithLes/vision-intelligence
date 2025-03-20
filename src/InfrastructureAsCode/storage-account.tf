
resource "azurerm_storage_account" "content-sa" {
  name                     = format("%s%s%s", local.short-name, "content","sa")
  resource_group_name      = azurerm_resource_group.deployment-rg[0].name
  location                 = azurerm_resource_group.deployment-rg[0].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
