# Changelog

## [2.0.0] - 2026-07-24

### Added
- JSON-based state persistence system (.taskflow/state.json)
- Wait/resume capability for human approval gates
- Sub-agent orchestration per phase
- State recovery on interruption
- New orchestrator scripts:
  - `scripts/state.sh` — state manager
  - `scripts/phase-runner.sh` — phase executor
  - `scripts/wait-for-approval.sh` — approval waiter
  - `scripts/resume.sh` — checkpoint resume
  - `scripts/run-flow.sh` — main orchestrator
- Structured logging (logs/ directory)
- TaskFlow configuration template
- Phase prompts for Claude Code per phase

### Preserved (from V1)
- All 8 phase documents (phases/*.md)
- All 5 standard documents (standards/*.md)
- Templates: progress.md, user_requirement.md, loop.md
- Documentation: RULES-OF-THE-GAME.md, CLI.md, DECISION-TREE.md, SKILL.md, FLOW.md, TEMPLATE-ARCHITECTURE.md
