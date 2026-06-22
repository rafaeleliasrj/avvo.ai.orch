# Makefile for avvo.ai.orch

.PHONY: setup setup-verbose install-timer rtk-check rtk-enable rtk-disable rtk-status help

setup:
	@bash scripts/setup_symlinks.sh
	@bash scripts/install_timer.sh
	@bash scripts/rtk.sh check

setup-verbose:
	@bash scripts/setup_symlinks.sh --verbose
	@bash scripts/install_timer.sh
	@bash scripts/rtk.sh check

install-timer:
	@bash scripts/install_timer.sh

rtk-check:
	@bash scripts/rtk.sh check

rtk-enable:
	@bash scripts/rtk.sh enable

rtk-disable:
	@bash scripts/rtk.sh disable

rtk-status:
	@bash scripts/rtk.sh status

help:
	@echo "avvo.ai.orch"
	@echo ""
	@echo "Targets:"
	@echo "  make setup         — configure OpenCode workspace assets"
	@echo "  make setup-verbose — configure with detailed output"
	@echo ""
	@echo "RTK integration (https://github.com/rtk-ai/rtk):"
	@echo "  make rtk-status    — show RTK binary state"
	@echo "  make rtk-check     — quick check (used by 'make setup')"
	@echo "  make rtk-enable    — install RTK (if missing)"
	@echo "  make rtk-disable   — show RTK cleanup guidance"
	@echo ""
	@echo "  make help          — show this help"
