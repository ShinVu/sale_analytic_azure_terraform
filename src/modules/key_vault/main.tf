# Reference current azurerm_client_config
data "azurerm_client_config" "current" {}

# Generate a random string for azure key vault name
resource "random_string" "azurerm_key_vault_name" {
  length  = 13    #String of length 13 characters
  lower   = true  #String should be lowercase
  numeric = false #String should not container numeric character
  special = false #String should not contain special character
  upper   = false #String should not contain uppercase character
}

resource "azurerm_key_vault" "vault" {
  name                       = coalesce(var.vault_name, "vault-${random_string.azurerm_key_vault_name.result}") #Name of the vault
  location                   = var.resource_group_location                                                      # Location of the vault
  resource_group_name        = var.resource_group_name                                                          # Resource group of the vault
  tenant_id                  = data.azurerm_client_config.current.tenant_id                                     # Tenant ID, retrieved from current client config
  sku_name                   = var.vault_sku_name                                                               # SKU name
  soft_delete_retention_days = var.vault_soft_delete_retention_days                                             # Soft delete retention days
  purge_protection_enabled   = var.vault_purge_protection                                                       # Vault purge protection
}

# Defind the current user id
# If var.msi_id is not null, get value from var.msi_id
# If var.msi_id is null, get value from data.azurerm_client_config.current.object_id
locals {
  current_user_id = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
}


resource "azurerm_key_vault_access_policy" "vault_access_policy" {
  key_vault_id = azurerm_key_vault.vault.id                   # The id of the vault where access policy will be created
  tenant_id    = data.azurerm_client_config.current.tenant_id # Tenant id
  object_id    = data.azurerm_client_config.current.object_id # Object id 

  key_permissions         = var.vault_access_policy_key_permissions         # Key permissions for this access policy
  secret_permissions      = var.vault_access_policy_secret_permissions      # Secret permissions for this access policy
  certificate_permissions = var.vault_access_policy_certificate_permissions # Certificate permissions for this access policy

  depends_on = [azurerm_key_vault.vault] #Access policy should only be created after the key vault is successfully created
}

resource "azurerm_key_vault_secret" "db_user" {
  name         = "db-user"
  value        = var.vault_secret_db_user
  key_vault_id = azurerm_key_vault.vault.id
  depends_on   = [azurerm_key_vault_access_policy.vault_access_policy]
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.vault_secret_db_pass
  key_vault_id = azurerm_key_vault.vault.id
  depends_on   = [azurerm_key_vault_access_policy.vault_access_policy]
}
