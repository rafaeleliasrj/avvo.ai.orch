---
name: git-workflow
description: "Use when needed to run any git command or follow the team's git workflow. Always include the sequential work item ID in branch names and PR titles."
argument-hint: "Work item ID (required); work type (feature, hotfix, automation); target repo(s)"
---

# Git Workflow Guide

## Guide
This guide defines the branch, PR, and QA flow by work type. Always include the sequential work item ID in branch names and PR titles.

### Common Rules
- Start from `master`/`main` unless the flow states otherwise.
- Use work item IDs in branch names and PR titles.
- Keep work in the work item branch; do not commit directly to `master`/`main`.
- Branch roles: `develop` (integration), `release` (pre-production), `master`/`main` (production).

### Work Item Relationship

- Git branches must be created using the primary sequential work item ID.
- Do not create multiple branches for the same work item unless explicitly required.
- Secondary internal notes can be referenced in commit messages when useful, but branch names and PR titles must use the main work item ID.

Example:

Work item: 0001

Branch:
- feature/0001

### Features
Work item pattern: `0001`

1. Create a branch from `master`/`main`: `<type>/<work-item-id>`.
2. Implement changes and commit.
3. Open PR to `develop` for QA validation.
4. When QA approves on `develop`, open a PR to `release`.
5. Open PR from `release` to `master`/`main`.
6. Fix rules:
   - If QA finds issues before `master`/`main`, fix in the same branch and reopen PR to `develop`.
   - If QA finds issues on `master`/`main`, create a new sequential work item, branch from `master`/`main`, and open a PR to `develop`. When QA approves, follow the standard flow.

### Hotfix
Hotfixes follow the same flow as [Features](#features).

### Automation
Target repo: `iob.pme.playwrite.automation` (usually)

1. Create an item branch from `main`.
2. Implement changes and commit.
3. Open PR to `develop`.
4. Run and validate tests.
5. When the features are released to production, open a PR from `develop` to `main`.

## Git conventions
- Branch naming: `<type>/<work-item-id>` (e.g., `feature/0001` or `hotfix/0042`).
- Commit messages: `<type>(<work-item-id>): <short description> (--ai|--no-ai)` (e.g., `feat(0001): add new feature --ai`).
- PR titles: `<work-item-id>: <short description> ([AI-ASSISTED]|[NO-AI])` (e.g., `0001: add new feature [AI-ASSISTED]`).

## Git commands
- Create branch: `git checkout -b <branch-name> origin/<base-branch>`
- Commit changes: `git add . && git commit -m <commit-msg>`
- Push branch: `git push origin <branch-name>`
- Change current branch: `git checkout <branch-name>`
- Create PR: Use BitBucket UI to create PR from `<branch-name>` to target branch (e.g., `develop`, `master`/`main`).

## Required Inputs
- Work item ID (e.g., 0001)
- Work type (feature, hotfix, automation)
- Target repo(s)

## Steps
1. Confirm work item ID, work type, and target repo(s); if the ID is missing or does not match the expected sequential pattern, stop and request a valid ID.
2. Identify the correct base branch per workflow.
3. Define the branch name to create.
4. List the PR sequence and target branches for QA and release.
5. Call out the follow-up work item flow when relevant.
