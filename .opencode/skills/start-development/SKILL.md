---
name: start-development
description: >
  Use when a developer wants to start, continue, or finish implementation work linked to a Trello card
  and a spec under specs/. This skill orients itself from avvo.ai.orch, loads the PRD/SPEC for a
  sequential work item like 0001, updates the Trello card flow, implements the approved plan, and stops
  at a mandatory human checkpoint before commit or card movement to the next review state.
---

# Start Development

This local copy mirrors the shared skill under `global/.opencode/skills/start-development/`.

Follow the same Trello-based workflow:

1. Read `avvo.ai.orch/AGENTS.md`
2. Read `specs/developing/<id>/<id>.prd.md` and `specs/developing/<id>/<id>.spec.md`
3. Locate the Trello card for the sequential ID
4. Move the card to `Em andamento` when starting work
5. Implement only the approved scope
6. Stop at a mandatory checkpoint before commit or card movement to `Code Review`

Lists expected on the Trello board:

- `Backlog`
- `Em andamento`
- `Code Review`
- `Done`
- `Cancelado`

Timer path:

```text
~/.config/opencode/dev-timers/timer.sh
```

Reference the shared skill for the full operating details whenever possible.
