# Doc Refine — Design Document

**Date:** 2026-03-06
**Status:** Approved

## Overview

A self-contained, iterative skill that improves a document in-place according to a user-provided prompt. Sibling to `plan-refine` but with document-oriented severity definitions and editing guidance. Does not touch code, create branches, open PRs, or run CI.

## Invocation

```
/useful-loops:doc-refine "<PROMPT>" <DOC_FILE> [--max N]
```

**Arguments:**
- `PROMPT` (required, quoted string) — instruction for how to analyze/improve the document (e.g., "improve clarity for a developer audience")
- `DOC_FILE` (required) — path to the document file to iterate on
- `--max N` (optional, default: 5) — maximum number of iterations

**Examples:**
```
/useful-loops:doc-refine "improve readability for non-technical audience" docs/user-guide.md
/useful-loops:doc-refine "tighten the prose and remove redundancy" README.md --max 3
/useful-loops:doc-refine "ensure consistent tone and fix unclear sections" docs/api-reference.md --max 8
```

## Architecture

Identical to `plan-refine`: single self-contained skill, no Ralph Loop dependency, 4-phase iterations, in-place editing, `/clear` between iterations.

### Key Difference: Document-Oriented Analysis

**Severity definitions (vs plan-refine):**
- **HIGH** — Confusing or misleading content, missing critical information, wrong audience level, structural issues that impede comprehension
- **MEDIUM** — Unclear wording, inconsistent tone, weak transitions, missing context, formatting issues
- **LOW** — Minor phrasing, redundancy, stylistic polish, typos

**Editing guidance:**
- Preserve the author's voice — edits should improve readability without changing the document's intent or personality
- Surgical edits only — change what the finding calls for without disrupting surrounding content

### Per-Iteration Flow (4 Phases)

1. **Phase 1: Read** — `/clear`, read document + tracking file, create tracking file on iteration 1, review prior iterations
2. **Phase 2: Analyze** — apply prompt to document, identify improvements, classify HIGH/MEDIUM/LOW
3. **Phase 3: Edit** — apply ALL findings to document in-place
4. **Phase 4: Track** — append iteration entry to `docs/plans/doc-refine-tracking.md`

### Stopping Conditions

**Stop when ANY of these is true:**
1. Iteration count reaches `--max N`
2. Zero improvements at any severity level — outputs `<promise>DOC_REFINED</promise>`

### Tracking File

**Location:** `docs/plans/doc-refine-tracking.md`

**Format:** Same as plan-refine — header with prompt/file path, then per-iteration entries with findings count and changes applied.

## File Changes

| File | Action |
|------|--------|
| `commands/doc-refine.md` | Create — the skill definition |
