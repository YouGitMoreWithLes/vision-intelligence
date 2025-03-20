resource "azurerm_log_analytics_workspace" "law" {
  name                = format("%s-%s", local.base-name, "law")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
