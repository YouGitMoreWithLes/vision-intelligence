variable "tenantId" {
  type    = string
  default = "6c637512-c417-4e78-9d62-b61258e4b619" # Insight
}

variable "subscriptionId" {
  type    = string
  default = "e669defe-f19a-4012-8e5b-6ac0529e0639"
}

variable "project_name" {
  type    = string
  default = "ivi"
}

variable "env" {
  type    = string
  default = "dev1"
}

variable "should_create_rg" {
  type    = bool
  default = true
}

variable "rg_location" {
  type    = string
  default = "westus2"
}

variable "vnet_base_ip" {
  description = "The first 2 octets for the base IP address for the virtual network. I.e., 172.16"
  type        = string
  default     = "172.16"
}

variable "vnet_subnets" {
  description = "The subnets to create in the private vnet."
  type        = list(object(
    { 
      Name = string 
      Delegation = optional(list(object({
        Delegate = string
        Actions  = optional(list(string), [])
      })))
    }))
  default = [ # CAUTION! Altering the order of this list will afftect hardcoded values in resource files.
    { Name = "app-gateway" },
    { Name = "app-service", Delegation = [{ Delegate = "Microsoft.ContainerInstance/containerGroups", Actions = ["Microsoft.Network/virtualNetworks/subnets/action"] }] },
    { Name = "container-instance" },
    { Name = "database" },
    { Name = "data-warehouse" },
    { Name = "event-hub" },
    { Name = "nat-gateway" },
    { Name = "storage" },
  ]
}

variable "should_deploy_container_resources" {
  type    = bool
  default = true
  description = "Use this variable to stop the deployment of the container instances and app gateway so that the Vision Intelligence container can be published to the ACR. Otherwise, the deployment will fail."
}

# variable "rg_name" {
#     type = string
#     default = "dev-ghal-rg"
# }

# variable "prefix" {
#     type = string
#     default = ""
# }

# variable "tags" {
#     description = "Tags to set for all resources"
#     type = map(string)
#     default = {
#         project = "candid",
#         environment = "dev",
#         app = "mdw",
#         costcenter = "Unknown",
#         security = "reserved"
#     }
# }

# variable "key_vault_secrets" {
#     type = list(string)
#     default = [
#         "sec-sql-server-aas-pwd"
#     ]
# }

# variable "key_vault_access_policy_devs" {
#     type = list(string)
#     default = [
#       "les.mcwhirter@insight.com"
#     ]
# }

# variable "certificate_permissions" {
#     type = list(string)
#     default = []
# }

#  variable "key_permissions" {
#      type = list(string)
#     default = []
#  }

# variable "secret_permissions" {
#     type = list(string)
#     default = []
# }

# variable "storage_permissions" {
#     type = list(string)
#     default = []
# }

# variable "storage_account_name" {
#     type = string
#     default = "ghactionslearn"
# }

# variable "storage_account_kind" {
#     type = string
#     default = "StorageV2"
# }

# variable "storage_account_tier" {
#     type = string
#     default = "Standard"
# }

# variable "storage_account_replication_type" {
#     type = string
#     default = "GRS"
# }

# variable "storage_account_containers" {
#     type = list(string)
#     default = []
# }

# variable "sql_db_name" {
#     type = string
#     default = "ghactionslearn"
# }

# variable "sql_admin_name" {
#     type = string
#     default = "ghactionslearnadmin"
# }

# variable "sql_sku" {
#     type = string
#     default = "GP_S_Gen5_4"
# }

# variable "sql_db_auto_pause" {
#     type = number
#     default = 60
# }

# variable "sql_max_db_size" {
#     type = number
#     default = 200
# }

# variable "sql_min_capacity" {
#     type = number
#     default = 1.25
# }

# variable "kv_users" {
#     type = list
#     default = []
# }
