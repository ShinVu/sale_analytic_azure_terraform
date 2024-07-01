output "databrick_workspace_id" {
  description = "ID of the workspace"
  value       = azurerm_databricks_workspace.databrick_workspace.id
}
output "databrick_workspace_url" {
  description = "Url of the workspace"
  value       = azurerm_databricks_workspace.databrick_workspace.workspace_url
}

output "databrick_workspace_workspace_id" {
  description = "Workspace ID of the workspace"
  value       = azurerm_databricks_workspace.databrick_workspace.workspace_id
}

#Output databrick connector id for unity catalog storage

output "databrick_connector_unity_catalog_id" {
  description = "Id of Databrick access connector"
  value       = azurerm_databricks_access_connector.databrick_connector_unity_catalog.id
}

#Output manged identity linked to the databrick connector
output "managed_identity_unity_catalog_id" {
  description = "Id of Managed identity of the unity catalog "
  value       = azurerm_user_assigned_identity.storage_unity_catalog.id
}

#Output managed identity linked to adf
output "managed_identity_adf_client_id" {
  description = "Client id of Manged identity"
  value = azurerm_user_assigned_identity.adf_databrick_identity.client_id
}

#Output the storage account and container for the databrick unity catalog

output "storage_account_unity_catalog_name" {
  description = "name of the storage account for unity catalog"
  value       = azurerm_storage_account.storage_account_unity_catalog.name
}

output "storage_container_unity_catalog_name" {
  description = "name of the storage container for unity catalog"
  value       = azurerm_storage_data_lake_gen2_filesystem.metastore_storage.name
}


# Output storage account that container bronze, silver. gold container
output "storage_account_name" {
  description = "name of the storage account"
  value       = azurerm_storage_account.storage_account.name
}

# Output bronze container of storage account
output "bronze_container_storage_account_name" {
  description = "name of the bronze filesystem"
  value       = azurerm_storage_data_lake_gen2_filesystem.bronze_layer.name
}
# Output silver container of storage account
output "silver_container_storage_account_name" {
  description = "name of the silver filesystem"
  value       = azurerm_storage_data_lake_gen2_filesystem.silver_layer.name
}
# Output bronze container of storage account
output "gold_container_storage_account_name" {
  description = "name of the gold filesystem"
  value       = azurerm_storage_data_lake_gen2_filesystem.gold_layer.name
}
### Bronze layer storage ###

## Databrick required output for datalog ##
#Output databrick connector id for unity catalog storage

output "databrick_connector_mi_databrick_bronze_reader_group_id" {
  description = "Id of Databrick access connector"
  value       = azurerm_databricks_access_connector.databrick_connector_mi_databrick_bronze_reader_group.id
}

#Output manged identity linked to the databrick connector
output "managed_identity_databrick_bronze_reader_group_id" {
  description = "Id of Managed identity databrick_bronze_reader_group "
  value       = azurerm_user_assigned_identity.databrick_bronze_reader_group.id
}

#Output filesystem name


### Silver layer storage ###

## Databrick required output for datalog ##
#Output databrick connector id for unity catalog storage

output "databrick_connector_mi_databrick_silver_contributor_group_id" {
  description = "Id of Databrick access connector"
  value       = azurerm_databricks_access_connector.databrick_connector_mi_databrick_silver_contributor_group.id
}

#Output manged identity linked to the databrick connector
output "managed_identity_databrick_silver_contributor_group_id" {
  description = "Id of Managed identity databrick_silver_contributor_group"
  value       = azurerm_user_assigned_identity.databrick_silver_contributor_group.id
}

### Gold layer storage ###

## Databrick required output for datalog ##
#Output databrick connector id for unity catalog storage

output "databrick_connector_mi_databrick_gold_contributor_group_id" {
  description = "Id of Databrick access connector"
  value       = azurerm_databricks_access_connector.databrick_connector_mi_databrick_gold_contributor_group.id
}

#Output manged identity linked to the databrick connector
output "managed_identity_databrick_gold_contributor_group_id" {
  description = "Id of Managed identity databrick_gold_contributor_group"
  value       = azurerm_user_assigned_identity.databrick_gold_contributor_group.id
}
