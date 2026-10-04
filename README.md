# Agentic DevOps on GitHub — Continuous AI PoC

A proof-of-concept that showcases **the best of agentic DevOps on GitHub**: a real
application that ships to Azure through a secure, multi-environment pipeline, with
[GitHub **Continuous AI**](https://githubnext.com/projects/continuous-ai/) agents
automating triage, documentation, diagnostics, and test improvement.

> **Continuous AI** is to collaborative software what CI/CD is to builds and
> deployments: routine, automated, AI-assisted work that runs *continuously* in the
> background of your repository. This repo demonstrates that vision end-to-end.

---

## What this demonstrates

| Capability | How it's shown here |
| --- | --- |
| **Ships to Azure** | .NET 10 minimal API → container → **Azure Container Apps** via **Terraform** |
| **Secure by default** | GitHub **OIDC** (no cloud secrets), managed identity, ACR without admin creds |
| **Quality gates** | `dotnet format`, xUnit tests, **60% coverage gate**, `tflint`, `actionlint`, `markdownlint` |
| **DevSecOps scanning** | **Trivy** (filesystem, IaC config, container image) + **CodeQL** + **Dependabot** |
| **Multi-environment** | **Dev → Test → Prod** promotion with manual approval before production |
| **Continuous AI** | Four agentic workflows ([gh-aw](https://github.com/githubnext/gh-aw)) running on GitHub Copilot |

---

## Continuous AI agents

These live as Markdown in [.github/workflows/](.github/workflows/) and compile to
locked GitHub Actions (`*.lock.yml`) via `gh aw compile`. They use **safe-outputs**
— the agent never gets write tokens directly; its proposed actions (comments,
draft PRs, issues) are applied by a separate, minimally-scoped job.

| Agent | File | Trigger | Continuous AI pillar |
| --- | --- | --- | --- |
| **Issue Triage** | [issue-triage.md](.github/workflows/issue-triage.md) | Issue opened/reopened | Continuous Triage |
| **Doc Updater** | [doc-updater.md](.github/workflows/doc-updater.md) | Push to `main` | Continuous Documentation |
| **CI Doctor** | [ci-doctor.md](.github/workflows/ci-doctor.md) | CI/CD run fails | Continuous Repair |
| **Test Improver** | [test-improver.md](.github/workflows/test-improver.md) | Weekly + manual | Continuous Quality |

The engine is **GitHub Copilot**, so no third-party model API keys are required.

### Central automation adoption

The agents import shared instructions from
[`DevOpsDerek/workflows`](https://github.com/DevOpsDerek/workflows).
Each source pins its import to a full commit SHA and uses `inlined-imports: true`,
so the compiled lock contains the shared instructions without checking out the
catalog at runtime. Local sources retain repository-specific triggers, paths,
commands, read permissions, and bounded safe-output configuration; do not copy
shared implementations into this repository.

The adopted catalog revision is
`dac4b81c298cb3ea6821ea312efa5375f42d5ccb`.

Issue triage now proposes an existing label and issue type in one comment rather
than applying them. Documentation and test improvements produce at most one
**draft PR** per run for human review. CI diagnosis remains failure-only and does
not create or apply new labels. No agent may
assign issues, change project status, merge, deploy, promote, apply infrastructure,
or publish.

The existing `meta-lint` CI job also calls the central
`.github/actions/validate-agentic-workflows` action using the same immutable
catalog revision. It validates and recompiles gh-aw sources and fails on stale
locks with only `contents: read`. A caller-side check also rejects changes to
`.github/aw/actions-lock.json` produced by compilation. CI also calls the
catalog's Terraform and Markdown lint workflows at immutable revision
`cd4f07509e9efb0c498217c3be352e762bd0c149`. Terraform formatting and validation
run separately for `infra/` and `infra/bootstrap/` using Terraform 1.15.6; the
existing TFLint checks cover both roots. Markdown lint uses pinned Node.js
22.15.0 and markdownlint-cli2 0.17.2 for authored Markdown, including gh-aw
sources, while excluding cached imports; generated `*.lock.yml` files are
validated by gh-aw compilation instead. The .NET build/format/test and 60%
coverage gate, test artifacts, Trivy, CodeQL, actionlint, workflow triggers,
and CD and environment-bound OIDC promotion remain in place. The catalog's
narrow checked-script helper is not a replacement for this multi-step CI.
Configure the protected production environment and required reviewers as
described in [setup](docs/SETUP.md) before deployment.

Use gh-aw **v0.89.21**, matching the explicit CI validator input:

```sh
gh aw compile --validate --actionlint --no-check-update
git diff -- .github/workflows .github/aw/actions-lock.json .gitattributes
```

Commit each source and generated lock together and review their safe-output
tools and permissions, not just compiler success. Never edit locks by hand.
Remote imports cached in `.github/aw/imports/` are ignored; shared content is
embedded in the locks. Update catalog SHAs deliberately after verifying the
published paths and contracts, then recompile and review all affected locks.

---

## Architecture

```mermaid
flowchart TB
    dev[Developer] -->|push / PR| repo[(GitHub Repository)]

    subgraph GH[GitHub]
        repo --> ci[CI: format, test, coverage, tflint, Trivy, CodeQL]
        repo --> cd[CD: build, scan, promote]
        repo --> agents[Continuous AI agents<br/>triage · docs · ci-doctor · tests]
    end

    cd -->|OIDC, no secrets| azlogin{{Azure OIDC login}}

    subgraph AZ[Azure]
        azlogin --> tf[Terraform: ACR · Log Analytics · Container Apps]
        tf --> aca[Azure Container App<br/>.NET 10 API]
        acr[(Azure Container Registry)] --> aca
        mi[User-assigned Managed Identity<br/>AcrPull] --> aca
    end

    agents -.safe-outputs.-> repo
```

### Environment promotion

```mermaid
flowchart LR
    build[Build image<br/>+ Trivy scan gate] --> dev[Deploy Dev<br/>auto]
    dev --> test[Deploy Test<br/>auto]
    test -->|manual approval| prod[Deploy Prod<br/>protected]
```

Each environment is fully isolated: its own resource group, ACR, Container Apps
environment, managed identity, and Terraform state file.

---

## Repository layout

```text
.
├── src/Api/                 # .NET 10 minimal API (Task CRUD) + Dockerfile
├── tests/Api.Tests/         # xUnit unit + integration tests
├── infra/                   # Terraform for Azure Container Apps (multi-env)
│   ├── envs/                # dev/test/prod tfvars + backend configs
│   └── bootstrap/           # remote state + GitHub OIDC identities (run once)
├── .github/
│   ├── workflows/           # CI, CD, CodeQL + agentic (*.md → *.lock.yml)
│   └── dependabot.yml
├── AgenticDevOps.sln
└── README.md
```

---

## The application

A small **Task API** (in-memory store) that is realistic enough to exercise the
whole pipeline:

| Method | Route | Description |
| --- | --- | --- |
| `GET` | `/healthz` | Liveness/readiness probe |
| `GET` | `/tasks` | List tasks |
| `GET` | `/tasks/{id}` | Get a task |
| `POST` | `/tasks` | Create a task |
| `PUT` | `/tasks/{id}` | Update a task |
| `DELETE` | `/tasks/{id}` | Delete a task |

OpenAPI is exposed at `/openapi/v1.json` in Development.

---

## Run locally

Prerequisites: **.NET 10 SDK** (see [global.json](global.json)).

```pwsh
dotnet restore AgenticDevOps.sln
dotnet test AgenticDevOps.sln -c Release --settings coverlet.runsettings
dotnet run --project src/Api
```

> On corporate machines with a restricted global NuGet feed, add
> `--configfile nuget.config` to the restore command to force nuget.org.

---

## Deploy to Azure

Deployment is OIDC-based and runs from GitHub Actions — there are **no cloud
secrets** stored in the repo. See [docs/SETUP.md](docs/SETUP.md) for the full
one-time setup (bootstrap state + OIDC identities, GitHub Environments, and
variables). In short:

1. `terraform -chdir=infra/bootstrap apply` — creates the Terraform state account
   and one GitHub-federated managed identity per environment.
2. Configure GitHub **Environments** (`dev`, `test`, `prod`) and set the
   `AZURE_CLIENT_ID` / `AZURE_TENANT_ID` / `AZURE_SUBSCRIPTION_ID` /
   `STATE_STORAGE_ACCOUNT` variables. Add required reviewers to `prod`.
3. Push to `main` — **CD** builds, scans, and promotes Dev → Test → Prod.

---

## Security posture

- **No long-lived cloud credentials** — GitHub OIDC federation only.
- **No ACR admin user** — image pulls use a user-assigned managed identity with
  `AcrPull`.
- **Defense-in-depth scanning** — Trivy (deps, IaC, image) + CodeQL, all reported
  as SARIF to GitHub code scanning; CRITICAL/HIGH findings fail the build.
- **Least-privilege agents** — Continuous AI workflows read-only by default;
  mutations go through scoped **safe-outputs** jobs.

See [SECURITY.md](SECURITY.md) for details.
