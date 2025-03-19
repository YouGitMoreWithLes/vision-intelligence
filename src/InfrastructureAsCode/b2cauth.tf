
# resource "azurerm_resource_group" "example" {
#   name     = "example-resources"
#   location = "West Europe"
# }

# resource "azurerm_b2c_directory" "example" {
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
#   sku                 = "Standard"
#   display_name        = "Example B2C Directory"
#   domain_name         = "exampleb2c.onmicrosoft.com"
# }

# resource "azurerm_b2c_user_flow" "example" {
#   name                = "B2C_1_signupsignin"
#   resource_group_name = azurerm_resource_group.example.name
#   b2c_directory_id    = azurerm_b2c_directory.example.id
#   user_flow_type      = "SignUpOrSignIn"
# }

# # resource "azurerm_b2c_application" "example" {
# #   resource_group_name = azurerm_resource_group.example.name
# #   b2c_directory_id    = azurerm_b2c_directory.example.id
# #   display_name        = "Example B2C Application"
# #   identifier_uris     = ["https://exampleb2c.onmicrosoft.com/exampleapp"]
# #   reply_urls          = ["https://exampleapp.com/auth"]
# #   type                = "Web"
# # }
