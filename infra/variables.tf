variable "subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy into."
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

variable "environment" {
  type        = string
  description = "Deployment environment (dev, test, or prod)."

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "uksouth"
}

variable "container_image" {
  type        = string
  description = "Fully qualified container image reference to deploy."
  # Placeholder so the environment can be stood up before the first real image
  # exists. The CD pipeline overrides this with the freshly built ACR image.
  default = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "container_target_port" {
  type        = number
  description = "Port the container listens on for ingress."
  default     = 8080
}

variable "min_replicas" {
  type        = number
  description = "Minimum number of container replicas."
  default     = 1
}

variable "max_replicas" {
  type        = number
  description = "Maximum number of container replicas."
  default     = 3
}

variable "cpu" {
  type        = number
  description = "vCPU allocated to the container app."
  default     = 0.5
}

variable "memory" {
  type        = string
  description = "Memory allocated to the container app (e.g. '1Gi')."
  default     = "1Gi"
}

variable "log_retention_days" {
  type        = number
  description = "Log Analytics workspace retention in days."
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Additional resource tags."
  default     = {}
}
