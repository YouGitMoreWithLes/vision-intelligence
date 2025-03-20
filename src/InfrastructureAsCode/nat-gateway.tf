resource "azurerm_public_ip" "nat-gateway-pip" {
  name                = format("%s-%s", local.base-name, "nat-gateway-pip")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat-gateway" {
  name                = format("%s-%s", local.base-name, "nat-gateway")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku_name = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.nat-gateway.id
  public_ip_address_id = azurerm_public_ip.nat-gateway-pip.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet-nat-gateway-association" {
  subnet_id      = azurerm_subnet.subnet[5].id
  nat_gateway_id = azurerm_nat_gateway.nat-gateway.id
}
