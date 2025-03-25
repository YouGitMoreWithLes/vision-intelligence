provider "azurerm" {
  subscription_id = var.subscriptionId
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# provider "databricks" {
#     azure_workspace_resource_id = azurerm_databricks_workspace.dbw[0].id
# }

# provider "github" {
#   token = ""
#   owner = "YouGitMoreWithLes-Insight"
# }
