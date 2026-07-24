#!/bin/bash
# Sainskerta Loop V2 — Main Orchestrator
# Usage: scripts/run-flow.sh [--start|--resume|--status|--help]

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATE_SH="$SCRIPT_DIR/state.sh"

help() {
  cat << 'HELP'
Usage: run-flow.sh [command]

Commands:
  --start      Initialize and start from phase 00
  --resume     Resume from last checkpoint
  --status     Show current workflow state
  --advance    Manually advance to next phase
  --wait       Set waiting mode
  --help       Show this help
HELP
}

case "${1:-}" in
  --start)
    echo "=== Starting Sainskerta Loop V2 (fresh) ==="
    rm -f "$SCRIPT_DIR/../.taskflow/state.json"   # fresh state each --start
    $STATE_SH init
    echo ""
    echo "Running from phase 00-PREREQUISITES..."
    exec "$SCRIPT_DIR/phase-runner.sh" --phase 00-PREREQUISITES
    ;;
  --resume)
    echo "=== Resuming ==="
    bash "$SCRIPT_DIR/resume.sh"
    ;;
  --status)
    $STATE_SH status
    ;;
  --advance)
    $STATE_SH advance
    ;;
  --wait)
    $STATE_SH wait "${2:-Manual pause}"
    ;;
  --help|-h)
    help
    ;;
  *)
    help
    ;;
esac
