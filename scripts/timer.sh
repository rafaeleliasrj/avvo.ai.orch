#!/usr/bin/env bash
# scripts/timer.sh — dev session timer for the start-development skill
# Installed to ~/.config/opencode/dev-timers/timer.sh by `make setup`.
#
# Usage:
#   timer.sh start   <ID>   — inicia ou detecta timer existente
#   timer.sh elapsed <ID>   — mostra tempo decorrido
#   timer.sh stop    <ID>   — para e remove o timer

set -euo pipefail

TIMER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CMD="${1:-}"
ID="${2:-}"

if [[ -z "$CMD" || -z "$ID" ]]; then
    echo "Uso: timer.sh <start|elapsed|stop> <ID>" >&2
    exit 1
fi

TIMER_FILE="$TIMER_DIR/${ID}.timer"

_format_elapsed() {
    local seconds=$1
    local h=$(( seconds / 3600 ))
    local m=$(( (seconds % 3600) / 60 ))
    if [[ $h -gt 0 ]]; then
        printf "%dh %dm" "$h" "$m"
    else
        printf "%dm" "$m"
    fi
}

_format_ts() {
    local ts=$1
    # GNU date (Linux / Git Bash no Windows)
    date -d "@$ts" "+%Y-%m-%d %H:%M %Z" 2>/dev/null \
        || date -r "$ts" "+%Y-%m-%d %H:%M %Z" 2>/dev/null \
        || echo "desconhecido"
}

case "$CMD" in
    start)
        if [[ -f "$TIMER_FILE" ]]; then
            START_TS=$(cat "$TIMER_FILE")
            NOW=$(date +%s)
            DIFF=$(( NOW - START_TS ))
            ELAPSED=$(_format_elapsed "$DIFF")
            START_FMT=$(_format_ts "$START_TS")
            echo "RESUMED: $ELAPSED  (iniciado em $START_FMT, raw: ${DIFF}s)"
        else
            NOW=$(date +%s)
            echo "$NOW" > "$TIMER_FILE"
            START_FMT=$(_format_ts "$NOW")
            echo "STARTED: $ID  (iniciado em $START_FMT)"
        fi
        ;;

    elapsed)
        if [[ ! -f "$TIMER_FILE" ]]; then
            echo "ELAPSED: timer não encontrado para '$ID'" >&2
            exit 1
        fi
        START_TS=$(cat "$TIMER_FILE")
        NOW=$(date +%s)
        DIFF=$(( NOW - START_TS ))
        ELAPSED=$(_format_elapsed "$DIFF")
        START_FMT=$(_format_ts "$START_TS")
        echo "ELAPSED: $ELAPSED   (raw: ${DIFF}s, iniciado em $START_FMT)"
        ;;

    stop)
        if [[ -f "$TIMER_FILE" ]]; then
            START_TS=$(cat "$TIMER_FILE")
            NOW=$(date +%s)
            DIFF=$(( NOW - START_TS ))
            ELAPSED=$(_format_elapsed "$DIFF")
            rm -f "$TIMER_FILE"
            echo "STOPPED: $ID  —  tempo total: $ELAPSED  (raw: ${DIFF}s)"
        else
            echo "STOPPED: timer para '$ID' não existia (já parado ou nunca iniciado)"
        fi
        ;;

    *)
        echo "Comando inválido: '$CMD'. Use start, elapsed ou stop." >&2
        exit 1
        ;;
esac
