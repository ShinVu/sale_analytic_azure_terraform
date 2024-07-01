### Environment variable ###

variable "environment" {
  type        = string
  description = "Current environment"
}


### Data factory variable ###
variable "var_data_factory_name" {
  type        = string
  description = "The name of the data factory to be created. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-zA-Z][-a-zA-Z0-9]*)$", var.var_data_factory_name)) && length(var.var_data_factory_name) >= 3 && length(var.var_data_factory_name) <= 24) || var.var_data_factory_name == ""
    error_message = "Data factory name must only contain alphanumeric characters and dashes (-), and cannot start with a number, length from 3 to 24 characters. Else Data factory name should be set to blank."
  }
}

variable "var_data_factory_access_policy_key_vault" {
  type        = list(string)
  description = "The required secret permissions so that the data factory (using managed service identity) can access the key vault"
}

variable "var_data_factory_github_config_account_name" {
  type        = string
  description = "Specifies the GitHub account name"
}

variable "var_data_factory_github_config_branch_name" {
  type        = string
  description = "Specifies the branch of the repository to get code from"
}

variable "var_data_factory_github_config_git_url" {
  type        = string
  description = "Specifies the GitHub Enterprise host name"
}

variable "var_data_factory_github_config_repository_name" {
  type        = string
  description = "Specifies the name of the git repository"
}

variable "var_data_factory_github_config_root_folder" {
  type        = string
  description = "Specifies the root folder within the repository. Set to / for the top level."
}

variable "var_data_factory_github_config_publishing_enabled" {
  type        = bool
  description = "Is automated publishing enabled?"
}

### Databrick variable ###
variable "var_databrick_workspace_sku_name" {
  type        = string
  description = ""
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.var_databrick_workspace_sku_name)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}

variable "var_databrick_workspace_name" {
  type        = string
  description = "The name of the databrick workspace to be created. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-zA-Z][-a-zA-Z0-9]*)$", var.var_databrick_workspace_name)) && length(var.var_databrick_workspace_name) >= 3 && length(var.var_databrick_workspace_name) <= 24) || var.var_databrick_workspace_name == ""
    error_message = "databrick name must only contain alphanumeric characters and dashes (-), and cannot start with a number, length from 3 to 24 characters. Else databrick name should be set to blank."
  }
}

### Resource group variable ###
variable "resource_group_location" {
  type        = string
  description = "Location of the resource group"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

### Key vault variable ###
variable "key_vault_id" {
  type        = string
  description = "Id of the key vault"
}

### Storage account variable ###
variable "var_storage_account_name" {
  type        = string
  description = "Name of the storage account"
}

variable "storage_account_tier" {
  type        = string
  description = "tier of the storage account"
}

variable "storage_account_replication_type" {
  type        = string
  description = "replication type of the storage account"
}

variable "storage_account_is_hns_enabled" {
  type        = bool
  description = "Is Hierarchical Namespace enabled?"
}

variable "storage_account_unity_catalog_name" {
  type        = string
  description = "Name of the storage account for unity catalog"
}
