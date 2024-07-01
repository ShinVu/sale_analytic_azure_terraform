# Set up data for databrick instance

# Get information about the current user (current user or service principal)
data "databricks_current_user" "current_user" {
}

# Get information about the current support spark runtime that fits search criteria
data "databricks_spark_version" "latest" {
  long_term_support = true
}

# Gets the smallest node type for databricks_cluster that fits search criteria
data "databricks_node_type" "smallest" {
  local_disk = true
}

# # Create databricks secret that is backed by azure key vault
# Removed to move to Unity Catalog
# resource "databricks_secret_scope" "key_vault_managed" {
#   name = "keyvault-managed"

#   keyvault_metadata {
#     resource_id = var.key_vault_id
#     dns_name    = var.key_vault_uri
#   }
# }


# Create databricks metastore
resource "databricks_metastore" "databricks_metastore" {
  name = "primary"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    var.storage_container_unity_catalog_name,
  var.storage_account_unity_catalog_name)
  owner         = data.databricks_current_user.current_user.user_name
  region        = var.resource_group_location
  force_destroy = true
}

# Assign metastore to workspace
resource "databricks_metastore_assignment" "databricks_metastore_assignment" {
  metastore_id = databricks_metastore.databricks_metastore.id
  workspace_id = var.databrick_workspace_workspace_id
}

# Use managed identity as credentials
resource "databricks_metastore_data_access" "this" {
  metastore_id = databricks_metastore.databricks_metastore.id
  name         = "managed_identity_metastore"

  azure_managed_identity {
    access_connector_id = var.databrick_connector_unity_catalog_id
    managed_identity_id = var.databrick_managed_identity_catalog_id
  }

  is_default = true
  depends_on = [
    databricks_metastore_assignment.databricks_metastore_assignment
  ]
}

# Grant bronze layer storage credential 
resource "databricks_storage_credential" "bronze_layer_credential" {
  name = "bronze_layer_storage_credential"
  azure_managed_identity {
    access_connector_id = var.databrick_connector_bronze_storage_id
    managed_identity_id = var.databrick_managed_identity_bronze_storage_id
  }
  depends_on = [
    databricks_metastore_assignment.databricks_metastore_assignment
  ]
}

# Grant silver layer storage credential 
resource "databricks_storage_credential" "silver_layer_credential" {
  name = "silver_layer_storage_credential"
  azure_managed_identity {
    access_connector_id = var.databrick_connector_silver_storage_id
    managed_identity_id = var.databrick_managed_identity_silver_storage_id
  }
  depends_on = [
    databricks_metastore_assignment.databricks_metastore_assignment
  ]
}

# Grant gold layer storage credential 
resource "databricks_storage_credential" "gold_layer_credential" {
  name = "gold_layer_storage_credential"
  azure_managed_identity {
    access_connector_id = var.databrick_connector_gold_storage_id
    managed_identity_id = var.databrick_managed_identity_gold_storage_id
  }
  depends_on = [
    databricks_metastore_assignment.databricks_metastore_assignment
  ]
}

# Create external location to bronze storage
resource "databricks_external_location" "bronze_layer" {
  name = "bronze_layer_external"
  url = format("abfss://%s@%s.dfs.core.windows.net",
    var.bronze_container_storage_account_name,
  var.storage_account_name)
  credential_name = databricks_storage_credential.bronze_layer_credential.id
  depends_on = [
    databricks_metastore_assignment.databricks_metastore_assignment
  ]
}


# Create external location to silver storage
resource "databricks_external_location" "silver_layer" {
  name = "silver_layer_external"
  url = format("abfss://%s@%s.dfs.core.windows.net",
    var.silver_container_storage_account_name,
  var.storage_account_name)
  credential_name = databricks_storage_credential.silver_layer_credential.id
  depends_on = [
    databricks_metastore_assignment.databricks_metastore_assignment
  ]
}

# Create external location to gold storage
resource "databricks_external_location" "gold_layer" {
  name = "gold_layer_external"
  url = format("abfss://%s@%s.dfs.core.windows.net",
    var.gold_container_storage_account_name,
  var.storage_account_name)
  credential_name = databricks_storage_credential.gold_layer_credential.id
  depends_on = [
    databricks_metastore_assignment.databricks_metastore_assignment
  ]
}

# Create a catalog 
resource "databricks_catalog" "sandbox" {
  name    = "sandbox"
  comment = "this catalog is managed by terraform"
  properties = {
    purpose = "dev"
  }
  depends_on = [databricks_metastore_assignment.databricks_metastore_assignment]
}

# Create a schema
resource "databricks_schema" "sandbox_default" {
  catalog_name = databricks_catalog.sandbox.id
  name         = "default"
  properties = {
    kind = "various"
  }
}

# Create a volume to bronze layer
resource "databricks_volume" "sandbox_default_bronze_layer" {
  name             = "bronze_layer"
  catalog_name     = databricks_catalog.sandbox.name
  schema_name      = databricks_schema.sandbox_default.name
  volume_type      = "EXTERNAL"
  storage_location = databricks_external_location.bronze_layer.url
  comment          = "this volume is managed by terraform"
}

# Create a volume to silver layer
resource "databricks_volume" "sandbox_default_silver_layer" {
  name             = "silver_layer"
  catalog_name     = databricks_catalog.sandbox.name
  schema_name      = databricks_schema.sandbox_default.name
  volume_type      = "EXTERNAL"
  storage_location = databricks_external_location.silver_layer.url
  comment          = "this volume is managed by terraform"
}

# Create a volume to gold layer
resource "databricks_volume" "sandbox_default_gold_layer" {
  name             = "gold_layer"
  catalog_name     = databricks_catalog.sandbox.name
  schema_name      = databricks_schema.sandbox_default.name
  volume_type      = "EXTERNAL"
  storage_location = databricks_external_location.gold_layer.url
  comment          = "this volume is managed by terraform"
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
  depends_on                            = [databricks_metastore_assignment.databricks_metastore_assignment]
}

# Create a base databricks cluster for exploration,...
resource "databricks_cluster" "databrick_cluster" {
  cluster_name            = var.cluster_name
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
  depends_on = [databricks_metastore_assignment.databricks_metastore_assignment]
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
  depends_on = [databricks_metastore_assignment.databricks_metastore_assignment]
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
  depends_on = [databricks_metastore_assignment.databricks_metastore_assignment]
}

data "databricks_group" "admin" {
  display_name = "admins" // existing admin group in databricks workspace
}

resource "databricks_service_principal" "sp" {
  application_id = var.managed_identity_adf_client_id
  display_name   = "adf_id"
}

resource "databricks_group_member" "admin_group" {
  group_id  = data.databricks_group.admin.id
  member_id = databricks_service_principal.sp.id
}