# resource "azurerm_storage_account" "static_website" {
#   name                     = format("%s%s", local.short-name, "swasa")
#   resource_group_name      = data.azurerm_resource_group.rg.name
#   location                 = data.azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"

#   static_website {
#     index_document    = "index.html"
#     error_404_document = "404.html"
#   }
# }

# resource "azurerm_cdn_frontdoor_profile" "afd_profile" {
#   name                      = format("%s%s", local.short-name, "cdnprofile")
#   resource_group_name         = data.azurerm_resource_group.rg.name
#   sku_name                    = "Standard_AzureFrontDoor"
# }

# resource "azurerm_cdn_frontdoor_endpoint" "afd_endpoint" {
#   name                     = format("%s%s", local.short-name, "cdnendpoint")
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd_profile.id
# }

# resource "azurerm_cdn_frontdoor_origin_group" "afd_origin_group" {
#   name                     = format("%s%s", local.short-name, "cdn-og")
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd_profile.id
#   session_affinity_enabled = false


#   health_probe {
#     protocol            = "Https"
#     interval_in_seconds = 60
#     request_type        = "GET"
#     path                = "/"
#   }

#   load_balancing {
    
#   }
# }

# resource "azurerm_cdn_frontdoor_origin" "afd_origin" {
#   name                            = format("%s%s", local.short-name, "cdn-origin")
#   cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.afd_origin_group.id
  
#   host_name                       = azurerm_storage_account.static_website.primary_web_host
#   origin_host_header              = azurerm_storage_account.static_website.primary_web_host
#   priority                        = 1
#   weight                          = 1000
#   certificate_name_check_enabled  = false
# }

# resource "azurerm_cdn_frontdoor_route" "afd_route" {
#   depends_on = [ 
#     azurerm_cdn_frontdoor_origin_group.afd_origin_group,
#     azurerm_cdn_frontdoor_origin.afd_origin
#     ]

#   name                     = "ghaldev-route"
#   cdn_frontdoor_endpoint_id = azurerm_cdn_frontdoor_endpoint.afd_endpoint.id
#   cdn_frontdoor_origin_ids = [ azurerm_cdn_frontdoor_origin.afd_origin.id ]
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.afd_origin_group.id
#   enabled                  = true
#   patterns_to_match        = ["/*"]
#   supported_protocols      = ["Http", "Https"]
#   forwarding_protocol    = "HttpsOnly"
#   https_redirect_enabled = true
# }

# resource "azurerm_cdn_frontdoor_custom_domain" "afd_custom_domain" {
#   name                     = format("%s%s", local.short-name, "customdomain")
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd_profile.id
#   host_name                = "www.lesm.me"

#   tls {
#     certificate_type    = "ManagedCertificate"
#   }
# }

# # resource "azurerm_cdn_frontdoor_custom_domain_association" "afd_custom_domain_association" {
# #   cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.afd_custom_domain.id
# #   cdn_frontdoor_route_ids = [ azurerm_cdn_frontdoor_route.afd_route.id ]
  
# # }
