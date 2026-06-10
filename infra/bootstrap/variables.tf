variable "subscription_id" {
  type        = string
  description = "Azure subscription ID to bootstrap."
}

variable "project" {
  type        = string
  description = "Short project name used as a naming prefix (lowercase alphanumeric)."
  default     = "agenticdevops"

  validation {
    condition     = can(regex("^[a-z0-9]{3,16}$", var.project))
    error_message = "project must be 3-16 lowercase alphanumeric characters."
  }
}

variable "location" {
  type        = string
  description = "Azure region for the state account and deployment identities."
  default     = "uksouth"
}

variable "github_org" {
  type        = string
  description = "GitHub organisation or user that owns the repository."
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name (without the owner prefix)."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to bootstrap resources."
  default = {
    managed-by = "terraform"
    workload   = "continuous-ai-poc"
    component  = "bootstrap"
  }
}
