terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Bootstrap uses local state by default — it is the chicken-and-egg step that
  # creates the remote state backend used by the main configuration.
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_subscription" "current" {}

locals {
  environments = ["dev", "test", "prod"]
  state_sa_name = lower(replace(
    "st${var.project}tf${random_string.suffix.result}", "-", ""
  ))
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

# ---------------------------------------------------------------------------
# Remote state backend (storage account + blob container)
# ---------------------------------------------------------------------------
resource "azurerm_resource_group" "state" {
  name     = "rg-${var.project}-tfstate"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "state" {
  name                            = local.state_sa_name
  resource_group_name             = azurerm_resource_group.state.name
  location                        = azurerm_resource_group.state.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = true
  tags                            = var.tags

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }
  }
}

resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}

# ---------------------------------------------------------------------------
# GitHub OIDC: one user-assigned identity per environment (no client secrets)
# ---------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "deploy" {
  for_each = toset(local.environments)

  name                = "id-${var.project}-deploy-${each.value}"
  resource_group_name = azurerm_resource_group.state.name
  location            = azurerm_resource_group.state.location
  tags                = var.tags
}

# Federated credential bound to the matching GitHub Environment.
resource "azurerm_federated_identity_credential" "env" {
  for_each = toset(local.environments)

  name                = "github-env-${each.value}"
  resource_group_name = azurerm_resource_group.state.name
  parent_id           = azurerm_user_assigned_identity.deploy[each.value].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:${var.github_org}/${var.github_repo}:environment:${each.value}"
}

# Extra federated credential so the dev identity can run `terraform plan` on PRs.
resource "azurerm_federated_identity_credential" "dev_pull_request" {
  name                = "github-pull-request"
  resource_group_name = azurerm_resource_group.state.name
  parent_id           = azurerm_user_assigned_identity.deploy["dev"].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:${var.github_org}/${var.github_repo}:pull_request"
}

# ---------------------------------------------------------------------------
# Role assignments for each deployment identity
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "contributor" {
  for_each = toset(local.environments)

  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.deploy[each.value].principal_id
}

# Required to create role assignments (e.g. AcrPull) from within the main config.
resource "azurerm_role_assignment" "rbac_admin" {
  for_each = toset(local.environments)

  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Role Based Access Control Administrator"
  principal_id         = azurerm_user_assigned_identity.deploy[each.value].principal_id
}

# Access to read/write Terraform state via Entra ID (no storage keys).
resource "azurerm_role_assignment" "state_blob" {
  for_each = toset(local.environments)

  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.deploy[each.value].principal_id
}
