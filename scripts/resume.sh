#!/bin/bash
# Sainskerta Loop V2 — Resume from Checkpoint
# Usage: scripts/resume.sh
# Finds the first pending/failed phase and continues (auto-start) or prompts retry.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKFLOW_DIR="$(dirname "$SCRIPT_DIR")"
STATE_SH="$SCRIPT_DIR/state.sh"
STATE="$WORKFLOW_DIR/.taskflow/state.json"

PHASES="00-PREREQUISITES 01-PLANNING 02-WIREFRAME-AUDIT 03-BACKEND 04-FRONTEND 05-AUDIT 06-DEPLOYMENT 07-IMPROVEMENT"

help() {
  cat << 'HELP'
Usage: resume.sh

Reads .taskflow/state.json, prints completed phases, then finds the first phase
whose status is 'pending' or 'failed':
  failed  -> warn and ask whether to retry
  pending -> auto-start scripts/phase-runner.sh --phase <id>

Options:
  --help, -h   Show this help
HELP
}

case "${1:-}" in
  --help|-h) help; exit 0 ;;
esac

phase_status() {
  grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$STATE" | head -n1 | sed -E 's/.*"([^"]*)"$/\1/'
}

echo "=== Resume: Checkpoint ==="
echo "Completed phases:"
found_any=0
for p in $PHASES; do
  st="$(phase_status "$p")"
  if [ "$st" = "completed" ]; then echo "  [x] $p"; found_any=1; fi
done
[ "$found_any" -eq 1 ] || echo "  (none yet)"
echo ""

# Find first pending or failed phase
target=""; target_status=""
for p in $PHASES; do
  st="$(phase_status "$p")"
  if [ "$st" = "failed" ] || [ "$st" = "pending" ] || [ "$st" = "running" ] || [ "$st" = "waiting" ]; then
    target="$p"; target_status="$st"; break
  fi
done

if [ -z "$target" ]; then
  echo "All phases complete. Nothing to resume."
  exit 0
fi

echo "Next phase: $target (status: $target_status)"

case "$target_status" in
  failed)
    echo "WARNING: phase $target previously FAILED."
    printf "Retry it now? [y/N] "
    read -r ans
    case "$ans" in
      y|Y|yes) exec "$SCRIPT_DIR/phase-runner.sh" --phase "$target" ;;
      *) echo "Aborted. Fix the phase, then re-run resume.sh."; exit 1 ;;
    esac
    ;;
  pending|running|waiting)
    echo "Auto-starting phase-runner for $target..."
    exec "$SCRIPT_DIR/phase-runner.sh" --phase "$target"
    ;;
esac
