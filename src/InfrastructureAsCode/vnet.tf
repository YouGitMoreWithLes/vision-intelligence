resource "azurerm_storage_account" "vnet-fl" {
  name = format("%s%s%s", local.short-name, "fl", "sa")

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "vnet" {
  name                = format("%s-%s", local.base-name, "vnet")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  address_space       = ["${var.vnet_base_ip}.0.0/16"]

}

resource "azurerm_subnet" "subnet" {

  count = length(var.vnet_subnets)
  name  = format("%s-%s-%s", local.base-name, "subnet", var.vnet_subnets[count.index].Name)

  resource_group_name = data.azurerm_resource_group.rg.name

  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["${var.vnet_base_ip}.${count.index}.0/24"]

  service_endpoints = var.vnet_subnets[count.index].ServiceEndpoints

  private_link_service_network_policies_enabled = var.vnet_subnets[count.index].ServiceEndpoints != null ? true : false

  dynamic "delegation" {
    for_each = var.vnet_subnets[count.index].Delegation != null ? [var.vnet_subnets[count.index].Delegation] : []
    content {
      name = var.vnet_subnets[count.index].Name

      service_delegation {
        name = var.vnet_subnets[count.index].Delegation[0].Delegate
        actions = var.vnet_subnets[count.index].Delegation[0].Actions
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "vnet_diagnostics" {
  name = format("%s-%s", local.base-name, "vnet-ds")

  target_resource_id = azurerm_virtual_network.vnet.id

  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_network_watcher" "nw" {
  name                = "network-watcher-${data.azurerm_resource_group.rg.location}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_network_watcher_flow_log" "flow_log" {
  name = "${azurerm_storage_account.vnet-fl.name}-flow-log"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  network_watcher_name = azurerm_network_watcher.nw.name
  target_resource_id   = azurerm_virtual_network.vnet.id
  storage_account_id   = azurerm_storage_account.vnet-fl.id
  enabled              = true

  retention_policy {
    enabled = true
    days    = 30
  }
}

