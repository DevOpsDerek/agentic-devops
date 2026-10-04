---
on:
  schedule: weekly on monday
  workflow_dispatch:

permissions:
  contents: read
  issues: read
  pull-requests: read

engine: copilot
network: defaults

inlined-imports: true
imports:
  - DevOpsDerek/workflows/.github/workflows/shared/agentic/test-quality.md@dac4b81c298cb3ea6821ea312efa5375f42d5ccb

tools:
  github:
    toolsets: [default]
  bash:
    - "dotnet *"
    - "find *"
    - "cat *"
    - "ls *"

safe-outputs:
  create-pull-request:
    max: 1
    draft: true
    fallback-as-issue: false
    allowed-files:
      - "tests/**"
  missing-tool:
    create-issue: false
---

# Test Improver Agent

Follow the imported test-quality policy for the .NET 10 Task API. Production
code is in `src/Api`; xUnit unit and `WebApplicationFactory` integration tests are
in `tests/Api.Tests`.

## Repository constraints and commands

Only edit files under `tests/`, following existing test naming and analyzer
settings. Do not change production code, infrastructure, dependency manifests,
or workflow configuration. Use the injected `TimeProvider` for deterministic
clock-dependent tests; avoid real network calls and test ordering dependencies.
Verify current gaps rather than assuming `ITaskStore.Delete` or missing-task
updates remain uncovered.

Run the complete command:

```sh
dotnet test AgenticDevOps.sln -c Release --collect "XPlat Code Coverage" --settings coverlet.runsettings --results-directory ./TestResults
```

CI requires at least 60% line coverage. Report the exact command result and before/after
coverage when measured; do not lower the gate or suppress restore/build errors.

Use a draft PR title like `test: improve coverage for <area>`. Never merge,
deploy, promote, apply infrastructure, or publish.
