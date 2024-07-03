### Environment variable ###
variable "environment" {
  type        = string
  description = "Current environment"
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "The environment can only be dev, staging, production"
  }
}


### Resource group variables ###
variable "module_resource_group_resource_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "module_resource_group_resource_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

### Key vault variables ###
variable "module_key_vault_vault_name" {
  type        = string
  description = "The name of the key vault to be created. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-zA-Z][-a-zA-Z0-9]*)$", var.module_key_vault_vault_name)) && length(var.module_key_vault_vault_name) >= 3 && length(var.module_key_vault_vault_name) <= 24) || var.module_key_vault_vault_name == ""
    error_message = "Vault name must only contain alphanumeric characters and dashes (-), and cannot start with a number, length from 3 to 24 characters. Else vault name should be set to blank."
  }
}

variable "module_key_vault_vault_sku_name" {
  type        = string
  description = "The SKU of the vault to be created."
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.module_key_vault_vault_sku_name)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}

variable "module_key_vault_vault_soft_delete_retention_days" {
  type        = number
  description = "The days to retain deleted vaults"
  default     = 7
  validation {
    condition     = var.module_key_vault_vault_soft_delete_retention_days >= 7 && var.module_key_vault_vault_soft_delete_retention_days <= 90
    error_message = "The soft_delete_retention_days must be between 7 and 90 days"
  }
}


variable "module_key_vault_vault_purge_protection" {
  type        = bool
  description = "Whether to enable purge protection for the vault. Enable purge protection by setting this variable to True."
  default     = false
  validation {
    condition     = contains([true, false], var.module_key_vault_vault_purge_protection)
    error_message = "The module_key_vault_vault_purge_protection can only be a Boolean value"
  }
}


variable "module_key_vault_msi_id" {
  type        = string
  description = "The Managed Service Identity ID. If this value isn't null (the default), 'data.azurerm_client_config.current.object_id' will be set to this value."
  default     = null
}

variable "module_key_vault_vault_access_policy_key_permissions" {
  type        = list(string)
  description = "List of key permissions."
  default     = ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]
  validation {
    condition     = length(var.module_key_vault_vault_access_policy_key_permissions) > 0 || alltrue([for action in var.module_key_vault_vault_access_policy_key_permissions : contains(["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"], action)])
    error_message = "Key permissions can only contain Backup, Create, Decrypt, Delete, Encrypt, Get, Import, List, Purge, Recover, Restore, Sign, UnwrapKey, Update, Verify, WrapKey, Release, Rotate, GetRotationPolicy and SetRotationPolicy."
  }
}

variable "module_key_vault_vault_access_policy_secret_permissions" {
  type        = list(string)
  description = "List of secret permissions."
  default     = ["Set"]
  validation {
    condition     = length(var.module_key_vault_vault_access_policy_secret_permissions) > 0 || alltrue([for action in var.module_key_vault_vault_access_policy_secret_permissions : contains(["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"], action)])
    error_message = "Secret permissions can only contain Backup, Delete, Get, List, Purge, Recover, Restore and Set"
  }
}

variable "module_key_vault_vault_access_policy_certificate_permissions" {
  type        = list(string)
  description = "List of certificate permissions."
  default     = ["Set"]
  validation {
    condition     = length(var.module_key_vault_vault_access_policy_certificate_permissions) > 0 || alltrue([for action in var.module_key_vault_vault_access_policy_certificate_permissions : contains(["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"], action)])
    error_message = "Certificate permissions can only contain Backup, Create, Delete, DeleteIssuers, Get, GetIssuers, Import, List, ListIssuers, ManageContacts, ManageIssuers, Purge, Recover, Restore, SetIssuers and Update."
  }
}


variable "module_key_vault_vault_secret_db_user" {
  type        = string
  description = "Database user"
}

variable "module_key_vault_vault_secret_db_pass" {
  type        = string
  description = "Database pass"
  sensitive   = true
}

### Databricks workspace variables ###
variable "module_architecture_var_databrick_workspace_name" {
  type        = string
  description = "The name of the databrick workspace to be created. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-zA-Z][-a-zA-Z0-9]*)$", var.module_architecture_var_databrick_workspace_name)) && length(var.module_architecture_var_databrick_workspace_name) >= 3 && length(var.module_architecture_var_databrick_workspace_name) <= 24) || var.module_architecture_var_databrick_workspace_name == ""
    error_message = "Vault name must only contain alphanumeric characters and dashes (-), and cannot start with a number, length from 3 to 24 characters. Else vault name should be set to blank."
  }
}

variable "module_architecture_var_databrick_workspace_sku_name" {
  type        = string
  description = ""
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.module_architecture_var_databrick_workspace_sku_name)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}

variable "module_databrick_cluster_name" {
  type        = string
  description = "Name of the databrick cluster"
}

variable "module_databrick_pool_min_idle_instances" {
  type = number
  description = "The minimum number of idle instances maintained by the pool. "
  default = 0
}

variable "module_databrick_pool_max_capacity" {
  type = number
  description = "The maximum number of instances the pool can contain, including both idle instances and ones in use by clusters."
  default = null
}


variable "module_databrick_pool_autotermination_minutes" {
  type = number
  description = "The number of minutes that idle instances in excess of the min_idle_instances are maintained by the pool before being terminated."
  default = 0
}

variable "module_databrick_cluster_autotermination_minutes" {
  type = number
  description = "Automatically terminate the cluster after being inactive for this time in minutes."
  default = 10
}

### Data factory workspace variables ###
variable "module_architecture_var_data_factory_name" {
  type        = string
  description = "The name of the data factory to be created. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-zA-Z][-a-zA-Z0-9]*)$", var.module_architecture_var_data_factory_name)) && length(var.module_architecture_var_data_factory_name) >= 3 && length(var.module_architecture_var_data_factory_name) <= 24) || var.module_architecture_var_data_factory_name == ""
    error_message = "Vault name must only contain alphanumeric characters and dashes (-), and cannot start with a number, length from 3 to 24 characters. Else vault name should be set to blank."
  }
}

variable "module_data_factory_access_policy_key_vault" {
  type        = list(string)
  description = "List of secret permissions for data access policy to key vault"
  default     = ["List", "Get"]
  validation {
    condition     = length(var.module_data_factory_access_policy_key_vault) > 0 || alltrue([for action in var.module_data_factory_access_policy_key_vault : contains(["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"], action)])
    error_message = "Secret permissions can only contain Backup, Delete, Get, List, Purge, Recover, Restore and Set"
  }
}


variable "module_architecture_var_data_factory_github_config_account_name" {
  type        = string
  description = "Specifies the GitHub account name"
}

variable "module_architecture_var_data_factory_github_config_branch_name" {
  type        = string
  description = "Specifies the branch of the repository to get code from"
}

variable "module_architecture_var_data_factory_github_config_git_url" {
  type        = string
  description = "Specifies the GitHub Enterprise host name"
  default     = "https://github.com"
}

variable "module_architecture_var_data_factory_github_config_repository_name" {
  type        = string
  description = "Specifies the name of the git repository"
}

variable "module_architecture_var_data_factory_github_config_root_folder" {
  type        = string
  description = "Specifies the root folder within the repository. Set to / for the top level."
  default     = "/"
}

variable "module_architecture_var_data_factory_github_config_publishing_enabled" {
  type        = bool
  description = "Is automated publishing enabled?"
  default     = true
}

### Storage account variables ###
variable "module_architecture_storage_account_name" {
  type        = string
  description = "The name of the storage account to be created. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-z][a-z0-9]*)$", var.module_architecture_storage_account_name)) && length(var.module_architecture_storage_account_name) >= 3 && length(var.module_architecture_storage_account_name) <= 24) || var.module_architecture_storage_account_name == ""
    error_message = "Storage account name must only contain lowercase alphanumeric characters, length from 3 to 24 characters. Else vault name should be set to blank."
  }
}


variable "module_architecture_storage_account_tier" {
  type        = string
  description = "tier of the storage account"
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.module_architecture_storage_account_tier)
    error_message = "Tier of the storage account can only be Standard, Premium"
  }
}

variable "module_architecture_storage_account_replication_type" {
  type        = string
  description = "replication type of the storage account"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.module_architecture_storage_account_replication_type)
    error_message = "Tier of the storage account can only be LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS"
  }
}

variable "module_architecture_storage_account_is_hns_enabled" {
  type        = bool
  description = "Is Hierarchical Namespace enabled?"
  validation {
    condition     = contains([true, false], var.module_architecture_storage_account_is_hns_enabled)
    error_message = "The module_architecture_storage_account_is_hns_enabled only be a Boolean value"
  }
}

variable "module_architecture_storage_account_unity_catalog_name" {
  type        = string
  description = "Name of the storage account for unity catalog"
   default     = ""
  validation {
    condition     = (can(regex("^([a-z][a-z0-9]*)$", var.module_architecture_storage_account_unity_catalog_name)) && length(var.module_architecture_storage_account_unity_catalog_name) >= 3 && length(var.module_architecture_storage_account_unity_catalog_name) <= 24) || var.module_architecture_storage_account_unity_catalog_name == ""
    error_message = "Storage account name must only contain lowercase alphanumeric characters, length from 3 to 24 characters. Else vault name should be set to blank."
  }
}

