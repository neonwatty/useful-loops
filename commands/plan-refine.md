---
description: "One plan-refine iteration: apply a prompt-driven analysis to a plan document, identify improvements, and apply them."
argument-hint: "\"PROMPT\" PLAN_FILE"
---

# Plan Refine

You are performing one complete plan-refine iteration. Apply the user's analysis prompt to the plan document, identify improvements, and apply them. Report progress at each phase.

Parse the arguments: extract the quoted PROMPT string and the PLAN_FILE path. If the prompt is not quoted, treat everything before the last path-like argument as the prompt.

**Prompt:** `<PROMPT>`
**Plan file:** `<PLAN_FILE>`

Run Phases 1-5 once. If Phase 2 finds zero improvements, skip to Phase 5 (signal).

---

## Phase 1: Read

1. Read the plan file at `<PLAN_FILE>`. If the file does not exist, stop and tell the user.

2. Read `docs/plans/plan-refine-tracking.md` to find the last iteration number. Your iteration is N+1. If no iterations exist yet, you are iteration 1. If the tracking file does not exist, create it (run `mkdir -p docs/plans` first if the directory does not exist):
   ```markdown
   # Plan Refine Tracking

   **Prompt:** "<user's prompt>"
   **Plan File:** <path>

   ---

   ## Iteration Log
   ```

3. If this is iteration 2 or later, review the prior iteration entries in the tracking file. Understand what was already changed so you do not re-tread the same ground or revert prior improvements.

## Phase 2: Analyze

Apply the user's prompt to the current plan content. Read the plan carefully and identify specific, actionable improvements.

For each improvement found, classify its severity:
- **HIGH** — Structural issue, missing critical section, incorrect or misleading information, logical gap
- **MEDIUM** — Unclear wording, weak justification, missing detail, inconsistent formatting
- **LOW** — Minor phrasing, typos, stylistic polish, redundant wording

If zero improvements are found at any severity level, skip to Phase 5 (signal).

If improvements were found, proceed to Phase 3.

## Phase 3: Edit

Apply ALL findings (HIGH, MEDIUM, and LOW) directly to the plan file in-place. Edit the file at `<PLAN_FILE>` — do not create a copy or a new file.

Prioritize HIGH findings first, then MEDIUM, then LOW. Each edit should be surgical: change only what the finding calls for without disrupting surrounding content.

After all edits are applied, re-read the plan file to verify the changes look correct and the document is coherent.

## Phase 4: Track

Append an iteration entry to `docs/plans/plan-refine-tracking.md`:

```markdown
### Iteration N (YYYY-MM-DD)

**Findings:** X (Y HIGH, Z MEDIUM, W LOW)

#### Changes Applied

- [HIGH] Description of change
- [MEDIUM] Description of change
- [LOW] Description of change
```

## Phase 5: Signal

**If improvements were found and applied:** exit normally. If running in a Ralph Loop, the loop will re-invoke for the next iteration.

**If NO improvements were found:** output exactly:

```
<promise>PLAN_REFINED</promise>
```

Only output this promise if you genuinely analyzed the full plan against the prompt and found nothing actionable.
