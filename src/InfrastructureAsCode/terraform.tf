terraform {
  
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.23.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.1.0"
    }
        
    databricks = {
        source  = "databricks/databricks"
        version = ">=1.70.0"
    }

    null_resource = {
        source  = "hashicorp/null"
        version = ">=3.2.3"
    }

    # github = {
    #   source  = "integrations/github"
    #   version = ">= 6.5.0"
    # }
  }

  backend "azurerm" {
    resource_group_name  = "tf-state-rg"
    storage_account_name = "ghatfstatesa"
    container_name       = "insight-vi-tfstate"
    key                  = "dev.tfstate"
  }
}
