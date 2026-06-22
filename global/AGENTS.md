# AI Agent Instructions

This workspace contains multiple repositories coordinated by `avvo.ai.orch`.

## Workspace Structure
|-- avvo.ai.orch/                   # OpenCode orchestration, specs, templates, skills
|-- Backend/                      # Backend API built with Dotnet 8
|-- Frontend/                     # Frontend application built with NextJS
|-- iob.pme.playwrite.automation/  # Playwright automation scripts

## Core Workflow
- Run `make setup` in `avvo.ai.orch` whenever you need to refresh generated `.opencode/`, `AGENTS.md`, and shared `specs/` links.
- Use the `git-workflow` skill for branch, commit, and PR conventions: `global/.opencode/skills/git-workflow/SKILL.md`.
- Use the `start-development` skill when implementation work is tied to a Trello card and a spec in `specs/`.
