
# Generate a random string for azure data factory name
resource "random_string" "azurerm_data_factory_name" {
  length  = 13    #String of length 13 characters
  lower   = true  #String should be lowercase
  numeric = false #String should not container numeric character
  special = false #String should not contain special character
  upper   = false #String should not contain uppercase character
}

# Generate a random string for azure integration runtime name
resource "random_string" "azurerm_data_factory_integration_name" {
  length  = 13    #String of length 13 characters
  lower   = true  #String should be lowercase
  numeric = false #String should not container numeric character
  special = false #String should not contain special character
  upper   = false #String should not contain uppercase character
}
# Generate a random string for azure databrick workspace name
resource "random_string" "azurerm_data_workspace_name" {
  length  = 13    #String of length 13 characters
  lower   = true  #String should be lowercase
  numeric = false #String should not container numeric character
  special = false #String should not contain special character
  upper   = false #String should not contain uppercase character
}

resource "azurerm_data_factory" "data_factory" {
  name                = coalesce(var.var_data_factory_name, "data-factory-${random_string.azurerm_data_factory_name.result}")
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "data_factory_integration_runtime" {
  name            = coalesce(var.integration_runtime_name, "data-integration-${random_string.azurerm_data_factory_integration_name.result}")
  data_factory_id = azurerm_data_factory.data_factory.id
}

resource "azurerm_databricks_workspace" "databrick_workspace" {
  name                = coalesce(var.var_databrick_workspace_name, "databrick-${random_string.azurerm_data_workspace_name.result}")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = var.var_databrick_workspace_sku_name
}
