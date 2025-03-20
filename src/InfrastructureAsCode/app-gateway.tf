resource "azurerm_public_ip" "app-gateway-pip" {
  count              = var.should_deploy_container_resources == true ? 1 : 0
 
  name                = format("%s-%s", local.base-name, "app-gateway-pip")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "app-gateway" {

  count              = var.should_deploy_container_resources == true ? 1 : 0
  
  depends_on = [ azurerm_public_ip.app-gateway-pip[0] ]
  
  name                = format("%s-%s", local.base-name, "app-gateway")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "app-gateway-ip-configuration"
    subnet_id = azurerm_subnet.subnet[0].id
  }

  frontend_ip_configuration {
    name                 = "app-gateway-public-frontend-ip"
    public_ip_address_id = azurerm_public_ip.app-gateway-pip[0].id
  }

  frontend_ip_configuration {
    name                          = "app-gateway-private-frontend-ip"
    private_ip_address_allocation = "Static"
    subnet_id                     = azurerm_subnet.subnet[0].id 
    private_ip_address = cidrhost(azurerm_subnet.subnet[0].address_prefixes[0], 10)
  }

  frontend_port {
    name = "app-gateway-frontend-port"
    port = 80
  }

  http_listener {
    name                           = "app-gateway-public-http-listener"
    frontend_ip_configuration_name = "app-gateway-public-frontend-ip"
    frontend_port_name             = "app-gateway-frontend-port"
    protocol                       = "Http"
  }

  backend_address_pool {
    name = "vision-intelligence-api-backend-pool"
    ip_addresses = [ azurerm_container_group.vision_intelligence_cg[0].ip_address ]
  }

  probe {
    name                = "app-gateway-http-backend-probe"
    host                = "127.0.0.1"
    path                = "/health"
    protocol            = "Http"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = false
  }

  backend_http_settings {
    name                  = "app-gateway-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 20
    probe_name            = "app-gateway-http-backend-probe"
  }

  request_routing_rule {
    name                          = "app-gateway-request-routing-rule"
    rule_type                     = "Basic"
    priority                      = "100"
    http_listener_name            = "app-gateway-public-http-listener"
    backend_address_pool_name     = "vision-intelligence-api-backend-pool"
    backend_http_settings_name    = "app-gateway-backend-http-settings"
  }
}
