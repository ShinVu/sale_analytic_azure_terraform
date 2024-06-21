### Resource group ###


# Resource group location
module_resource_group_resource_location = "southeastasia"

# Resource group prefix name
module_resource_group_resource_name_prefix = "dev_rg"



### Key vault ###


# Name of the key vault
module_key_vault_vault_name = "dev-key-vault-shin"

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
module_key_vault_vault_access_policy_key_permissions =  ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]

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
module_architecture_var_databrick_workspace_sku_name = "standard"


### Data factory variables ###

# Name of the data factory
module_architecture_var_data_factory_name = "dev-datafactory-2153"

# Name of the integration runtime
module_architecture_var_data_factory_integration_runtime = "dev-runtime-2153"


