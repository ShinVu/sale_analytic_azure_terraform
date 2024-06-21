variable "var_data_factory_name" {
  type        = string
  description = "The name of the data factory to be created. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-zA-Z][-a-zA-Z0-9]*)$", var.var_data_factory_name)) && length(var.var_data_factory_name) >= 3 && length(var.var_data_factory_name) <= 24) || var.var_data_factory_name == ""
    error_message = "Data factory name must only contain alphanumeric characters and dashes (-), and cannot start with a number, length from 3 to 24 characters. Else Data factory name should be set to blank."
  }
}

variable "integration_runtime_name" {
  type        = string
  description = "The name of the self hosted integration runtime for azure data factory. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-zA-Z][-a-zA-Z0-9]*)$", var.integration_runtime_name)) && length(var.integration_runtime_name) >= 3 && length(var.integration_runtime_name) <= 24) || var.integration_runtime_name == ""
    error_message = "Runtime name must only contain alphanumeric characters and dashes (-), and cannot start with a number, length from 3 to 24 characters. Else Runtime name should be set to blank."
  }
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

variable "var_databrick_workspace_name" {
  type        = string
  description = "The name of the databrick workspace to be created. The value will be randomly generated if blank."
  default     = ""
  validation {
    condition     = (can(regex("^([a-zA-Z][-a-zA-Z0-9]*)$", var.var_databrick_workspace_name)) && length(var.var_databrick_workspace_name) >= 3 && length(var.var_databrick_workspace_name) <= 24) || var.var_databrick_workspace_name == ""
    error_message = "databrick name must only contain alphanumeric characters and dashes (-), and cannot start with a number, length from 3 to 24 characters. Else databrick name should be set to blank."
  }
}

variable "resource_group_location" {
  type        = string
  description = "Location of the resource group"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}
