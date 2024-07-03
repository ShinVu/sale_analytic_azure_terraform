# Reference current azurerm_client_config
data "azurerm_client_config" "current" {}

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

# Create a data factory instance
resource "azurerm_data_factory" "data_factory" {
  name                = coalesce(var.var_data_factory_name, "data-factory-${random_string.azurerm_data_factory_name.result}")
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.data_factory_bronze_container.id,
      azurerm_user_assigned_identity.data_factory_key_vault.id,
      azurerm_user_assigned_identity.adf_databrick_identity.id
    ]
  }
  dynamic "github_configuration" {
    for_each = (var.environment == "dev" ? [1] : [])
    content {
      account_name       = var.environment == "dev" ? var.var_data_factory_github_config_account_name : null
      branch_name        = var.environment == "dev" ? var.var_data_factory_github_config_branch_name : null
      git_url            = var.environment == "dev" ? var.var_data_factory_github_config_git_url : null
      repository_name    = var.environment == "dev" ? var.var_data_factory_github_config_repository_name : null
      root_folder        = var.environment == "dev" ? var.var_data_factory_github_config_root_folder : null
      publishing_enabled = var.environment == "dev" ? var.var_data_factory_github_config_publishing_enabled : null
    }
  }
}


# Create a managed identity for data factory to access key vault
resource "azurerm_user_assigned_identity" "data_factory_key_vault" {
  location            = var.resource_group_location
  name                = "data_factory_key_vault_identity"
  resource_group_name = var.resource_group_name
}

# Create a managed identity for data factory to access bronze storage container 
resource "azurerm_user_assigned_identity" "data_factory_bronze_container" {
  location            = var.resource_group_location
  name                = "data_factory_bronze_container_identity"
  resource_group_name = var.resource_group_name
}

# Create a group that have List/Get access to secrets in Key vault 
# Create a group in EntraID
resource "azuread_group" "secret_key_vault" {
  display_name     = "secret_key_vault"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}

# Add managed identity data_factory_key_vault to group
resource "azuread_group_member" "data_factory_key_vault_group_secret_key_vault" {
  group_object_id  = azuread_group.secret_key_vault.id
  member_object_id = azurerm_user_assigned_identity.data_factory_key_vault.principal_id
}

# Grant List/Get access to group secret_key_vault 
resource "azurerm_key_vault_access_policy" "secret_key_vault" {
  key_vault_id       = var.key_vault_id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = azuread_group.secret_key_vault.object_id
  secret_permissions = var.var_data_factory_access_policy_key_vault
}

### Data factory resources ###

## Credentials ##
## Assign necessary credentials to data factory instance ##

# Credential for Key vault managed identity
resource "azurerm_data_factory_credential_user_managed_identity" "data_factory_key_vault_identity_credentials" {
  name            = azurerm_user_assigned_identity.data_factory_key_vault.name
  description     = "Credential for azure data factory to access key vault"
  data_factory_id = azurerm_data_factory.data_factory.id
  identity_id     = azurerm_user_assigned_identity.data_factory_key_vault.id

  annotations = ["Key vault", "Data factory"]
}

# Credential for Bronze container managed identity
resource "azurerm_data_factory_credential_user_managed_identity" "data_factory_bronze_container_identity_credentials" {
  name            = azurerm_user_assigned_identity.data_factory_bronze_container.name
  description     = "Credential for azure data factory to access bronze container"
  data_factory_id = azurerm_data_factory.data_factory.id
  identity_id     = azurerm_user_assigned_identity.data_factory_bronze_container.id

  annotations = ["Bronze container", "Data factory"]
}

# Credential for Databricks managed identity
resource "azurerm_data_factory_credential_user_managed_identity" "data_factory_databricks_identity_credentials" {
  name            = azurerm_user_assigned_identity.adf_databrick_identity.name
  description     = "Credential for azure data factory to access databricks workspace"
  data_factory_id = azurerm_data_factory.data_factory.id
  identity_id     = azurerm_user_assigned_identity.adf_databrick_identity.id

  annotations = ["Databricks workspace", "Data factory"]
}

## Integration runtime ##
# Create an self hosted integration runtime to copy data from on premise database #
resource "azurerm_data_factory_integration_runtime_self_hosted" "self_hosted_integration_runtime" {
  name            = "self-hosted-integration-runtime"
  data_factory_id = azurerm_data_factory.data_factory.id
}

## Linked services ##
# Create linked services to data sources and compute #

# Use custom linked service because azurerm_data_factory_linked_service_key_vault doesn't support UMI yet
# Ideally, azurerm_data_factory_linked_service_key_vault should have been used. Azurerm 3.104.2 and below does not support setting user managed identity so we use a custom linked service for now.
resource "azurerm_data_factory_linked_custom_service" "linked_services_key_vault_custom" {
  name                 = "linked_services_key_vault_custom"
  data_factory_id      = azurerm_data_factory.data_factory.id
  type                 = "AzureKeyVault"
  type_properties_json = <<JSON
{
  "baseUrl": "${var.vault_uri}",
  "credential": {
    "referenceName": "${azurerm_data_factory_credential_user_managed_identity.data_factory_key_vault_identity_credentials.name}",
    "type": "CredentialReference"
    }      
}
JSON
}

# Linked services to SQL server
resource "azurerm_data_factory_linked_service_sql_server" "linked_servies_sql_server" {
  name            = "sql_server"
  data_factory_id = azurerm_data_factory.data_factory.id

  connection_string = "Integrated Security=False;Data Source=localhost;Initial Catalog=AdventureWorks;User ID=dat;"
  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_custom_service.linked_services_key_vault_custom.name
    secret_name         = "db-password"
  }
}

# Linked services to Data lake gen2
# Ideally, azurerm_data_factory_linked_service_data_lake_storage_gen2 should have been used. Azurerm 3.104.2 and below does not support setting user managed identity so we use a custom linked service for now.

resource "azurerm_data_factory_linked_custom_service" "linked_services_data_lake_storage_gen2_custom" {
  name                 = "linked_services_data_lake_storage_gen2_custom"
  data_factory_id      = azurerm_data_factory.data_factory.id
  type                 = "AzureBlobFS"
  type_properties_json = <<JSON
{
    "url": "${azurerm_storage_account.storage_account.primary_dfs_endpoint}", 
    "credential": {
        "referenceName": "${azurerm_data_factory_credential_user_managed_identity.data_factory_bronze_container_identity_credentials.name}",
        "type": "CredentialReference"
    }
}
JSON
}

# Linked services to Databricks
resource "azurerm_data_factory_linked_service_azure_databricks" "linked_services_databricks" {
  name            = "databricks"
  data_factory_id = azurerm_data_factory.data_factory.id
  description     = "ADB Linked Service via MSI"
  adb_domain      = "https://${azurerm_databricks_workspace.databrick_workspace.workspace_url}"

  msi_work_space_resource_id = azurerm_databricks_workspace.databrick_workspace.id

  existing_cluster_id = var.adf_cluster_id
}

# Create a group that have full access to bronze_container 
# Create a group in EntraID
resource "azuread_group" "bronze_writer" {
  display_name     = "bronze_writer"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}

# Add managed identity data_factory_bronze_container to group
resource "azuread_group_member" "data_factory_bronze_container_group_bronze_writer" {
  group_object_id  = azuread_group.bronze_writer.id
  member_object_id = azurerm_user_assigned_identity.data_factory_bronze_container.principal_id
}

# Create a group that have list and read access to bronze_container
# Create a group in EntraID
resource "azuread_group" "bronze_reader" {
  display_name     = "bronze_reader"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}

# Create a group that have full access to silver_container
# Create a group in EntraID
resource "azuread_group" "silver_contributor" {
  display_name     = "silver_contributor"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}

# Create a group that have full access to gold_container
# Create a group in EntraID
resource "azuread_group" "gold_contributor" {
  display_name     = "gold_contributor"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}

# Create a managed identity for ADF to link with Databricks
resource "azurerm_user_assigned_identity" "adf_databrick_identity" {
  location            = var.resource_group_location
  name                = "adf_databrick_identity"
  resource_group_name = var.resource_group_name
}


# Assign Contributor role to managed identity
resource "azurerm_role_assignment" "adf_databrick_role" {
  scope                = azurerm_databricks_workspace.databrick_workspace.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.adf_databrick_identity.principal_id
}

# Assign Contributor role to system managed identity for ADF
# Both UMI and SMI are required for User managed identity or System manged identity to work
# Assign Contributor role to managed identity
resource "azurerm_role_assignment" "adf_system_databrick_role" {
  scope                = azurerm_databricks_workspace.databrick_workspace.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_data_factory.data_factory.identity[0].principal_id
}


resource "azurerm_storage_account" "storage_account" {
  name                     = var.var_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  is_hns_enabled           = var.storage_account_is_hns_enabled
}

# Create filesystem for bronze layer
resource "azurerm_storage_data_lake_gen2_filesystem" "bronze_layer" {
  name               = "bronze-layer"
  storage_account_id = azurerm_storage_account.storage_account.id
  # Bronze writer group should be able to list, read, write from filesystem
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.bronze_writer.object_id
    permissions = "rwx"
  }
  ace {
    scope       = "default"
    type        = "group"
    id          = azuread_group.bronze_writer.object_id
    permissions = "rwx"
  }
  # Bronze reader group should be able to list, read from filesystem
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.bronze_reader.object_id
    permissions = "rwx"
  }
  ace {
    scope       = "default"
    type        = "group"
    id          = azuread_group.bronze_reader.object_id
    permissions = "rwx"
  }
}

# Create filesystem for silver layer
resource "azurerm_storage_data_lake_gen2_filesystem" "silver_layer" {
  name               = "silver-layer"
  storage_account_id = azurerm_storage_account.storage_account.id
  # Silver contributor group should be able to list, read, write from filesystem
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.silver_contributor.object_id
    permissions = "rwx"
  }
  ace {
    scope       = "default"
    type        = "group"
    id          = azuread_group.silver_contributor.object_id
    permissions = "rwx"
  }
}

# Create filesystem for gold layer
resource "azurerm_storage_data_lake_gen2_filesystem" "gold_layer" {
  name               = "gold-layer"
  storage_account_id = azurerm_storage_account.storage_account.id
  # Gold contributor group should be able to list, read, write from filesystem
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.gold_contributor.object_id
    permissions = "rwx"
  }
  ace {
    scope       = "default"
    type        = "group"
    id          = azuread_group.gold_contributor.object_id
    permissions = "rwx"
  }
}

# Generate a random string for azure databrick workspace name
resource "random_string" "azurerm_data_workspace_name" {
  length  = 13    #String of length 13 characters
  lower   = true  #String should be lowercase
  numeric = false #String should not container numeric character
  special = false #String should not contain special character
  upper   = false #String should not contain uppercase character
}

# Create a databrick instance
resource "azurerm_databricks_workspace" "databrick_workspace" {
  name                = coalesce(var.var_databrick_workspace_name, "databrick-${random_string.azurerm_data_workspace_name.result}")
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = var.var_databrick_workspace_sku_name
}

# Create a DLS2 for Unity Catalog
resource "azurerm_storage_account" "storage_account_unity_catalog" {
  name                     = var.storage_account_unity_catalog_name
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  is_hns_enabled           = var.storage_account_is_hns_enabled
}

# Create a storage container that will hold your managed tables and volume data at the metastore level
resource "azurerm_storage_data_lake_gen2_filesystem" "metastore_storage" {
  name               = "metastore-storage"
  storage_account_id = azurerm_storage_account.storage_account_unity_catalog.id

}
# Create a managed identity for Unity Catalog that should have access to DLS2
resource "azurerm_user_assigned_identity" "storage_unity_catalog" {
  location            = var.resource_group_location
  name                = "storage_account_unity_catalog"
  resource_group_name = var.resource_group_name
}

# Assign role assignment Storage blob contributor to the managed identity to access storage account
resource "azurerm_role_assignment" "blob_contributor_unity_catalog" {
  scope                = azurerm_storage_account.storage_account_unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.storage_unity_catalog.principal_id
}

# Assign role assignment Storage Queue Data Contributor to the managed identity to access storage account
resource "azurerm_role_assignment" "queue_contributor_unity_catalog" {
  scope                = azurerm_storage_account.storage_account_unity_catalog.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_user_assigned_identity.storage_unity_catalog.principal_id
}

# Create a Databrick access connector
resource "azurerm_databricks_access_connector" "databrick_connector_unity_catalog" {
  name                = "databrick_connector_unity_catalog"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage_unity_catalog.id]
  }

  tags = {
    Environment = "dev"
  }
}

# Create a managed identity that belongs to group bronze_reader
# This will be used for databrick to access data
resource "azurerm_user_assigned_identity" "databrick_bronze_reader_group" {
  location            = var.resource_group_location
  name                = "databrick_bronze_reader_group"
  resource_group_name = var.resource_group_name
}

# Add managed identity databrick_bronze_writer_group to bronze_reader group
resource "azuread_group_member" "databrick_bronze_reader_group_bronze_reader" {
  group_object_id  = azuread_group.bronze_reader.object_id
  member_object_id = azurerm_user_assigned_identity.databrick_bronze_reader_group.principal_id
}

# Create a Databrick access connector for this managed identity
resource "azurerm_databricks_access_connector" "databrick_connector_mi_databrick_bronze_reader_group" {
  name                = "databrick_connector_mi_databrick_bronze_reader_group"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.databrick_bronze_reader_group.id]
  }

  tags = {
    Environment = "dev"
  }
}

# Create a managed identity that belongs to group silver_contributor
# This will be used for databrick to access data
resource "azurerm_user_assigned_identity" "databrick_silver_contributor_group" {
  location            = var.resource_group_location
  name                = "databrick_silver_contributor_group"
  resource_group_name = var.resource_group_name
}

# Add managed identity databrick_silver_contributor_group to silver_contributor group
resource "azuread_group_member" "databrick_silver_contributor_group_silver_contributor" {
  group_object_id  = azuread_group.silver_contributor.object_id
  member_object_id = azurerm_user_assigned_identity.databrick_silver_contributor_group.principal_id
}

# Create a Databrick access connector for this managed identity
resource "azurerm_databricks_access_connector" "databrick_connector_mi_databrick_silver_contributor_group" {
  name                = "databrick_connector_mi_databrick_silver_contributor_group"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.databrick_silver_contributor_group.id]
  }

  tags = {
    Environment = "dev"
  }
}


# Create a managed identity that belongs to group gold_contributor
# This will be used for databrick to access data
resource "azurerm_user_assigned_identity" "databrick_gold_contributor_group" {
  location            = var.resource_group_location
  name                = "databrick_gold_contributor_group"
  resource_group_name = var.resource_group_name
}

# Add managed identity databrick_gold_contributor_group to gold_contributor group
resource "azuread_group_member" "databrick_gold_contributor_group_gold_contributor" {
  group_object_id  = azuread_group.gold_contributor.object_id
  member_object_id = azurerm_user_assigned_identity.databrick_gold_contributor_group.principal_id
}

# Create a Databrick access connector for this managed identity
resource "azurerm_databricks_access_connector" "databrick_connector_mi_databrick_gold_contributor_group" {
  name                = "databrick_connector_mi_databrick_gold_contributor_group"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.databrick_gold_contributor_group.id]
  }

  tags = {
    Environment = "dev"
  }
}

# Create a synapse workspace
resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                = "dev-shin-synapse"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  # Default filesystem to gold_layer
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.gold_layer.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  public_network_access_enabled        = true
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Env = "dev"
  }
}

# Grant admin to workspace
resource "azurerm_synapse_workspace_aad_admin" "example" {
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  login                = "AzureAD Admin"
  object_id            = data.azurerm_client_config.current.object_id
  tenant_id            = data.azurerm_client_config.current.tenant_id
}

# Change firewall rule
resource "azurerm_synapse_firewall_rule" "firewall_rule" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}
