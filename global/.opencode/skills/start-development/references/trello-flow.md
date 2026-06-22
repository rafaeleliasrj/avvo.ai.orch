# Trello Flow Reference

The `start-development` skill assumes a Trello board with these lists:

| List | Meaning |
|---|---|
| `Backlog` | Work not started |
| `Em andamento` | Active implementation |
| `Code Review` | Waiting for human review |
| `Done` | Delivered and finished |
| `Cancelado` | Work cancelled or superseded |

## Required MCP Capabilities

The recommended MCP server is `atlassian-trello-mcp`.

The skill expects these tools to exist:

- `list_boards`
- `get_lists`
- `trello_search`
- `get_card`
- `move_card`
- `trello_add_comment`
- `trello_add_member_to_card`

## Work Item Convention

- IDs are sequential: `0001`, `0002`, `0003`
- Specs live under `specs/developing/<id>/`
- Branches use `feature/<id>` unless another type is explicitly requested

## Normal Card Movement

```text
Backlog -> Em andamento -> Code Review -> Done
```

## Cancellation Path

```text
Backlog -> Cancelado
Em andamento -> Cancelado
Code Review -> Cancelado
```

## Notes

- Trello does not enforce workflow transitions natively. The skill validates list names instead.
- The skill never moves a card backwards unless the developer explicitly asks for it.
- When scope changes mid-flight, the skill comments on the card and leaves it in `Em andamento`.
