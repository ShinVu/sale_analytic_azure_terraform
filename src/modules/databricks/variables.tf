variable "key_vault_id" {
  type = string
}

variable "key_vault_uri" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "pool_min_idle_instances" {
  type = number
}

variable "pool_max_capacity" {
  type = number
}

variable "pool_autotermination_minutes" {
  type = number
}

variable "cluster_autotermination_minutes" {
  type = number
}

variable "databrick_connector_unity_catalog_id" {
  type = string
}

variable "databrick_managed_identity_catalog_id" {
  type = string
}

variable "databrick_workspace_id" {
  type = string
}

variable "databrick_workspace_workspace_id" {
  type = string
}


variable "resource_group_location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "storage_account_unity_catalog_name" {
  type = string
}

variable "storage_container_unity_catalog_name" {
  type = string
}

### Storage account variables ###
variable "storage_account_name" {
  type = string
}
### Bronze storage credential variables ###

variable "databrick_connector_bronze_storage_id" {
  type = string
}

variable "databrick_managed_identity_bronze_storage_id" {
  type = string
}

### Bronze storage name variables ### 
variable "bronze_container_storage_account_name" {
  type = string
}

### Silver storage credential variables ###

variable "databrick_connector_silver_storage_id" {
  type = string
}

variable "databrick_managed_identity_silver_storage_id" {
  type = string
}

### Silver storage name variables ### 
variable "silver_container_storage_account_name" {
  type = string
}

### Gold storage credential variables ###

variable "databrick_connector_gold_storage_id" {
  type = string
}

variable "databrick_managed_identity_gold_storage_id" {
  type = string
}

### Gold storage name variables ### 
variable "gold_container_storage_account_name" {
  type = string
}

variable "managed_identity_adf_client_id" {
  type = string
}