---
name: funnel-audit
description: "This command should be used when the user asks to 'run a funnel audit', 'audit marketing pages', 'check top-of-funnel', or 'improve marketing conversion'. Runs one interactive iteration: collaboratively audits one top-of-funnel marketing category with the user, discusses findings, agrees on fixes, validates, PRs, runs CI, and merges."
---

# Funnel Audit — Full Cycle (Interactive)

You are performing one complete funnel-audit iteration **collaboratively with the user**. Marketing and conversion decisions are subjective — copy, placement, feature choices, and tone all depend on the product's brand and strategy. Unlike security or test-coverage sweeps, you must **not** auto-pilot through this. Every substantive decision requires user input.

**Core principle: Propose, don't prescribe.** Present your analysis, suggest changes, and let the user decide what to implement.

## Phase 1: Setup

1. Ensure you are on main with the latest code:
   ```bash
   git checkout main && git pull origin main
   ```

2. Read `docs/plans/funnel-audit-tracking.md` to find the last iteration number. Your iteration is N+1. If no iterations exist yet, you are iteration 1. If the tracking file does not exist, create it:
   ```markdown
   # Funnel Audit Tracking

   Top-of-funnel marketing audit. 7 categories to cover.

   ## Categories

   | # | Category | Status |
   |---|----------|--------|
   | 1 | CTAs & Conversion Points | Not Started |
   | 2 | Referral & Viral Mechanics | Not Started |
   | 3 | Email Capture & Lead Nurture | Not Started |
   | 4 | Onboarding & Activation | Not Started |
   | 5 | SEO & Content Discoverability | Not Started |
   | 6 | Demo-to-Signup Funnel | Not Started |
   | 7 | Shareable & Exportable Content | Not Started |

   ---

   ## Iteration Log
   ```

3. **Ask the user which category to focus on.** Present the tracking status (which categories are done, partial, or not started) and use `AskUserQuestion` to let them choose. Suggest the next unaudited category in order, but let the user override:

   ```
   AskUserQuestion:
     question: "Which marketing category should we audit this iteration?"
     header: "Category"
     options:
       - label: "<suggested next category> (Recommended)"
         description: "Next unaudited category in sequence"
       - label: "<other unaudited category>"
         description: "<status>"
       - label: "<another unaudited category>"
         description: "<status>"
       - label: "Re-audit a completed category"
         description: "Revisit a previously audited category for remaining issues"
   ```

   Populate the options dynamically based on tracking file status. Always recommend the next unaudited category but respect the user's choice.

4. Create an iteration branch:
   ```bash
   git checkout -b funnel-audit/iteration-<N>
   ```

## Phase 2: Analyze

Focus on **one category** per iteration. Read every relevant file — pages, components, layouts, configs, styles, utilities. Do not sample; be exhaustive.

### Category Checklists

Use the detailed category checklist table and analysis method in `references/funnel-categories.md`. The reference includes all 7 categories with their specific items to check and the severity classification guide.

### Checkpoint: Present Findings to User

After completing the analysis, **stop and present all findings to the user before proceeding to fixes.** Format findings as a clear table:

```
| # | Finding | Severity | File(s) | Proposed Action |
|---|---------|----------|---------|-----------------|
| 1 | No CTA on /pricing page | HIGH | src/app/pricing/page.tsx | Add signup CTA below pricing table |
| 2 | Generic "Submit" button text | MEDIUM | src/components/ContactForm.tsx | Change to "Get Started Free" |
```

Then use `AskUserQuestion` to get user direction:

```
AskUserQuestion:
  question: "I found N findings for <category>. Which should we address this iteration?"
  header: "Findings"
  options:
    - label: "Fix all HIGH and MEDIUM (Recommended)"
      description: "Address X findings, defer Y LOW items"
    - label: "Fix HIGH only"
      description: "Address X critical findings, defer the rest"
    - label: "Let me review the list first"
      description: "I want to discuss specific findings before deciding"
    - label: "Skip this category"
      description: "No changes needed — mark as reviewed"
```

If the user chooses "Let me review the list first," engage in a discussion about each finding. The user may:
- **Reject a finding** — they disagree it's an issue (remove it from the list)
- **Reclassify severity** — they think a HIGH is actually LOW, or vice versa
- **Modify the proposed action** — they want a different fix than what you suggested
- **Add findings you missed** — they noticed something the checklist didn't cover

Update the findings list based on user feedback before proceeding to Phase 3.

## Phase 3: Fix

Before implementing, **present proposed changes to the user for approval**, especially for:

- **Copy and messaging** — CTA text, button labels, headlines, descriptions, error messages, empty states. The user knows their brand voice. Always propose specific text and ask:

  ```
  AskUserQuestion:
    question: "Here's the proposed copy for the new CTA. Does this match your brand voice?"
    header: "CTA copy"
    options:
      - label: "Looks good, use it"
        description: "Proceed with the proposed copy"
      - label: "I'll provide alternative copy"
        description: "Let me write the text myself"
      - label: "Adjust the tone"
        description: "Keep the structure but change the tone (more casual, more urgent, etc.)"
  ```

- **New feature decisions** — Adding a referral system, email capture modal, share buttons, or other net-new functionality. These are product decisions, not just code fixes:

  ```
  AskUserQuestion:
    question: "The audit suggests adding <feature>. Should we implement it?"
    header: "New feature"
    options:
      - label: "Yes, implement it"
        description: "Add this feature in this iteration"
      - label: "Defer to a future iteration"
        description: "Good idea but not right now"
      - label: "Not needed for this app"
        description: "Skip — doesn't fit our product strategy"
  ```

- **Layout and placement changes** — Where to position CTAs, how to restructure a page flow, which components to add/move

After getting user approval on the approach, implement the agreed-upon fixes:

1. Fix only the findings the user approved
2. Use the copy the user approved (or provided)
3. Match the target app's existing code conventions — use its component library, CSS approach, routing patterns, and state management
4. **Never remove existing marketing/conversion features** — only add or improve
5. Cap at ~12 files per iteration; defer the rest
6. For new features: implement if straightforward (< 100 lines per feature) and user-approved, defer if complex

## Phase 4: Validate

Follow the **Validate** phase in `references/common-lifecycle.md`. Marketing changes are particularly likely to break snapshot tests or content-dependent assertions — update them accordingly.

## Phase 5: Update Tracking

Append a new entry to `docs/plans/funnel-audit-tracking.md`:

```markdown
### Iteration N (YYYY-MM-DD)

**Category:** <category name>
**Findings:** X total (Y HIGH, Z MEDIUM, W LOW)
**Fixed:** A
**Deferred:** B
**User-rejected:** C (findings the user decided were not applicable)

#### Fixed

- [x] [HIGH] Description of fix
- [x] [MEDIUM] Description of fix

#### Deferred

- [ ] [LOW] Description (reason for deferral)

#### User-Rejected

- [-] [MEDIUM] Description (user's reason for rejection)

#### Categories Remaining

- [list of unaudited categories or categories with remaining HIGH/MEDIUM findings]
```

Update the category's status in the Categories table at the top of the tracking file:
- **Completed** — all checklist items reviewed, no outstanding HIGH or MEDIUM findings (user-rejected items count as resolved)
- **Partial (N HIGH/MEDIUM remaining)** — some findings were deferred or unfixed

## Phase 6: Ship

**If issues were found and fixed:**

Before shipping, ask the user for confirmation:

```
AskUserQuestion:
  question: "Ready to create a PR with these changes?"
  header: "Ship"
  options:
    - label: "Yes, create PR (Recommended)"
      description: "Stage, commit, push, and open a pull request"
    - label: "Let me review the diff first"
      description: "Show me the full diff before committing"
    - label: "Not yet"
      description: "I want to make more adjustments first"
```

If "Let me review the diff first," run `git diff` and present it. Wait for user confirmation before proceeding.

Once approved, follow the **Ship** phase in `references/common-lifecycle.md` with:
- **Branch:** `funnel-audit/iteration-<N>`
- **Commit:** `fix: funnel-audit: <category> improvements from iteration N`
- **PR title:** `Funnel Audit: Iteration N — <category>`
- **PR body:** `Top-of-funnel marketing audit. See docs/plans/funnel-audit-tracking.md for details.`

**If NO issues found AND all 7 categories completed:** skip to Phase 8.

## Phase 7: CI & Merge

Follow the **CI & Merge** phase in `references/common-lifecycle.md`, but **ask the user before merging** (funnel audits are interactive):

```
AskUserQuestion:
  question: "CI is green. Merge this PR?"
  header: "Merge"
  options:
    - label: "Yes, squash and merge (Recommended)"
      description: "Merge the PR and clean up the branch"
    - label: "Leave it open"
      description: "I want to review the PR on GitHub first"
```

Only merge after user approval.

## Phase 8: Signal

Completion requires BOTH conditions:
1. All 7 marketing categories have been reviewed (check tracking file — user-rejected categories count as reviewed)
2. No HIGH or MEDIUM findings remain unfixed across any category (user-rejected findings count as resolved)

**If both conditions met**, tell the user the funnel audit is complete and output exactly:

```
<promise>FUNNEL_OPTIMIZED</promise>
```

**If either condition is NOT met**, summarize what remains and ask the user if they'd like to continue with another iteration now or stop for today.

Only output this promise if you genuinely reviewed all categories with the user and verified no actionable findings remain.
