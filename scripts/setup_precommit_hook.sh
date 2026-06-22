#!/bin/sh
# Run this once per developer after cloning the repo.
# It points Git to the shared .githooks/ directory.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR=$1
VERBOSE=$2
HOOKS_DIR=".githooks"

cd "$REPO_DIR" || exit 1

if [ ! -d "$HOOKS_DIR" ]; then
  mkdir -p "$HOOKS_DIR"
fi

if [ ! -f "$HOOKS_DIR/commit-msg" ]; then
  cp "$SCRIPT_DIR/$HOOKS_DIR/commit-msg" "$HOOKS_DIR"
fi

chmod +x "$HOOKS_DIR/commit-msg"
git config core.hooksPath "$HOOKS_DIR"

if [ "$VERBOSE" = "--verbose" ]; then
  echo ""
  echo "  ✔ Git hooks configured ($(basename "$REPO_DIR")/)"
  echo "    Commit tagging: [AI-ASSISTED] / [NO-AI] / prompt"
fi