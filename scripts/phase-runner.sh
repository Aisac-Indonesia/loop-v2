#!/bin/bash
# Sainskerta Loop V2 — Phase Runner
# Usage: scripts/phase-runner.sh --phase <PHASE_ID>
# Marks the phase running, drives Claude Code from its phase doc, then advances
# (or enters a wait state for approval-gated phases, or marks failed on error).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKFLOW_DIR="$(dirname "$SCRIPT_DIR")"
STATE_SH="$SCRIPT_DIR/state.sh"

# Phases that pause for human approval instead of auto-advancing.
# ponytail: hardcoded gate; move to orchestrator/flow-plan.yaml if it grows.
APPROVAL_PHASES=" 02-WIREFRAME-AUDIT "

help() {
  cat << 'HELP'
Usage: phase-runner.sh --phase <PHASE_ID>

Phases:
  00-PREREQUISITES  01-PLANNING  02-WIREFRAME-AUDIT  03-BACKEND
  04-FRONTEND       05-AUDIT     06-DEPLOYMENT       07-IMPROVEMENT

Options:
  --phase <ID>   Phase to execute
  --help, -h     Show this help
HELP
}

while [ $# -gt 0 ]; do
  case "$1" in
    --phase) PHASE="$2"; shift 2 ;;
    --help|-h) help; exit 0 ;;
    *) echo "Unknown: $1"; help; exit 1 ;;
  esac
done

[ -n "${PHASE:-}" ] || { echo "Error: --phase required"; help; exit 1; }
PHASE_DOC="$WORKFLOW_DIR/phases/$PHASE.md"
PROMPT_FILE="$WORKFLOW_DIR/orchestrator/phase-prompts/$(echo "$PHASE" | tr 'A-Z' 'a-z').txt"
[ -f "$PHASE_DOC" ] || { echo "Error: phases/$PHASE.md not found"; exit 1; }

# 1. Mark running
$STATE_SH set currentPhase "$PHASE"
$STATE_SH phase "$PHASE" running
echo "Executing phase [$PHASE]..."
echo "Phase document: phases/$PHASE.md"

# 2. Build prompt (prefer per-phase template, else point Claude at the doc)
if [ -f "$PROMPT_FILE" ]; then
  PROMPT="$(cat "$PROMPT_FILE")"
else
  PROMPT="Execute the workflow phase documented in phases/$PHASE.md. Follow every step, then report completion."
fi

# 3. Drive Claude Code (sub-agent per phase). Prefer project CLI, fall back to `claude`.
run_claude() {
  if command -v claude-privasimu >/dev/null 2>&1; then
    claude-privasimu --allowed-tools "Read(*)" "Write(*)" "Edit(*)" "Bash(*)" -p "$PROMPT"
  elif command -v claude >/dev/null 2>&1; then
    claude -p "$PROMPT"
  else
    echo "  (no claude CLI found — dry run; prompt above would execute phase $PHASE)"
    return 0
  fi
}

# 4. On success: advance or wait for approval. On failure: mark failed.
if run_claude; then
  if [[ "$APPROVAL_PHASES" == *" $PHASE "* ]]; then
    $STATE_SH wait "Awaiting user approval for $PHASE"
    echo "=== [ $PHASE ] Needs approval — waiting ==="
    echo "Run: scripts/wait-for-approval.sh --reason \"Review $PHASE output\""
  else
    $STATE_SH advance
    echo "=== [ $PHASE ] Complete ==="
  fi
else
  $STATE_SH phase "$PHASE" failed
  $STATE_SH set status failed 2>/dev/null || true
  echo "=== [ $PHASE ] FAILED ===" >&2
  exit 1
fi
