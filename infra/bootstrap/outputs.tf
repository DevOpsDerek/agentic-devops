output "state_resource_group_name" {
  description = "Resource group holding the Terraform state account."
  value       = azurerm_resource_group.state.name
}

output "state_storage_account_name" {
  description = "Storage account name for the remote backend (use in *.backend.hcl)."
  value       = azurerm_storage_account.state.name
}

output "state_container_name" {
  description = "Blob container holding Terraform state."
  value       = azurerm_storage_container.state.name
}

output "deploy_identity_client_ids" {
  description = "Map of environment -> deployment identity client ID (set as AZURE_CLIENT_ID per GitHub Environment)."
  value       = { for env, id in azurerm_user_assigned_identity.deploy : env => id.client_id }
}

output "tenant_id" {
  description = "Entra tenant ID (set as AZURE_TENANT_ID secret/variable)."
  value       = data.azurerm_subscription.current.tenant_id
}

output "subscription_id" {
  description = "Subscription ID (set as AZURE_SUBSCRIPTION_ID secret/variable)."
  value       = data.azurerm_subscription.current.subscription_id
}
