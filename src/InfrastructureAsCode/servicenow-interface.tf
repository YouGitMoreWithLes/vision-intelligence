resource "azurerm_eventhub_namespace" "ehn_servicenow" {
  count               = var.should_deploy_servicenow_resources ? 1 : 0
  name                = format("%s-%s", local.base-name, "ehn-servicenow")

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku                 = "Standard"
  capacity            = 1

  public_network_access_enabled = false

  network_rulesets {
    default_action = "Deny"
    public_network_access_enabled = false 
    trusted_service_access_enabled = true
    
    virtual_network_rule {
      subnet_id = azurerm_subnet.subnet[5].id
      ignore_missing_virtual_network_service_endpoint = true
    }
  }  
}

resource "azurerm_private_endpoint" "ehn_servicenow_pe" {
  name                = format("%s-%s", local.base-name, "ehn-servicenow-pe")

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet[5].id

  private_service_connection {
    name                           = format("%s-%s", local.base-name, "ehn-servicenow-sc")
    private_connection_resource_id = azurerm_eventhub_namespace.ehn_servicenow[0].id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }

  private_dns_zone_group {
    name                 = format("%s-%s", local.base-name, "ehn-servicenow-pe-zg")
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_eventhub.id]
  }
}

resource "azurerm_eventhub" "eh_servicenow" {
  count               = var.should_deploy_servicenow_resources ? 1 : 0
  
  name                = format("%s-%s", local.base-name, "eh-servicenow")
  namespace_id        = azurerm_eventhub_namespace.ehn_servicenow[0].id
  
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "ehar_servicenow" {
  count               = var.should_deploy_servicenow_resources ? 1 : 0
  
  name                = format("%s-%s", local.base-name, "ehar-servicenow")

  namespace_name      = azurerm_eventhub_namespace.ehn_servicenow[0].name
  eventhub_name       = azurerm_eventhub.eh_servicenow[0].name

  resource_group_name = data.azurerm_resource_group.rg.name

  listen              = true
  send                = true
  manage              = false
}

resource "azurerm_storage_account" "sa_servicenow" {
  count                    = var.should_deploy_servicenow_resources ? 1 : 0

  name                     = format("%s%s%s", local.short-name, "servicenow","sa")

  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "asp_servicenow" {
  count               = var.should_deploy_servicenow_resources ? 1 : 0
  
  name                = format("%s-%s", local.base-name, "servicenow-asp")
  
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku_name = "Y1"
  os_type = "Linux"
}

resource "azurerm_function_app" "servicenow_fa" {
  count                      = var.should_deploy_servicenow_resources ? 1 : 0
  
  name                       = format("%s-%s", local.base-name, "servicenow-fa")
  
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = data.azurerm_resource_group.rg.location

  app_service_plan_id        = azurerm_service_plan.asp_servicenow[0].id

  storage_account_name       = azurerm_storage_account.sa_servicenow[0].name
  storage_account_access_key = azurerm_storage_account.sa_servicenow[0].primary_access_key

  version                    = "~3"
  app_settings = {
    "AzureWebJobsStorage" = azurerm_storage_account.sa_servicenow[0].primary_connection_string
    "FUNCTIONS_EXTENSION_VERSION" = "~3"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "EventHubConnectionStringServiceNow" = azurerm_eventhub_namespace.ehn_servicenow[0].default_primary_connection_string
    "EventHubName" = azurerm_eventhub.eh_servicenow[0].name
  }
}

resource "azurerm_key_vault_secret" "ehn-servicenow-secret" {
  depends_on = [ 
    azurerm_eventhub_namespace.ehn_servicenow[0],
    azurerm_role_assignment.crnt_usr_kv_admin
    ]
  
  name         = "EventHubConnectionString-servicenow"
  value        = azurerm_eventhub_namespace.ehn_servicenow[0].default_primary_connection_string

  key_vault_id = azurerm_key_vault.key-vault.id
}
