variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}


variable "vault_name" {
  type        = string
  description = "The name of the key vault to be created. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-zA-Z][-a-zA-Z0-9]*)$", var.vault_name)) && length(var.vault_name) >= 3 && length(var.vault_name) <= 24) || var.vault_name == ""
    error_message = "Vault name must only contain alphanumeric characters and dashes (-), and cannot start with a number, length from 3 to 24 characters. Else vault name should be set to blank."
  }
}

variable "vault_sku_name" {
  type        = string
  description = "The SKU of the vault to be created."
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.vault_sku_name)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}

variable "vault_soft_delete_retention_days" {
  type        = number
  description = "The days to retain deleted vaults"
  default     = 7
  validation {
    condition     = var.vault_soft_delete_retention_days >= 7 && var.vault_soft_delete_retention_days <= 90
    error_message = "The soft_delete_retention_days must be between 7 and 90 days"
  }
}


variable "vault_purge_protection" {
  type        = bool
  description = "Whether to enable purge protection for the vault. Enable purge protection by setting this variable to True."
  default     = false
  validation {
    condition     = contains([true, false], var.vault_purge_protection)
    error_message = "The vault_purge_protection can only be a Boolean value"
  }
}


variable "msi_id" {
  type        = string
  description = "The Managed Service Identity ID. If this value isn't null (the default), 'data.azurerm_client_config.current.object_id' will be set to this value."
  default     = null
}

variable "vault_access_policy_key_permissions" {
  type        = list(string)
  description = "List of key permissions."
  default     = ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]
  validation {
    condition     = length(var.vault_access_policy_key_permissions) > 0 || alltrue([for action in var.vault_access_policy_key_permissions : contains(["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"], action)])
    error_message = "Key permissions can only contain Backup, Create, Decrypt, Delete, Encrypt, Get, Import, List, Purge, Recover, Restore, Sign, UnwrapKey, Update, Verify, WrapKey, Release, Rotate, GetRotationPolicy and SetRotationPolicy."
  }
}

variable "vault_access_policy_secret_permissions" {
  type        = list(string)
  description = "List of secret permissions."
  default     = ["Set"]
  validation {
    condition     = length(var.vault_access_policy_secret_permissions) > 0 || alltrue([for action in var.vault_access_policy_secret_permissions : contains(["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"], action)])
    error_message = "Secret permissions can only contain Backup, Delete, Get, List, Purge, Recover, Restore and Set"
  }
}
variable "vault_access_policy_certificate_permissions" {
  type        = list(string)
  description = "List of certificate permissions."
  default     = ["Set"]
  validation {
    condition     = length(var.vault_access_policy_certificate_permissions) > 0 || alltrue([for action in var.vault_access_policy_certificate_permissions : contains(["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"], action)])
    error_message = "Certificate permissions can only contain Backup, Create, Delete, DeleteIssuers, Get, GetIssuers, Import, List, ListIssuers, ManageContacts, ManageIssuers, Purge, Recover, Restore, SetIssuers and Update."
  }
}


variable "vault_secret_db_user" {
  type        = string
  description = "Database user"
}

variable "vault_secret_db_pass" {
  type        = string
  description = "Database pass"
  sensitive   = true
}

variable "var_databrick_workspace_sku_name" {
  type        = string
  description = ""
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.var_databrick_workspace_sku_name)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}

variable "var_data_factory_name" {
  type        = string
  description = "The name of the data factory to be created. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-zA-Z][-a-zA-Z0-9]*)$", var.var_data_factory_name)) && length(var.var_data_factory_name) >= 3 && length(var.var_data_factory_name) <= 24) || var.var_data_factory_name == ""
    error_message = "Vault name must only contain alphanumeric characters and dashes (-), and cannot start with a number, length from 3 to 24 characters. Else vault name should be set to blank."
  }
}

variable "var_databrick_workspace_name" {
  type        = string
  description = "The name of the databrick workspace to be created. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-zA-Z][-a-zA-Z0-9]*)$", var.var_databrick_workspace_name)) && length(var.var_databrick_workspace_name) >= 3 && length(var.var_databrick_workspace_name) <= 24) || var.var_databrick_workspace_name == ""
    error_message = "Vault name must only contain alphanumeric characters and dashes (-), and cannot start with a number, length from 3 to 24 characters. Else vault name should be set to blank."
  }
}
