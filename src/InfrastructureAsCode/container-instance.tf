resource "azurerm_container_group" "vision_intelligence_cg" {
  count              = var.should_deploy_container_resources == true ? 1 : 0

  name                = format("%s-%s", local.base-name, "cg")
  location            = azurerm_resource_group.deployment-rg[0].location
  resource_group_name = azurerm_resource_group.deployment-rg[0].name
  os_type             = "Linux"

  ip_address_type = "Private"
  subnet_ids = [ azurerm_subnet.subnet[1].id ]

  exposed_port  {
    port     = 8080
    protocol = "TCP"
  }

  exposed_port  {
    port     = 8081
    protocol = "TCP"
  }

  container {
    name   = "vision-intelligence-webapi"
    image  = "${azurerm_container_registry.acr.login_server}/vision-intelligence-webapi:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }

    ports {
      port     = 8081
      protocol = "TCP"
    }

    environment_variables = {
      "ENV_VAR_EXAMPLE" = "example_value"
    }

    secure_environment_variables = {
      "ACR_USERNAME" = azurerm_key_vault_secret.acr-secret-user.value
      "ACR_PASSWORD" = azurerm_key_vault_secret.acr-secret-password.value
    }
  }

  image_registry_credential {
    server   = azurerm_key_vault_secret.acr-secret-server.value
    username = azurerm_key_vault_secret.acr-secret-user.value
    password = azurerm_key_vault_secret.acr-secret-password.value
  }
}
