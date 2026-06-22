# Repository Purpose

`avvo.ai.orch` is the central orchestration repository for AI-assisted development across the workspace. It:

- Distributes shared OpenCode instructions to other repositories
- Maintains PRD and SPEC templates for the Spec-Driven Design workflow
- Stores shared skills, references, and automation scripts
- Keeps multi-repo delivery conventions consistent

This is not an application repository. Most changes here affect instructions, templates, and orchestration behavior.

## Repository Structure

```text
avvo.ai.orch/
|- global/                     # Shared instructions and OpenCode assets
|  |- AGENTS.md                # Base instructions merged into every repo
|  \- .opencode/
|     \- skills/              # Global skills
|- Backend/                    # Backend-specific overlay
|- Frontend/                   # Frontend-specific overlay
|- merged/                     # Generated output, never committed
|- shared/                     # Cross-repo reference documents
|- specs/                      # Shared specs for active and completed work
|- templates/                  # PRD and SPEC templates
|- scripts/                    # Setup and support automation
\- README.md
```

## How Distribution Works

`make setup` regenerates the merged instructions used by the workspace.

For each target repo, the setup script:

1. Copies `global/.opencode/` into `merged/<repo>/.opencode/`
2. Overlays `<repo>/.opencode/` on top when repo-specific assets exist
3. Concatenates `global/AGENTS.md`, optional `shared/*.md`, and `<repo>/AGENTS.md` into `merged/<repo>/AGENTS.md`
4. Deploys `.opencode/`, `AGENTS.md`, and `specs/` into the target repo

Never edit generated files in consumer repos directly. Edit the source files here and rerun `make setup`.

## Common Commands

```bash
# Refresh merged instructions and workspace links
make setup

# Create a spec folder for the next sequential work item
mkdir -p specs/developing/0001
touch specs/developing/0001/0001.prd.md
touch specs/developing/0001/0001.spec.md

# Mark a spec as complete
mv specs/developing/0001 specs/done/0001
```

## SDD Workflow

1. Discovery Chat
- Use `templates/prd-template.md`
- Output to `specs/developing/<id>/<id>.prd.md`

2. Planning Chat
- Use `templates/spec-template.md`
- Output to `specs/developing/<id>/<id>.spec.md`

3. Implementation Chat
- Open the target repo
- Execute only what the approved spec defines

## Updating The Orchestration Repo

Update `global/` when the change applies to every repo.

Update a repo overlay directory when the change is stack-specific.

After any change to `global/`, `shared/`, `templates/`, `scripts/`, or a repo overlay, run:

```bash
make setup
```

## Key Files

| File | Purpose |
|---|---|
| `global/AGENTS.md` | Shared workspace instructions |
| `global/.opencode/skills/` | Global OpenCode skills |
| `templates/prd-template.md` | Discovery template |
| `templates/spec-template.md` | Planning template |
| `scripts/setup_symlinks.sh` | Merge and deployment logic |
| `specs/` | Shared specifications |

## Development Notes

- Do not commit `merged/`
- Do not manually edit generated `.opencode/` or `AGENTS.md` files in consumer repos
- Do commit source files under `global/`, repo overlays, `templates/`, `scripts/`, and `specs/`

## Reference

- Orchestration root: `avvo.ai.orch/`
- Merge output: `avvo.ai.orch/merged/`
- Setup entrypoint: `make setup`
