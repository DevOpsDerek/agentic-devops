---
on:
  issues:
    types: [opened, reopened]

permissions:
  contents: read
  issues: read
  pull-requests: read

engine: copilot
network: defaults

inlined-imports: true
imports:
  - DevOpsDerek/workflows/.github/workflows/shared/agentic/issue-triage.md@dac4b81c298cb3ea6821ea312efa5375f42d5ccb

tools:
  github:
    toolsets: [default]

safe-outputs:
  add-comment:
    max: 1
    target: triggering
  missing-tool:
    create-issue: false
---

# Issue Triage Agent

Follow the imported triage policy for the **Agentic DevOps** repository: a .NET 10
API in `src/Api`, xUnit tests in `tests/Api.Tests`, Terraform in `infra`, and CI/CD
and agentic configuration in `.github/workflows`.

## Context

The issue that triggered this run is #${{ github.event.issue.number }}.

Read its title and body and inspect existing labels. Suggest the issue type and
one existing label in the single comment; do not apply either. Keep the comment
under 150 words. Never assign the issue or change its project status. If a needed
label does not exist, report it with missing-tool rather than creating it.
