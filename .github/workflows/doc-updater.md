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

tools:
  github:
    toolsets: [default]

safe-outputs:
  create-pull-request:
    max: 1
  missing-tool:
---

# Documentation Updater Agent

You keep the repository documentation in sync with the code. This workflow runs
after changes land on `main` under `src/`, `infra/`, or `.github/workflows/`.

## What to do

1. Review the most recent changes on `main` (the latest commit(s) that triggered
   this run). Focus on what changed in the application code, the Terraform
   infrastructure, and the GitHub Actions / agentic workflows.
2. Inspect the existing documentation, primarily:
   - `README.md`
   - any files under `docs/`
   - `.github/copilot-instructions.md` and `AGENTS.md`
3. Identify documentation that is now **stale, missing, or inaccurate** because of
   the change — for example new endpoints, changed environment variables, new
   Terraform variables/outputs, altered deployment steps, or new workflows.
4. Make the smallest set of edits that brings the docs back into accuracy. Update
   tables, command snippets, architecture notes, and the API surface description
   as needed. Keep the existing tone and structure.

## Output

- Open **one** pull request containing only documentation changes.
- Use a clear title like `docs: sync documentation with recent changes`.
- In the PR body, summarise what changed in the code and exactly which docs you
  updated, as a short bullet list.

## Guardrails

- **Only** modify Markdown / documentation files. Never change application code,
  Terraform, Dockerfiles, or workflow definitions.
- If nothing is out of date, do not open a pull request — say so and stop.
- Do not fabricate behaviour; describe only what the code actually does.
