resource "azurerm_log_analytics_workspace" "law" {
  name                = format("%s-%s", local.base-name, "law")
  resource_group_name = azurerm_resource_group.deployment-rg[0].name
  location            = azurerm_resource_group.deployment-rg[0].location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
