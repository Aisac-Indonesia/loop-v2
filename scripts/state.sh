#!/bin/bash
# Sainskerta Loop V2 — State Manager
# Usage: scripts/state.sh [init|get|set|advance|wait|resume|status|--help]

set -e
STATE_FILE="$(dirname "$0")/../.taskflow/state.json"
LOG_FILE="$(dirname "$0")/../logs/state.log"

log() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"; }

help() {
  cat << 'HELP'
Usage: state.sh <command> [args]

Commands:
  init              Create fresh state.json
  get <field>       Get a field value
  set <field> <val> Set a field value
  advance           Move to next phase
  wait <reason>     Set waiting mode
  resume            Clear waiting mode
  status            Pretty print state
HELP
}

init() {
  mkdir -p "$(dirname "$STATE_FILE")"
  cat > "$STATE_FILE" << 'JSON'
{"projectName":"","createdAt":"","lastUpdated":"","currentPhase":"00-PREREQUISITES","phaseStatus":{"00-PREREQUISITES":"pending","01-PLANNING":"pending","02-WIREFRAME-AUDIT":"pending","03-BACKEND":"pending","04-FRONTEND":"pending","05-AUDIT":"pending","06-DEPLOYMENT":"pending","07-IMPROVEMENT":"pending"},"phaseHistory":[],"waitState":{"waiting":false,"reason":"","approved":null,"since":""},"metadata":{"version":"2.0.0","workflow":"sainskerta-loop-v2"}}
JSON
  log "State initialized"
  echo "[OK] State initialized"
}

get() {
  local key="$1"
  [ -f "$STATE_FILE" ] || { echo "[]"; return; }
  grep -o "\"$key\":\"[^\"]*\"" "$STATE_FILE" 2>/dev/null | head -1 | sed "s/\"$key\":\"//;s/\"//"
}

set_field() {
  local key="$1"
  local val="$2"
  [ -f "$STATE_FILE" ] || init
  sed -i "s|\"$key\":\"[^\"]*\"|\"$key\":\"$val\"|g" "$STATE_FILE"
  log "Set $key = $val"
}

advance() {
  local phases=("00-PREREQUISITES" "01-PLANNING" "02-WIREFRAME-AUDIT" "03-BACKEND" "04-FRONTEND" "05-AUDIT" "06-DEPLOYMENT" "07-IMPROVEMENT")
  local cur=$(get currentPhase)
  local idx=-1
  for i in "${!phases[@]}"; do
    if [ "${phases[$i]}" = "$cur" ]; then
      idx=$i
      break
    fi
  done
  if [ $idx -ge 0 ] && [ $idx -lt $((${#phases[@]}-1)) ]; then
    set_field "currentPhase" "${phases[$((idx+1))]}"
    log "Advanced: $cur -> ${phases[$((idx+1))]}"
    echo "[OK] Advanced to ${phases[$((idx+1))]}"
  else
    echo "[DONE] All phases complete"
  fi
}

wait_phase() {
  local reason="$1"
  set_field "waiting" "true"
  set_field "reason" "$reason"
  log "WAITING: $reason"
  echo "[WAIT] $reason"
}

resume_phase() {
  set_field "waiting" "false"
  set_field "reason" ""
  set_field "approved" "true"
  log "Resumed"
  echo "[OK] Resumed"
}

status() {
  [ -f "$STATE_FILE" ] || { echo "No state file found. Run init first."; return; }
  echo "=== Sainskerta Loop V2 - State ==="
  echo "Project:  $(get projectName)"
  echo "Phase:    $(get currentPhase)"
  echo "Waiting:  $(get waiting)"
  echo "Reason:   $(get reason)"
  echo "================================"
}

case "${1:-}" in
  init) init ;;
  get) get "$2" ;;
  set) set_field "$2" "$3" ;;
  advance) advance ;;
  wait) wait_phase "$2" ;;
  resume) resume_phase ;;
  status) status ;;
  --help|-h) help ;;
  *) help ;;
esac
