# Backend configuration for the TEST environment state.
# Storage account/container are provisioned by infra/bootstrap.
# Replace <STATE_STORAGE_ACCOUNT> with the bootstrap output value, or pass these
# values on the CLI via `-backend-config="key=..."` in CI.
resource_group_name  = "rg-agenticdevops-tfstate"
storage_account_name = "<STATE_STORAGE_ACCOUNT>"
container_name       = "tfstate"
key                  = "test.terraform.tfstate"
use_azuread_auth     = true
