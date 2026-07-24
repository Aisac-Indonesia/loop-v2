# Migrating from V1 to V2

## For New Projects

Just use V2 directly:

```bash
cp -r sainskerta-loop-workflow-v2/ my-new-project/
cd my-new-project/
./scripts/run-flow.sh --start
```

## For Existing V1 Projects

### Step 1: Copy V2 workflow alongside your project
```bash
# Your project is in: my-project/
# V2 workflow is in: sainskerta-loop-workflow-v2/
cp -r sainskerta-loop-workflow-v2/ my-project-v2/
cd my-project-v2/
```

### Step 2: Copy your project files
```bash
# Copy your project code
cp -r ../my-project/* ./
```

### Step 3: Initialize state
```bash
./scripts/run-flow.sh --start
```

### Step 4: Set current phase
If your project is at phase 03-BACKEND:
```bash
./scripts/state.sh set currentPhase "03-BACKEND"
./scripts/state.sh set projectName "my-project"
```

### Step 5: Verify and continue
```bash
./scripts/run-flow.sh --status
# Check that currentPhase matches your actual progress
```

### What Changed

| Aspect | V1 | V2 |
|--------|----|----|
| Progress tracking | Manual progress.md edits | JSON state + auto progress.md |
| Phase execution | Manual Claude Code calls | orchestrator/phase-runner.sh |
| Approval | Manual check-in | Auto wait/resume via file monitoring |
| Crash recovery | Lost progress | Resume from checkpoint |

### Rollback

Your V1 project folder is untouched. Just go back to using it as before:
```bash
cd ../my-project/
# Continue with V1 workflow normally
```
