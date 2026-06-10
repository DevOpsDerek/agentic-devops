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

  # Partial backend configuration. Real values are supplied per environment via
  # `terraform init -backend-config=envs/<env>.backend.hcl` (see infra/bootstrap).
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  # In CI the AzureRM provider authenticates via GitHub OIDC using the
  # ARM_USE_OIDC / ARM_CLIENT_ID / ARM_TENANT_ID / ARM_SUBSCRIPTION_ID env vars.
  # Locally it falls back to `az login`.
  subscription_id = var.subscription_id
}
