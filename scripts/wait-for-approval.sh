#!/bin/bash
# Sainskerta Loop V2 — Approval Waiter
# Usage: scripts/wait-for-approval.sh --reason "..."
# Blocks until user_requirement.md is modified, then resumes state. Times out after 30 min.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKFLOW_DIR="$(dirname "$SCRIPT_DIR")"
STATE_SH="$SCRIPT_DIR/state.sh"
REQUIREMENT_FILE="$WORKFLOW_DIR/templates/user_requirement.md"

INTERVAL=30      # poll seconds
TIMEOUT=1800     # 30 minutes

help() {
  cat << 'HELP'
Usage: wait-for-approval.sh --reason "Reason for waiting"

Sets wait state, then polls templates/user_requirement.md every 30s for a
modification-time change. On change -> state.sh resume. Timeout: 1800s (30 min).

Options:
  --reason "..."   Reason shown while waiting (default: "Awaiting user approval")
  --help, -h       Show this help
HELP
}

while [ $# -gt 0 ]; do
  case "$1" in
    --reason) REASON="$2"; shift 2 ;;
    --help|-h) help; exit 0 ;;
    *) echo "Unknown: $1"; help; exit 1 ;;
  esac
done

REASON="${REASON:-Awaiting user approval}"

# mtime helper (portable-ish: GNU stat, fall back to BSD stat)
mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0; }

[ -f "$REQUIREMENT_FILE" ] || : > "$REQUIREMENT_FILE"

$STATE_SH wait "$REASON"

echo ""
echo "============================================"
echo "  WAITING: $REASON"
echo "  Edit $REQUIREMENT_FILE to approve."
echo "  Poll: ${INTERVAL}s   Timeout: ${TIMEOUT}s"
echo "============================================"
echo ""

start_mtime="$(mtime "$REQUIREMENT_FILE")"
elapsed=0
while [ "$elapsed" -lt "$TIMEOUT" ]; do
  sleep "$INTERVAL"
  elapsed=$((elapsed + INTERVAL))
  now_mtime="$(mtime "$REQUIREMENT_FILE")"
  if [ "$now_mtime" != "$start_mtime" ]; then
    echo "Change detected in user_requirement.md — resuming."
    $STATE_SH resume
    exit 0
  fi
  echo "  ...waiting (${elapsed}s / ${TIMEOUT}s)"
done

echo "TIMEOUT after ${TIMEOUT}s — no approval detected. Still waiting." >&2
exit 2
