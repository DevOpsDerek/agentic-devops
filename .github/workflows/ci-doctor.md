---
on:
  workflow_run:
    workflows: [CI, CD]
    types: [completed]
    branches:
      - main

if: github.event.workflow_run.conclusion == 'failure'

permissions:
  contents: read
  actions: read
  issues: read
  pull-requests: read

engine: copilot
network: defaults

inlined-imports: true
imports:
  - DevOpsDerek/workflows/.github/workflows/shared/agentic/ci-failure-diagnosis.md@dac4b81c298cb3ea6821ea312efa5375f42d5ccb

tools:
  github:
    toolsets: [default]

safe-outputs:
  create-issue:
    max: 1
    title-prefix: "[CI diagnosis] "
    labels: []
  add-comment:
    max: 1
  missing-tool:
    create-issue: false
---

# CI Doctor Agent

Follow the imported CI failure diagnosis policy for this repository's CI and CD.

## Trigger context

The triggering run ID is **${{ github.event.workflow_run.id }}**, run number
**#${{ github.event.workflow_run.run_number }}**, conclusion
**${{ github.event.workflow_run.conclusion }}**. Use the ID (not the display
number) to fetch its jobs and logs.

Stop immediately unless the conclusion is `failure`. Relevant checks include
the .NET solution build, xUnit/60% coverage gate, Terraform validation, TFLint,
actionlint, markdownlint, gh-aw compilation, Trivy, and OIDC deployment.
Diagnose authentication or deployment failures from existing logs only: do not
request credentials, rerun or cancel jobs, deploy, promote, or apply Terraform.

The local safe-output configuration deliberately specifies no labels; diagnosis
must not invent labels that do not exist in this repository.
Do not create labels, assign issues, or change project status. Include the
workflow, branch, and run number in the diagnostic title after its shared prefix.
