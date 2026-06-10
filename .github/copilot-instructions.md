# Copilot instructions — Agentic DevOps PoC

This repository is a proof-of-concept for agentic DevOps on GitHub. Keep changes
consistent with the conventions below.

## Project shape

- **App:** .NET 10 minimal API in `src/Api` (Task CRUD, in-memory `ITaskStore`).
- **Tests:** xUnit in `tests/Api.Tests` (unit + `WebApplicationFactory` integration).
- **Infra:** Terraform in `infra/` targeting Azure Container Apps; `infra/bootstrap`
  provisions remote state and GitHub OIDC identities.
- **CI/CD:** GitHub Actions in `.github/workflows` (`ci.yml`, `cd.yml`, `deploy.yml`,
  `codeql.yml`).
- **Continuous AI:** agentic workflows authored as `*.md` and compiled to
  `*.lock.yml` with `gh aw compile`.

## Conventions

- Target framework is **net10.0**; production code builds with
  `TreatWarningsAsErrors=true` and code-style enforcement on. Keep it warning-clean.
- Test projects relax analyzers — do not copy production analyzer strictness into
  tests.
- Public API methods avoid names that collide with reserved keywords (e.g. the
  store uses `Find`, not `Get`).
- `Program.cs` ends with `public partial class Program;` so integration tests can
  reference it — keep that.
- Prefer constructor-injected `TimeProvider` over `DateTime.UtcNow` for testability.

## Validation before finishing

```pwsh
dotnet format AgenticDevOps.sln --verify-no-changes
dotnet test AgenticDevOps.sln -c Release --settings coverlet.runsettings
terraform -chdir=infra fmt -check -recursive
terraform -chdir=infra validate
gh aw compile
```

- Keep line coverage at or above **60%** (enforced in CI).
- After editing any `.github/workflows/*.md` agentic file, **recompile** so the
  matching `.lock.yml` stays in sync, and commit both.

## Guardrails

- Do not add cloud secrets — deployment uses GitHub OIDC only.
- Do not enable the ACR admin user or commit Terraform state.
