output "vault_id" {
  description = "Id of the vault id"
  value       = azurerm_key_vault.vault.id
}
output "vault_uri" {
  description = "URI of the vault"
  value = azurerm_key_vault.vault.vault_uri
}