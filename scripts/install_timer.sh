#!/usr/bin/env bash
# scripts/install_timer.sh — instala timer.sh em ~/.config/opencode/dev-timers/
# Chamado por `make setup`.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/timer.sh"
DEST_DIR="$HOME/.config/opencode/dev-timers"
DEST="$DEST_DIR/timer.sh"

mkdir -p "$DEST_DIR"
cp -f "$SRC" "$DEST"
chmod +x "$DEST"

echo "✓ Timer instalado em $DEST"
