# Use the resource_group module
module "resource_group" {
  source = "../modules/resource_group" # Local path to module resource group

  location = var.module_resource_group_resource_location
  prefix   = var.module_resource_group_resource_name_prefix
}

module "key_vault" {
  source = "../modules/key_vault" # Local path to module key_vault

  # Variables defined in dev- terraform.tfvars
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

  # Module depends on module resource group
  depends_on = [module.resource_group]
}

module "architecture" {
   source = "../modules/architecture" # Local path to module architecture

  var_data_factory_name =  var.module_architecture_var_data_factory_name
  integration_runtime_name = var.module_architecture_var_data_factory_integration_runtime
  var_databrick_workspace_name =  var.module_architecture_var_databrick_workspace_name
  var_databrick_workspace_sku_name = var.module_architecture_var_databrick_workspace_sku_name
  # Variables from the module resource_group output
  resource_group_location = module.resource_group.resource_group_location
  resource_group_name     = module.resource_group.resource_group_name

  # Module depends on module resource group
  depends_on = [module.resource_group]
}

