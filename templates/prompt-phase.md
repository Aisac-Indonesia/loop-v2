# Phase: {{PHASE_ID}} - {{PHASE_NAME}}

Reference: phases/{{PHASE_FILE}}

## Task
Execute the {{PHASE_NAME}} phase of the Sainskerta Loop workflow.

## Steps
1. Read the reference phase document
2. Execute all phase tasks
3. Update templates/progress.md with results

## Requirements
- Follow Sainskerta standards (modular monolith, no foreign keys, soft delete)
- No hardcoded dummy data — all via database
- Update progress.md after completion

## Allowed Tools
Read(*), Write(*), Edit(*), Bash(*)
