# Plan Refine Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a self-contained iterative skill that improves a plan document in-place according to a user-provided prompt.

**Architecture:** Single skill file (`commands/plan-refine.md`) that handles its own iteration loop internally. No Ralph Loop dependency, no git/PR/CI workflow. 4-phase iterations: Read → Analyze → Edit → Track.

**Tech Stack:** Claude Code skill (markdown with YAML frontmatter)

**Design doc:** `docs/plans/2026-03-06-plan-refine-design.md`

---

### Task 1: Create the plan-refine skill file

**Files:**
- Create: `commands/plan-refine.md`
- Reference: `commands/beta-audit.md` (for frontmatter format and tone conventions)
- Reference: `docs/plans/2026-03-06-plan-refine-design.md` (for design spec)

**Step 1: Write the skill file**

Create `commands/plan-refine.md` with:

1. **YAML frontmatter** — `description` and `argument-hint` fields matching the repo's convention
2. **Intro paragraph** — set the role/context (like other skills' opening lines)
3. **Argument parsing section** — extract PROMPT, PLAN_FILE, and optional --max N (default 5)
4. **Iteration loop** — instructions to repeat Phases 1-4 up to N times
5. **Phase 1: Read** — read plan file + tracking file (create tracking file if iteration 1), review prior iterations
6. **Phase 2: Analyze** — apply prompt to plan content, identify improvements, classify HIGH/MEDIUM/LOW
7. **Phase 3: Edit** — apply all findings to plan file in-place
8. **Phase 4: Track** — append iteration entry to `docs/plans/plan-refine-tracking.md`
9. **Stopping condition** — if zero findings at any severity, output `<promise>PLAN_REFINED</promise>` and stop
10. **Max iterations reached** — exit normally after N iterations if not already stopped

Key conventions to follow from existing skills:
- Tracking file template uses same markdown structure (header → iteration log → per-iteration entries)
- Severity classification matches existing pattern (HIGH/MEDIUM/LOW)
- Completion promise format: `<promise>PLAN_REFINED</promise>`
- No `/compact`, no git branching, no PR/CI/merge phases

**Step 2: Review the file**

Read the created file back and verify:
- Frontmatter is valid YAML
- All 4 phases are present with clear instructions
- Stopping condition is explicit
- Tracking file template is included
- Argument parsing covers PROMPT, PLAN_FILE, --max N

**Step 3: Commit**

```bash
git add commands/plan-refine.md
git commit -m "feat: add plan-refine skill for iterative plan improvement"
```

---

### Task 2: Update README

**Files:**
- Modify: `README.md`

**Step 1: Read the current README**

Read `README.md` to find where skills are listed and how they're documented.

**Step 2: Add plan-refine entry**

Add an entry for `plan-refine` in the skills list, following the existing format. Include:
- Skill name and description
- Example invocation
- Note that it's self-contained (no Ralph Loop dependency)

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add plan-refine to README"
```

---

### Task 3: Push and open PR

**Step 1: Push the branch**

```bash
git push -u origin feat/plan-refine
```

**Step 2: Create PR**

```bash
gh pr create --title "feat: add plan-refine skill for iterative plan improvement" --body "..."
```

Include in the PR body:
- Summary of what plan-refine does
- How it differs from other sweeps (no git/PR/CI, self-contained loop)
- Example invocations
- Link to design doc
