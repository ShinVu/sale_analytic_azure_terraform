output "integration_runtime_key" {
  description = "Primary key of the self hosted integration runtime"
  value       = azurerm_data_factory_integration_runtime_self_hosted.data_factory_integration_runtime.primary_authorization_key
  sensitive   = true
}
