### Environment ###
environment = "dev"

### Resource group ###


# Resource group location
module_resource_group_resource_location = "southeastasia"

# Resource group prefix name
module_resource_group_resource_name_prefix = "dev_rg"



### Key vault ###


# Name of the key vault
module_key_vault_vault_name = "dev-key-vault-shin-21"

# SKU of key vault
# Must be one of ['standard','premium']
module_key_vault_vault_sku_name = "standard"

# The days to retain deleted vaults
# This value can be between 7 and 90 (days)
module_key_vault_vault_soft_delete_retention_days = 7

# Whether to enable purge protection for the vault
# This value can be a boolean value: True of False
module_key_vault_vault_purge_protection = false

# MSI ID
# The Managed Service Identity ID. If this value isn't null (the default), 'data.azurerm_client_config.current.object_id' will be set to this value
module_key_vault_msi_id = ""


# # Name of key
# vault_key_name = ""

# Key permissions 
# Include ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]
module_key_vault_vault_access_policy_key_permissions = ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]

# Secret permissions 
# Include ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
module_key_vault_vault_access_policy_secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]

# Certificates permissions 
# Include ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
module_key_vault_vault_access_policy_certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]

### Databricks workspace variables ###


# Name of the databrick workspace
module_architecture_var_databrick_workspace_name = "dev-databrick-2153"

# SKU of databrick workspace
# Must be one of ['standard','premium']
module_architecture_var_databrick_workspace_sku_name = "premium"

# Name of the cluster
module_databrick_cluster_name = "dev-cluster"

# Instance pools idle min
module_databrick_pool_min_idle_instances = 0

# Instance pools max capacity
module_databrick_pool_max_capacity = 3

# Instance pools autotermination minutes
module_databrick_pool_autotermination_minutes = 0

# Cluster autotermination minutes
module_databrick_cluster_autotermination_minutes = 10
### Data factory variables ###

# Name of the data factory
module_architecture_var_data_factory_name = "dev-datafactory-2154"

# Data factory access policy secret permissions to key vault
module_data_factory_access_policy_key_vault = ["List", "Get"]

# Github configuration
module_architecture_var_data_factory_github_config_account_name       = "ShinVu"
module_architecture_var_data_factory_github_config_branch_name        = "main"
module_architecture_var_data_factory_github_config_git_url            = "https://github.com"
module_architecture_var_data_factory_github_config_publishing_enabled = true
module_architecture_var_data_factory_github_config_repository_name    = "sale_analytic_azure_factory"
module_architecture_var_data_factory_github_config_root_folder        = "/"

### Storage account variables ### 
# Name of the storage account
module_architecture_storage_account_name = "devstorageshin"

# Tier of the storage account 
module_architecture_storage_account_tier = "Standard"

# Replication of the storage account
module_architecture_storage_account_replication_type = "LRS"

# Whether HNS is enabled
module_architecture_storage_account_is_hns_enabled = true

# Name of the storage account for unity catalog
module_architecture_storage_account_unity_catalog_name = "devstorageshinunity"