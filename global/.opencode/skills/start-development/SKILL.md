---
name: start-development
description: >
  Use when a developer wants to start, continue, or finish implementation work linked to a Trello card
  and a spec under specs/. This skill orients itself from avvo.ai.orch, loads the PRD/SPEC for a
  sequential work item like 0001, updates the Trello card flow, implements the approved plan, and stops
  at a mandatory human checkpoint before commit or card movement to the next review state.
---

# Start Development

This skill coordinates implementation work across `avvo.ai.orch`, the target repository, and Trello.

## Sources Of Truth

1. `avvo.ai.orch/global/AGENTS.md`
2. `specs/developing/<id>/<id>.prd.md`
3. `specs/developing/<id>/<id>.spec.md`
4. The Trello card linked to the same work item ID

If the Trello card and the spec diverge, the spec wins.

## Required Trello Setup

The board must expose these lists:

- `Backlog`
- `Em andamento`
- `Code Review`
- `Done`
- `Cancelado`

Reference: `references/trello-flow.md`

## Operating Flow

### 1. Orient

Read `avvo.ai.orch/AGENTS.md` context and locate the work item folder in `specs/developing/<id>/`.

### 2. Load The Spec

Read both files when available:

- `specs/developing/<id>/<id>.prd.md`
- `specs/developing/<id>/<id>.spec.md`

Extract:

- target repository
- implementation scope
- files to change
- explicit constraints

### 3. Load The Trello Card

Using the Trello MCP server:

1. Find the board with `list_boards`
2. Find the card with `trello_search` using the sequential ID
3. Read current list, members, comments, and description with `get_card`

### 4. Present Context

Show the developer:

```text
WORK ITEM: 0001
Card: <name>
List: <Backlog|Em andamento|Code Review|Done|Cancelado>
Spec: specs/developing/0001/0001.spec.md
Target repo: <repo>
```

### 5. Start Work

When the developer confirms implementation:

1. Move the card to `Em andamento` if it is still in `Backlog`
2. Assign the current developer to the card when possible
3. Start the timer with `~/.config/opencode/dev-timers/timer.sh start <id>`
4. Present a concise technical plan before writing code

### 6. Implement

Implement only the approved scope from the spec.

Rules:

- Do not expand scope silently
- Keep branch naming tied to the work item ID, for example `feature/0001`
- If the spec requires substantial changes, use a delegated agent or isolated worktree when useful

### 7. Mandatory Checkpoint

Before any commit or Trello card review movement, stop and present:

- changed files
- summary of implementation
- tests run
- proposed commit message
- proposed Trello comment
- proposed next list, usually `Code Review`

Wait for explicit approval.

### 8. After Approval

Only after approval:

1. Commit the code
2. Add the approved Trello comment
3. Move the card to `Code Review` unless the developer asked for another state
4. Stop the timer

### 9. Special Cases

- No implementation needed:
  comment on the card, move to `Cancelado` after approval, stop the timer
- Scope changed during implementation:
  add a Trello comment, keep the card in `Em andamento`, preserve the timer for resumption
- Partial session:
  do not commit, do not move to `Code Review`, keep the card in `Em andamento`

## Forbidden Actions

- Commiting before the mandatory checkpoint
- Moving the card to a review state without approval
- Expanding scope beyond the approved spec
- Treating Trello as the source of truth when the spec says otherwise

## Related Files

- `global/.opencode/skills/git-workflow/SKILL.md`
- `global/.opencode/skills/start-development/references/trello-flow.md`
