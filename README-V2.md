# Sainskerta Loop V2 — TaskFlow Edition

> **Loop Engineering with Persistent State & Human-in-the-Loop Orchestration**

## What's New in V2

| Feature | V1 | V2 |
|---------|----|----|
| State management | Shell variables (lost on crash) | **JSON persistent** (.taskflow/state.json) |
| Approval gates | Manual check | **Auto wait/resume** |
| Crash recovery | Lost progress | **Resume from checkpoint** |
| Sub-agent orchestration | None | **Per-phase orchestration** |
| Logging | Minimal | **Structured logs** (logs/) |

## Architecture

```
┌─────────────────────────────────────────────────┐
│                 run-flow.sh                      │
│          (Main Orchestrator)                     │
└──────────┬──────────────────────┬───────────────┘
           │                      │
    ┌──────▼──────┐       ┌──────▼──────┐
    │  state.sh   │       │phase-runner │
    │ (Manager)   │◄─────►│   .sh       │
    └──────┬──────┘       └──────┬──────┘
           │                     │
    ┌──────▼──────┐       ┌──────▼──────┐
    │.taskflow/   │       │   Claude    │
    │ state.json  │       │   Code      │
    └─────────────┘       └─────────────┘
```

## Quickstart

```bash
# 1. Start fresh workflow
./scripts/run-flow.sh --start

# 2. Run phases one by one
./scripts/phase-runner.sh --phase 00-PREREQUISITES
./scripts/phase-runner.sh --phase 01-PLANNING
./scripts/phase-runner.sh --phase 02-WIREFRAME-AUDIT
# ...continue through all 8 phases

# 3. Check status anytime
./scripts/run-flow.sh --status

# 4. Resume after interruption
./scripts/run-flow.sh --resume
```

## Phase Lifecycle

```
pending → running → waiting → completed
                                     → failed (retry)
```

| Phase | Needs Approval | Status |
|-------|---------------|--------|
| 00-PREREQUISITES | ✅ Yes | Setup DB, framework, env |
| 01-PLANNING | ✅ Yes | Architecture & planning |
| 02-WIREFRAME-AUDIT | ✅ Yes | Wireframe → Mockup → Approve |
| 03-BACKEND | ❌ No | Backend coding |
| 04-FRONTEND | ❌ No | Frontend coding |
| 05-AUDIT | ✅ Yes | Security, perf, code review |
| 06-DEPLOYMENT | ✅ Yes | Build, deploy, SSL |
| 07-IMPROVEMENT | ❌ No | Loop maintenance |

## File Structure

```
sainskerta-loop-workflow-v2/
├── .taskflow/
│   └── state.json              ← Persistent state
├── phases/                     ← 8 phase documents (from V1)
├── standards/                  ← 5 standard documents (from V1)
├── templates/
│   ├── progress.md             ← Progress tracking
│   ├── user_requirement.md     ← User requirement file
│   ├── loop.md                 ← Loop state
│   ├── taskflow-config.json    ← Workflow config
│   └── prompt-phase.md         ← Phase prompt template
├── scripts/
│   ├── state.sh                ← State manager
│   ├── phase-runner.sh         ← Phase executor
│   ├── wait-for-approval.sh    ← Approval waiter
│   ├── resume.sh               ← Resume from checkpoint
│   └── run-flow.sh             ← Main orchestrator
├── orchestrator/
│   ├── flow-plan.yaml          ← Phase dependency graph
│   └── phase-prompts/          ← Claude Code prompts per phase
├── logs/                       ← Execution logs
├── README-V2.md                ← This file
├── CHANGELOG.md                ← Version history
└── MIGRATION.md                ← V1 to V2 migration guide
```

## Usage

### Starting a New Project

```bash
cp -r sainskerta-loop-workflow-v2/ my-new-project/
cd my-new-project/
./scripts/run-flow.sh --start
# Edit templates/user_requirement.md with project details
./scripts/phase-runner.sh --phase 00-PREREQUISITES
```

### Resuming After Crash

```bash
cd my-project/
./scripts/run-flow.sh --resume
# Shows current phase, continues from last checkpoint
```

### Waiting for Approval

When a phase needs approval (wireframe, audit, deploy):
1. Script auto-pauses
2. Edit `templates/user_requirement.md`
3. Script detects the change and resumes

## Requirements

- Bash 4.0+
- Claude Code (`claude-privasimu`)
- `sed` and `grep` (pre-installed on all Linux)
- `jq` (optional, for pretty JSON)

## Migration from V1

See [MIGRATION.md](MIGRATION.md) for detailed steps.
