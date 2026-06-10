output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "ACR login server used for pushing/pulling images."
  value       = azurerm_container_registry.main.login_server
}

output "acr_name" {
  description = "ACR resource name."
  value       = azurerm_container_registry.main.name
}

output "container_app_name" {
  description = "Name of the deployed Container App."
  value       = azurerm_container_app.api.name
}

output "container_app_fqdn" {
  description = "Public FQDN of the Container App ingress."
  value       = azurerm_container_app.api.ingress[0].fqdn
}

output "app_url" {
  description = "Public HTTPS URL of the API."
  value       = "https://${azurerm_container_app.api.ingress[0].fqdn}"
}
