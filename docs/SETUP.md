# Setup guide

One-time setup to enable OIDC-based, multi-environment deployment to Azure. All
steps are dry-run friendly — review the Terraform plans before applying.

## Prerequisites

- Azure subscription with permission to create resource groups, role assignments,
  and managed identities.
- [Azure CLI](https://learn.microsoft.com/cli/azure/), [Terraform](https://developer.hashicorp.com/terraform) >= 1.9, and the [GitHub CLI](https://cli.github.com/).
- This repository pushed to GitHub.

## 1. Bootstrap remote state + OIDC identities

The bootstrap configuration creates the Terraform state storage account and one
GitHub-federated **user-assigned managed identity per environment** (no client
secrets).

```pwsh
az login
cd infra/bootstrap

terraform init
terraform apply `
  -var="subscription_id=<SUBSCRIPTION_ID>" `
  -var="github_org=<OWNER>" `
  -var="github_repo=<REPO>"
```

Record the outputs:

| Output | Use |
| --- | --- |
| `state_storage_account_name` | `STATE_STORAGE_ACCOUNT` variable |
| `deploy_identity_client_ids` | `AZURE_CLIENT_ID` per environment |
| `tenant_id` | `AZURE_TENANT_ID` variable |
| `subscription_id` | `AZURE_SUBSCRIPTION_ID` variable |

## 2. Create GitHub Environments

Create three [environments](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment): `dev`, `test`, `prod`.

- On **`prod`**, enable **Required reviewers** so production deploys pause for
  manual approval.
- Optionally restrict each environment's deployment branches to `main`.

## 3. Set environment variables

For **each** environment, set these GitHub Actions **variables** (not secrets —
none of these are sensitive):

| Variable | Value |
| --- | --- |
| `AZURE_CLIENT_ID` | The matching environment's identity client ID from bootstrap |
| `AZURE_TENANT_ID` | Tenant ID from bootstrap |
| `AZURE_SUBSCRIPTION_ID` | Subscription ID |
| `STATE_STORAGE_ACCOUNT` | State storage account name from bootstrap |

```pwsh
gh variable set AZURE_CLIENT_ID --env dev --body "<dev-client-id>"
gh variable set AZURE_TENANT_ID --env dev --body "<tenant-id>"
gh variable set AZURE_SUBSCRIPTION_ID --env dev --body "<subscription-id>"
gh variable set STATE_STORAGE_ACCOUNT --env dev --body "<state-account>"
# repeat for test and prod (with each env's own AZURE_CLIENT_ID)
```

## 4. Deploy

Push to `main` (or run the **CD** workflow manually). The pipeline builds the
image, runs the Trivy image gate, then promotes **Dev → Test → Prod**, pausing for
approval before production.

## 5. (Optional) Seed labels for triage

The Issue Triage agent applies existing labels. Seed a useful set:

```pwsh
gh label create "area:api" --color 1d76db
gh label create "area:infra" --color 0e8a16
gh label create "area:workflows" --color 5319e7
gh label create "ci/cd" --color fbca04
gh label create "infrastructure" --color 0e8a16
gh label create "security" --color b60205
gh label create "priority:high" --color d93f0b
gh label create "priority:medium" --color fbca04
gh label create "priority:low" --color c2e0c6
```
