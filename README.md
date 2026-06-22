# AI Orchestration Workspace

`avvo.ai.orch` is the repository that coordinates OpenCode instructions, shared specs, and automation across the workspace.

## Workspace Layout

```text
/workspace
|- avvo.ai.orch/                  # Central orchestration repo
|- Backend/                       # Backend source code
|- Frontend/                      # Frontend source code
\- iob.pme.playwrite.automation/  # E2E automation
```

## What `make setup` Produces

Each target repository receives generated OpenCode assets:

- `.opencode/` merged from `global/.opencode/` plus any repo-specific overlay
- `AGENTS.md` copied from a merged file built from `global/AGENTS.md`, shared references, and any repo-specific `AGENTS.md`
- `specs/` linked back to the shared spec repository

These generated artifacts are managed by this repository and should not be edited by hand in consumer repos.

## Repository Structure

```text
avvo.ai.orch/
|- global/
|  |- AGENTS.md
|  \- .opencode/
|     \- skills/
|- shared/
|- templates/
|- specs/
|- scripts/
|- merged/                        # Generated, not committed
\- README.md
```

## SDD Workflow

### 1. Discovery
- Open the workspace root so the agent can see all repos.
- Research impact, dependencies, and reusable patterns.
- Output: `specs/developing/<id>/<id>.prd.md`

### 2. Planning
- Use the PRD plus workspace rules.
- Define file-level changes and implementation iterations.
- Output: `specs/developing/<id>/<id>.spec.md`

### 3. Implementation
- Open the target repo.
- Execute only the relevant portion of the approved spec.

## Conventions

- Work item IDs are sequential: `0001`, `0002`, `0003`
- Specs live under `specs/developing/<id>/` and move to `specs/done/<id>/`
- Branches use the work item ID, for example `feature/0001`
- PR titles use the work item ID, for example `0001: add checkout validation`

## Adding Or Updating Shared Context

1. Edit `global/AGENTS.md` for workspace-wide instructions.
2. Edit `global/.opencode/skills/` for shared skills.
3. Edit `shared/*.md` for cross-repo references.
4. Edit repo overlay directories for stack-specific behavior.
5. Run `make setup`.

## RTK Integration

[RTK](https://github.com/rtk-ai/rtk) remains optional. `make setup` only checks whether it is available.

| Target | What it does |
|---|---|
| `make rtk-status` | Shows whether RTK is installed and whether the global OpenCode hook is active |
| `make rtk-check` | Quick RTK status check |
| `make rtk-enable` | Installs RTK if needed and enables the hook in the OpenCode global config |
| `make rtk-disable` | Removes the RTK hook from the OpenCode global config |

## Next Steps

1. Clone `avvo.ai.orch` alongside the consumer repositories.
2. Run `make setup`.
3. Start the next work item with a new sequential ID under `specs/developing/`.
