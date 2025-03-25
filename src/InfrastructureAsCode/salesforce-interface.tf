resource "azurerm_eventhub_namespace" "ehn_salesforce" {
  count               = var.should_deploy_salesforce_resources ? 1 : 0
  name                = format("%s-%s", local.base-name, "ehn-salesforce")

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

resource "azurerm_private_endpoint" "ehn_salesforce_pe" {
  name                = format("%s-%s", local.base-name, "ehn-salesforce-pe")

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet[5].id

  private_service_connection {
    name                           = format("%s-%s", local.base-name, "ehn-salesforce-sc")
    private_connection_resource_id = azurerm_eventhub_namespace.ehn_salesforce[0].id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }

  private_dns_zone_group {
    name                 = format("%s-%s", local.base-name, "ehn-salesforce-pe-zg")
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_eventhub.id]
  }
}

resource "azurerm_eventhub" "eh_salesforce" {
  count               = var.should_deploy_salesforce_resources ? 1 : 0
  
  name                = format("%s-%s", local.base-name, "eh-salesforce")
  namespace_id        = azurerm_eventhub_namespace.ehn_salesforce[0].id
  
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "ehar_salesforce" {
  count               = var.should_deploy_salesforce_resources ? 1 : 0
  
  name                = format("%s-%s", local.base-name, "ehar-salesforce")

  namespace_name      = azurerm_eventhub_namespace.ehn_salesforce[0].name
  eventhub_name       = azurerm_eventhub.eh_salesforce[0].name

  resource_group_name = data.azurerm_resource_group.rg.name

  listen              = true
  send                = true
  manage              = false
}

resource "azurerm_storage_account" "sa_salesforce" {
  count                    = var.should_deploy_salesforce_resources ? 1 : 0

  name                     = format("%s%s%s", local.short-name, "salesforce","sa")

  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "asp_salesforce" {
  count               = var.should_deploy_salesforce_resources ? 1 : 0
  
  name                = format("%s-%s", local.base-name, "salesforce-asp")
  
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku_name = "B1"
  os_type = "Linux"
}

resource "azurerm_linux_function_app" "salesforcefa" {
  depends_on = [ azurerm_subnet.subnet ]
  count                      = var.should_deploy_salesforce_resources ? 1 : 0
  
  name                       = format("%s-%s", local.base-name, "salesforce-fa")
  
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = data.azurerm_resource_group.rg.location

  service_plan_id            = azurerm_service_plan.asp_salesforce[0].id

  storage_account_name       = azurerm_storage_account.sa_salesforce[0].name
  storage_account_access_key = azurerm_storage_account.sa_salesforce[0].primary_access_key

  identity {
    type = "SystemAssigned"
  }

  functions_extension_version= "~4"

  public_network_access_enabled = false
  virtual_network_subnet_id = azurerm_subnet.subnet[2].id
  
  app_settings = {
    "AzureWebJobsStorage" = azurerm_storage_account.sa_salesforce[0].primary_connection_string
    "FUNCTIONS_EXTENSION_VERSION" = "~3"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "EventHubConnectionStringSalesForce" = azurerm_eventhub_namespace.ehn_salesforce[0].default_primary_connection_string
    "EventHubName" = azurerm_eventhub.eh_salesforce[0].name
  }

  site_config {
    container_registry_use_managed_identity = false
    application_stack {
      docker {
        registry_url = azurerm_container_registry.acr.login_server
        image_name = format("%s-%s", local.base-name, "salesforce")
        image_tag = "latest"
        registry_username = azurerm_key_vault_secret.acr-secret-user.value
        registry_password = azurerm_key_vault_secret.acr-secret-password.value
      }
    }

    always_on = true
    ftps_state = "Disabled" 


    # linux_fx_version = "python|3.8"

    minimum_tls_version = "1.2"
    scm_minimum_tls_version = "1.2"

    # ip_restriction {
    #   ip_address = "*"
    #   action     = "Deny"

    #   virtual_network_subnet_id = azurerm_subnet.subnet[2].id
    # }

    # scm_ip_restriction {
    #   ip_address = "*"
    #   action     = "Deny"
    # }
  }
}

resource "azurerm_key_vault_secret" "ehn-salesforce-secret" {
  depends_on = [ 
    azurerm_eventhub_namespace.ehn_salesforce[0],
    azurerm_role_assignment.crnt_usr_kv_admin
    ]
  
  name         = "EventHubConnectionString-SalesForce"
  value        = azurerm_eventhub_namespace.ehn_salesforce[0].default_primary_connection_string

  key_vault_id = azurerm_key_vault.key-vault.id
}
