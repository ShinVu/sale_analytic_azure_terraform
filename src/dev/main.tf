# Use the resource_group module
module "resource_group" {
  source = "../modules/resource_group" # Local path to module resource group

  environment = var.environment # Current environment 
  location    = var.module_resource_group_resource_location
  prefix      = var.module_resource_group_resource_name_prefix
}

module "key_vault" {
  source = "../modules/key_vault" # Local path to module key_vault

  # Variables defined in dev- terraform.tfvars
  environment = var.environment # Current environment 

  vault_name                                  = var.module_key_vault_vault_name
  vault_sku_name                              = var.module_key_vault_vault_sku_name
  vault_soft_delete_retention_days            = var.module_key_vault_vault_soft_delete_retention_days
  vault_purge_protection                      = var.module_key_vault_vault_purge_protection
  vault_access_policy_key_permissions         = var.module_key_vault_vault_access_policy_key_permissions
  vault_access_policy_secret_permissions      = var.module_key_vault_vault_access_policy_secret_permissions
  vault_access_policy_certificate_permissions = var.module_key_vault_vault_access_policy_certificate_permissions
  vault_secret_db_user                        = var.module_key_vault_vault_secret_db_user
  vault_secret_db_pass                        = var.module_key_vault_vault_secret_db_pass
  # Variables from the module resource_group output
  resource_group_location = module.resource_group.resource_group_location
  resource_group_name     = module.resource_group.resource_group_name
}

module "architecture" {
  source = "../modules/architecture" # Local path to module architecture

  environment = var.environment # Current environment 
  # Data factory 
  var_data_factory_name                    = var.module_architecture_var_data_factory_name
  var_data_factory_access_policy_key_vault = var.module_data_factory_access_policy_key_vault
  # Data factory github configuration 
  var_data_factory_github_config_account_name       = var.module_architecture_var_data_factory_github_config_account_name
  var_data_factory_github_config_branch_name        = var.module_architecture_var_data_factory_github_config_branch_name
  var_data_factory_github_config_git_url            = var.module_architecture_var_data_factory_github_config_git_url
  var_data_factory_github_config_publishing_enabled = var.module_architecture_var_data_factory_github_config_publishing_enabled
  var_data_factory_github_config_repository_name    = var.module_architecture_var_data_factory_github_config_repository_name
  var_data_factory_github_config_root_folder        = var.module_architecture_var_data_factory_github_config_root_folder
  # Databrick
  var_databrick_workspace_name     = var.module_architecture_var_databrick_workspace_name
  var_databrick_workspace_sku_name = var.module_architecture_var_databrick_workspace_sku_name
  # Storage account Datalake gen2 
  var_storage_account_name         = var.module_architecture_storage_account_name
  storage_account_replication_type = var.module_architecture_storage_account_replication_type
  storage_account_tier             = var.module_architecture_storage_account_tier
  storage_account_is_hns_enabled   = var.module_architecture_storage_account_is_hns_enabled
  # Storage account Datalake gen2 Unity catalog
  storage_account_unity_catalog_name = var.module_architecture_storage_account_unity_catalog_name
  # Variables from the module resource_group output
  resource_group_location = module.resource_group.resource_group_location
  resource_group_name     = module.resource_group.resource_group_name
  # Variables from the module key_vault output
  key_vault_id = module.key_vault.vault_id
  vault_uri    = module.key_vault.vault_uri
}

module "databricks" {
  source = "../modules/databricks" # Local path to module databricks

  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
  }

  # Variables from the module key_vault output
  key_vault_id  = module.key_vault.vault_id
  key_vault_uri = module.key_vault.vault_uri

  # Variables from the module resource_group output
  resource_group_location = module.resource_group.resource_group_location
  resource_group_name     = module.resource_group.resource_group_name

  # Variables for clusters
  cluster_name = var.module_databrick_cluster_name

  # Variables for databrick instances
  databrick_workspace_id           = module.architecture.databrick_workspace_id
  databrick_workspace_id           = module.architecture.databrick_workspace_id
  databrick_workspace_workspace_id = module.architecture.databrick_workspace_workspace_id
  # Variables for instance pools 
  pool_min_idle_instances         = var.module_databrick_pool_min_idle_instances
  pool_max_capacity               = var.module_databrick_pool_max_capacity
  pool_autotermination_minutes    = var.module_databrick_pool_autotermination_minutes
  cluster_autotermination_minutes = var.module_databrick_cluster_autotermination_minutes

  # Variables for unity catalog storage
  storage_account_unity_catalog_name   = module.architecture.storage_account_unity_catalog_name
  storage_container_unity_catalog_name = module.architecture.storage_container_unity_catalog_name

  #Variables for storage account
  storage_account_name = module.architecture.storage_account_name

  #Variables for bronze, silver, gold filesystem
  bronze_container_storage_account_name = module.architecture.bronze_container_storage_account_name
  silver_container_storage_account_name = module.architecture.silver_container_storage_account_name
  gold_container_storage_account_name   = module.architecture.gold_container_storage_account_name
  # Variables for databricks connector to bronze storage container 
  databrick_connector_bronze_storage_id        = module.architecture.databrick_connector_mi_databrick_bronze_reader_group_id
  databrick_managed_identity_bronze_storage_id = module.architecture.managed_identity_databrick_bronze_reader_group_id

  # Variables for databricks connector to silver storage container 
  databrick_connector_silver_storage_id        = module.architecture.databrick_connector_mi_databrick_silver_contributor_group_id
  databrick_managed_identity_silver_storage_id = module.architecture.managed_identity_databrick_silver_contributor_group_id

  # Variables for databricks connector to silver storage container 
  databrick_connector_gold_storage_id        = module.architecture.databrick_connector_mi_databrick_gold_contributor_group_id
  databrick_managed_identity_gold_storage_id = module.architecture.managed_identity_databrick_gold_contributor_group_id

  # Variables for databricks connector
  databrick_connector_unity_catalog_id  = module.architecture.databrick_connector_unity_catalog_id
  databrick_managed_identity_catalog_id = module.architecture.managed_identity_unity_catalog_id

  # Variables for managed identity ADF
  managed_identity_adf_client_id = module.architecture.managed_identity_adf_client_id
}


module "active_directory" {
  source = "../modules/active_directory" # Local path to module active_directory
}
