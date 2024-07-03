# Set up data for databrick instance

locals {
  databrick_workspace_id = var.databrick_workspace_id
}

# Get information about the current user (current user or service principal)
data "databricks_current_user" "current_user" {
  provider   = databricks.workspace
  depends_on = [local.databrick_workspace_id]
}

# Get information about the current support spark runtime that fits search criteria
data "databricks_spark_version" "latest" {
  long_term_support = true
  provider          = databricks.workspace
  depends_on        = [local.databrick_workspace_id]
}

# Gets the smallest node type for databricks_cluster that fits search criteria
data "databricks_node_type" "smallest" {
  local_disk = true
  provider   = databricks.workspace
  depends_on = [local.databrick_workspace_id]
}

# # # Create databricks secret that is backed by azure key vault
# # Removed to move to Unity Catalog
# # resource "databricks_secret_scope" "key_vault_managed" {
# #   name = "keyvault-managed"

# #   keyvault_metadata {
# #     resource_id = var.key_vault_id
# #     dns_name    = var.key_vault_uri
# #   }
# # }


# Create databricks metastore
# resource "databricks_metastore" "databricks_metastore" {
#   provider = databricks.account
#   name     = "primary"
#   storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
#     var.storage_container_unity_catalog_name,
#   var.storage_account_unity_catalog_name)
#   owner         = data.databricks_current_user.current_user.user_name
#   region        = var.resource_group_location
#   force_destroy = true
# }
# # Assign metastore to workspace
# resource "databricks_metastore_assignment" "databricks_metastore_assignment" {
#   metastore_id = databricks_metastore.databricks_metastore.id
#   workspace_id = var.databrick_workspace_workspace_id
# }
# # Use managed identity as credentials
# resource "databricks_metastore_data_access" "this" {
#   metastore_id = databricks_metastore.databricks_metastore.id
#   name         = "managed_identity_metastore"

#   azure_managed_identity {
#     access_connector_id = var.databrick_connector_unity_catalog_id
#     managed_identity_id = var.databrick_managed_identity_catalog_id
#   }

#   is_default = true
#   depends_on = [
#     databricks_metastore_assignment.databricks_metastore_assignment
#   ]
# }

# Because limitation of 1 metastore per region of databricks account, resolve to using the default created metastore for the workspace
data "databricks_current_metastore" "default_workspace" {
  provider   = databricks.workspace
  depends_on = [local.databrick_workspace_id]
}

# Grant sandbox catalog storage credential
resource "databricks_storage_credential" "sandbox_catalog_credential" {
  name = "sandbox_catalog_credential"
  azure_managed_identity {
    access_connector_id = var.databrick_connector_unity_catalog_id
    managed_identity_id = var.databrick_managed_identity_catalog_id
  }
  provider = databricks.workspace
}

# Grant bronze layer storage credential 
resource "databricks_storage_credential" "bronze_layer_credential" {
  name = "bronze_layer_storage_credential"
  azure_managed_identity {
    access_connector_id = var.databrick_connector_bronze_storage_id
    managed_identity_id = var.databrick_managed_identity_bronze_storage_id
  }
  provider = databricks.workspace
}

# Grant silver layer storage credential 
resource "databricks_storage_credential" "silver_layer_credential" {
  name = "silver_layer_storage_credential"
  azure_managed_identity {
    access_connector_id = var.databrick_connector_silver_storage_id
    managed_identity_id = var.databrick_managed_identity_silver_storage_id
  }
  provider = databricks.workspace
}

# Grant gold layer storage credential 
resource "databricks_storage_credential" "gold_layer_credential" {
  name = "gold_layer_storage_credential"
  azure_managed_identity {
    access_connector_id = var.databrick_connector_gold_storage_id
    managed_identity_id = var.databrick_managed_identity_gold_storage_id
  }
  provider = databricks.workspace
}

# Create external location to sandbox catalog storage
resource "databricks_external_location" "sandbox_catalog" {
  name = "sandbox_external"
  url = format("abfss://%s@%s.dfs.core.windows.net",
    var.storage_container_unity_catalog_name,
  var.storage_account_unity_catalog_name)
  credential_name = databricks_storage_credential.sandbox_catalog_credential.id
  provider        = databricks.workspace
}

# Create external location to bronze storage
resource "databricks_external_location" "bronze_layer" {
  name = "bronze_layer_external"
  url = format("abfss://%s@%s.dfs.core.windows.net",
    var.bronze_container_storage_account_name,
  var.storage_account_name)
  credential_name = databricks_storage_credential.bronze_layer_credential.id
  provider        = databricks.workspace
}


# Create external location to silver storage
resource "databricks_external_location" "silver_layer" {
  name = "silver_layer_external"
  url = format("abfss://%s@%s.dfs.core.windows.net",
    var.silver_container_storage_account_name,
  var.storage_account_name)
  credential_name = databricks_storage_credential.silver_layer_credential.id
  provider        = databricks.workspace
}

# Create external location to gold storage
resource "databricks_external_location" "gold_layer" {
  name = "gold_layer_external"
  url = format("abfss://%s@%s.dfs.core.windows.net",
    var.gold_container_storage_account_name,
  var.storage_account_name)
  credential_name = databricks_storage_credential.gold_layer_credential.id
  provider        = databricks.workspace
}

# Create a catalog 
resource "databricks_catalog" "sandbox" {
  name         = "sandbox"
  storage_root = databricks_external_location.sandbox_catalog.url
  comment      = "this catalog is managed by terraform"
  properties = {
    purpose = "dev"
  }
  provider = databricks.workspace
}

# Create a schema
resource "databricks_schema" "sandbox_default" {
  catalog_name = databricks_catalog.sandbox.id
  name         = "default"
  properties = {
    kind = "various"
  }
  provider = databricks.workspace
}

# Create a volume to bronze layer
resource "databricks_volume" "sandbox_default_bronze_layer" {
  name             = "bronze_layer"
  catalog_name     = databricks_catalog.sandbox.name
  schema_name      = databricks_schema.sandbox_default.name
  volume_type      = "EXTERNAL"
  storage_location = databricks_external_location.bronze_layer.url
  comment          = "this volume is managed by terraform"
  provider         = databricks.workspace
}

# Create a volume to silver layer
resource "databricks_volume" "sandbox_default_silver_layer" {
  name             = "silver_layer"
  catalog_name     = databricks_catalog.sandbox.name
  schema_name      = databricks_schema.sandbox_default.name
  volume_type      = "EXTERNAL"
  storage_location = databricks_external_location.silver_layer.url
  comment          = "this volume is managed by terraform"
  provider         = databricks.workspace
}

# Create a volume to gold layer
resource "databricks_volume" "sandbox_default_gold_layer" {
  name             = "gold_layer"
  catalog_name     = databricks_catalog.sandbox.name
  schema_name      = databricks_schema.sandbox_default.name
  volume_type      = "EXTERNAL"
  storage_location = databricks_external_location.gold_layer.url
  comment          = "this volume is managed by terraform"
  provider         = databricks.workspace
}

## Create cluster, instance pools after workspace is assigned to metastore

# Create databrick instance pool
resource "databricks_instance_pool" "smallest_nodes" {
  instance_pool_name = "dev-pool-(${data.databricks_current_user.current_user.alphanumeric})"
  min_idle_instances = var.pool_autotermination_minutes
  max_capacity       = var.pool_max_capacity
  node_type_id       = data.databricks_node_type.smallest.id
  preloaded_spark_versions = [
    data.databricks_spark_version.latest.id
  ]

  idle_instance_autotermination_minutes = var.pool_autotermination_minutes
  provider                              = databricks.workspace
}


# Create a databricks cluster for ADF linked services
resource "databricks_cluster" "databrick_adf_cluster" {
  cluster_name            = "adf_cluster"
  spark_version           = data.databricks_spark_version.latest.id
  instance_pool_id        = databricks_instance_pool.smallest_nodes.id
  autotermination_minutes = var.cluster_autotermination_minutes
  spark_conf = {
    # Single-node
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }
  data_security_mode = "SINGLE_USER"
  custom_tags = {
    "ResourceClass" = "SingleNode"
  }
  provider = databricks.workspace
}


# Create databricks cluster policy
resource "databricks_cluster_policy" "databricks_cluster_policy" {
  name = "dev-minimal-(${data.databricks_current_user.current_user.alphanumeric})"
  definition = jsonencode({
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 10
    },
    "autotermination_minutes" : {
      "type" : "fixed",
      "value" : 10,
      "hidden" : true
    }
  })
  provider = databricks.workspace
}

