---
on:
  push:
    branches: [main]
    paths:
      - "src/**"
      - "infra/**"
      - ".github/workflows/**"

permissions:
  contents: read
  issues: read
  pull-requests: read

engine: copilot
network: defaults

inlined-imports: true
imports:
  - DevOpsDerek/workflows/.github/workflows/shared/agentic/documentation-upkeep.md@dac4b81c298cb3ea6821ea312efa5375f42d5ccb

tools:
  github:
    toolsets: [default]

safe-outputs:
  create-pull-request:
    max: 1
    draft: true
    fallback-as-issue: false
    protected-files: allowed
    allowed-files:
      - "README.md"
      - "docs/*.md"
      - "docs/**/*.md"
      - ".github/copilot-instructions.md"
      - "AGENTS.md"
  missing-tool:
    create-issue: false
---

# Documentation Updater Agent

Follow the imported documentation-upkeep policy after changes land on `main`
under `src/`, `infra/`, or `.github/workflows/`.

## Repository context

The .NET 10 API lives in `src/Api`, tests in `tests/Api.Tests`, Azure Container
Apps Terraform in `infra`, and workflows in `.github/workflows`. Check `README.md`,
`docs/`, `.github/copilot-instructions.md`, and `AGENTS.md` against the triggering
commit. Preserve the existing tone and structure.

Only edit documentation Markdown, not `.github/workflows/*.md` sources,
application code, Terraform, Dockerfiles, or generated references. Preserve the
documented OIDC-only authentication, environment-specific state, and production
reviewer requirements; never deploy, promote, apply infrastructure, or publish.

Use a title like `docs: sync documentation with recent changes`. CI checks
authored Markdown, including these workflow sources, with the pinned central
markdownlint-cli2 workflow. Cached `.github/aw/imports/` files are excluded;
generated `*.lock.yml` files are not Markdown inputs and are validated by
`gh aw compile`. Report the exact check result or explicitly state if the tool
is unavailable; do not claim a check passed without executing it.
