# AGENTS.md

Guidance for AI agents (and humans) working in this repository.

## Overview

A Continuous AI proof-of-concept: a .NET 10 API deployed to Azure Container Apps
via Terraform, with GitHub Actions CI/CD and four agentic workflows.

## Key commands

| Task | Command |
| --- | --- |
| Restore | `dotnet restore AgenticDevOps.sln` |
| Format check | `dotnet format AgenticDevOps.sln --verify-no-changes` |
| Build | `dotnet build AgenticDevOps.sln -c Release` |
| Test + coverage | `dotnet test AgenticDevOps.sln -c Release --settings coverlet.runsettings` |
| Terraform validate | `terraform -chdir=infra validate` |
| Compile agentic workflows | `gh aw compile` |

## Directory map

- `src/Api/` — application code (edit here for feature/bug work).
- `tests/Api.Tests/` — tests (the **Test Improver** agent only edits here).
- `infra/` — Terraform; `infra/envs/` holds per-environment vars and backends.
- `.github/workflows/` — CI/CD YAML and agentic `*.md` + generated `*.lock.yml`.
- `docs/` — setup and supporting documentation (the **Doc Updater** agent edits
  Markdown only).

## Rules for agents

1. **Stay in your lane.** Doc agents touch only Markdown; test agents touch only
   `tests/`. Never modify generated `*.lock.yml` by hand.
2. **Keep it green.** Run format, build, and tests before proposing changes;
   maintain >= 60% coverage.
3. **Re-compile workflows.** If you change a `*.md` workflow, run `gh aw compile`
   and include the updated `*.lock.yml`.
4. **No secrets, no admin creds.** Deployment is OIDC-only; ACR admin stays off.
5. **Small, reviewable PRs** with a clear summary of what changed and why.

## Coding conventions

- net10.0, nullable enabled, implicit usings, warnings-as-errors in `src/`.
- Inject `TimeProvider`; avoid static clocks.
- Avoid public method names that collide with reserved words.
