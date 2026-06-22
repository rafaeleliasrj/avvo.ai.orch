#!/bin/bash
# scripts/rtk.sh
# Manage RTK (Rust Token Killer) integration for the OpenCode workspace.
# Ref: https://github.com/rtk-ai/rtk
#
# Subcommands:
#   check    — verify if rtk binary is installed
#   enable   — install binary if missing
#   disable  — print manual removal guidance for local shell integrations
#   status   — print current state

set -euo pipefail

RTK_INSTALL_URL="https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh"
OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"

color_red()    { printf "\033[31m%s\033[0m" "$1"; }
color_green()  { printf "\033[32m%s\033[0m" "$1"; }
color_yellow() { printf "\033[33m%s\033[0m" "$1"; }

rtk_installed() {
  command -v rtk >/dev/null 2>&1
}

cmd_status() {
  echo "RTK integration status"
  echo "----------------------"
  if rtk_installed; then
    echo "  binary : $(color_green "installed")  ($(rtk --version 2>/dev/null || echo unknown))"
  else
    echo "  binary : $(color_red "missing")"
  fi

  echo "  config : $OPENCODE_CONFIG_DIR"
}

cmd_check() {
  if ! rtk_installed; then
    echo "$(color_yellow "[rtk]") binary not found — run 'make rtk-enable' to install."
    return 0
  fi
  echo "$(color_green "[rtk]") installed. Configure it in your OpenCode shell workflow if desired."
}

install_binary() {
  if rtk_installed; then
    return 0
  fi
  echo "RTK binary not found. Installing via curl install script..."
  echo "  Source: $RTK_INSTALL_URL"
  if ! command -v curl >/dev/null 2>&1; then
    echo "$(color_red "ERROR"): curl is required to install RTK. Install curl or visit https://github.com/rtk-ai/rtk for alternatives." >&2
    exit 1
  fi
  curl -fsSL "$RTK_INSTALL_URL" | sh
  if ! rtk_installed; then
    echo "$(color_red "ERROR"): RTK installation finished but 'rtk' is not in PATH." >&2
    echo "  Open a new shell or update your PATH and try again." >&2
    exit 1
  fi
  echo "$(color_green "✓") RTK binary installed: $(rtk --version 2>/dev/null || echo unknown)"
}

cmd_enable() {
  install_binary
  echo "$(color_green "✓") RTK installed. Integrate it with your preferred shell commands in OpenCode if desired."
}

cmd_disable() {
  echo "$(color_yellow "[rtk]") OpenCode does not use the legacy Claude hook file."
  echo "  Remove any manual RTK shell aliases or wrappers from your local environment if you no longer want to use it."
}

usage() {
  cat <<EOF
Usage: $0 {check|enable|disable|status}

  check    Verify RTK binary + hook state (non-failing).
  enable   Install rtk (if missing).
  disable  Print manual cleanup guidance.
  status   Print detailed integration status.

Ref: https://github.com/rtk-ai/rtk
EOF
}

main() {
  local sub="${1:-}"
  case "$sub" in
    check)   cmd_check ;;
    enable)  cmd_enable ;;
    disable) cmd_disable ;;
    status)  cmd_status ;;
    ""|-h|--help|help) usage ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"
