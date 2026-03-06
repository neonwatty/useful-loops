# Plan Refine — Design Document

**Date:** 2026-03-06
**Status:** Approved

## Overview

A self-contained, iterative skill that improves a plan document in-place according to a user-provided prompt. Unlike other codebase-sweeps skills, this skill does not touch code, create branches, open PRs, or run CI. It operates purely on plan files.

## Invocation

```
/codebase-sweeps:plan-refine "<PROMPT>" <PLAN_FILE> [--max N]
```

**Arguments:**
- `PROMPT` (required, quoted string) — instruction for how to analyze/improve the plan (e.g., "examine for gaps in error handling coverage")
- `PLAN_FILE` (required) — path to the plan file to iterate on
- `--max N` (optional, default: 5) — maximum number of iterations

**Examples:**
```
/codebase-sweeps:plan-refine "examine for gaps in error handling" docs/plans/architecture.md
/codebase-sweeps:plan-refine "strengthen the testing strategy" docs/plans/launch-plan.md --max 3
/codebase-sweeps:plan-refine "check for missing edge cases" docs/plans/api-design.md --max 10
```

## Architecture

### Single self-contained skill

One file: `commands/plan-refine.md`. No Ralph Loop dependency, no loop wrapper file. The skill handles its own iteration count internally.

**Rationale:** Plan editing is fundamentally lighter than the code-shipping sweeps. There is no git branching, PR creation, CI polling, or merge cycle — so the two-file split (single + loop) and Ralph Loop delegation add complexity without benefit.

### Per-Iteration Flow (4 Phases)

```
Phase 1: Read
  - Read the plan file
  - Read the tracking file (create on iteration 1)
  - Review prior iteration changes to avoid re-treading ground

Phase 2: Analyze
  - Apply the user's prompt to the current plan content
  - Identify specific improvements
  - Classify each: HIGH, MEDIUM, or LOW severity

Phase 3: Edit
  - Apply ALL findings (HIGH, MEDIUM, and LOW) directly to the plan file in-place

Phase 4: Track
  - Append an iteration entry to the tracking file
  - Log: findings count by severity, changes made, iteration number
```

### Stopping Conditions

**Stop when ANY of these is true:**
1. Iteration count reaches `--max N`
2. An iteration finds zero improvements at any severity level — outputs `<promise>PLAN_REFINED</promise>`

All findings (HIGH, MEDIUM, LOW) are applied every iteration. The skill keeps polishing until there is genuinely nothing left to improve for the given prompt.

### Tracking File

**Location:** `docs/plans/plan-refine-tracking.md`

Created on the first iteration. Logs:
- The original prompt
- The plan file path
- Each iteration's findings, changes made, and deferrals

**Format:**
```markdown
# Plan Refine Tracking

**Prompt:** "<user's prompt>"
**Plan File:** <path>

---

## Iteration Log

### Iteration 1 (YYYY-MM-DD)

**Findings:** X (Y HIGH, Z MEDIUM, W LOW)

#### Changes Applied

- [HIGH] Description of change
- [MEDIUM] Description of change
- [LOW] Description of change
```

### Completion Signal

```
<promise>PLAN_REFINED</promise>
```

Output only when an iteration genuinely finds zero improvements. This signal is compatible with the Ralph Loop protocol if the skill is ever wrapped in a loop skill in the future.

## What's NOT Included (vs Other Sweeps)

| Feature | Other Sweeps | plan-refine |
|---------|-------------|-------------|
| `/compact` | Yes (context fills across iterations) | No (iterations are lightweight) |
| Git branching | Yes (iteration branch per cycle) | No |
| Commits / PRs | Yes | No |
| CI polling / merge | Yes | No |
| Ralph Loop delegation | Yes (loop skills) | No (self-contained) |
| Parallel explorer agents | Yes (beta-audit) | No (plan files are small) |
| Manual todos file | Some (beta-audit, service-audit) | No |

## File Changes

| File | Action |
|------|--------|
| `commands/plan-refine.md` | Create — the skill definition |

## Open Questions

None — all resolved during brainstorming.
