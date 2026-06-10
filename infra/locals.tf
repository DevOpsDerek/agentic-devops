locals {
  name_prefix = "${var.project}-${var.environment}"

  # Globally-unique, alphanumeric-only names for ACR (3-50 chars, no hyphens).
  acr_name = lower(replace("${var.project}${var.environment}${random_string.suffix.result}", "-", ""))

  common_tags = merge(
    {
      project     = var.project
      environment = var.environment
      managed-by  = "terraform"
      workload    = "continuous-ai-poc"
    },
    var.tags
  )
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
  numeric = true
}
