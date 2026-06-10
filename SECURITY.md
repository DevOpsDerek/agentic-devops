# Security

This proof-of-concept is built to demonstrate secure-by-default agentic DevOps.

## Cloud authentication

- **No long-lived cloud credentials are stored in the repository.** GitHub Actions
  authenticates to Azure using **OIDC federation** (`azure/login` with
  `id-token: write`), exchanging a short-lived GitHub token for an Azure access
  token.
- Each environment (`dev`, `test`, `prod`) uses its **own** user-assigned managed
  identity with a federated credential scoped to that GitHub Environment.
- The Azure Container Registry has the **admin user disabled**; the Container App
  pulls images using a managed identity granted only the `AcrPull` role.

## Supply-chain & code scanning

| Tool | Scope | Gate |
| --- | --- | --- |
| **Trivy** | Filesystem / dependencies | Fail on CRITICAL, HIGH |
| **Trivy** | IaC misconfiguration (`config`) | Reported as SARIF |
| **Trivy** | Container image | Fail on CRITICAL, HIGH |
| **CodeQL** | C# static analysis | SARIF + scheduled scan |
| **Dependabot** | NuGet, Terraform, Actions, Docker | Automated update PRs |

All scanners upload SARIF to GitHub code scanning for centralized review.

## Agentic workflow safety

The Continuous AI workflows follow least-privilege principles via
[gh-aw](https://github.com/githubnext/gh-aw):

- Agent jobs run with **read-only** GitHub permissions.
- All mutations (labels, comments, issues, pull requests) are performed by a
  separate **safe-outputs** job with narrowly-scoped, per-action permissions.
- Outbound network access is restricted via the `network` setting.
- Each workflow's instructions include explicit guardrails (what the agent may and
  may not touch).

## Reporting

This is a demonstration repository. For real deployments, configure a private
vulnerability reporting policy and a security contact here.
