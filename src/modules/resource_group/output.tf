output "resource_group_name" {
  description = "Name of the created Azure resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Location of the created Azure resource group"
  value       = azurerm_resource_group.rg.location
}