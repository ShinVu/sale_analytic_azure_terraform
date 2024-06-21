terraform {
  required_providers {
    #AzureRM provider for interacting with Azure
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
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
  features {}
}