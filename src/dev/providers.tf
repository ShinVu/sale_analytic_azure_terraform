terraform {
  required_providers {
    #AzureRM provider for interacting with Azure
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    #Databricks provider for interacting with azure databricks
    databricks = {
      source = "databricks/databricks"
    }
    #Random provider for generating random values
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

# Define additional feature for azurerm provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true  ## Whether to purge on destroy. Should only be set to true in development environment
      recover_soft_deleted_key_vaults = false ## Whether to recover soft-deleted key vault if the name instance matched.
    }
  }
}

# Define host URL for databricks provider
provider "databricks" {
  host = module.architecture.databrick_workspace_url
}
