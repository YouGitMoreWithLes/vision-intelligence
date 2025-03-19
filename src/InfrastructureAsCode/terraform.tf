terraform {
  
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.23.0"
    }

    github = {
      source  = "integrations/github"
      version = ">= 6.5.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tf-state-rg"
    storage_account_name = "satfstateexample"
    container_name       = "ivi-tfstate"
    key                  = "dev.terraform.tfstate"
  }
}