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
    type = "UserAssigned"
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



# Create storage account  
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