---
description: "One beta-audit iteration: explore the app holistically for beta-readiness gaps, fix code issues, collect manual to-dos, validate, PR, CI, merge."
---

# Beta Audit — Full Cycle

You are performing one complete beta-audit iteration. This app is being prepared for beta testers. Explore it thoroughly as a holistic reviewer — look for anything that would embarrass you, confuse a user, break under real usage, or signal the app isn't ready. Report progress at each phase.

## Phase 1: Setup

1. Ensure you are on main with the latest code:
   ```bash
   git checkout main && git pull origin main
   ```

2. Read `docs/plans/beta-audit-tracking.md` to find the last iteration number. Your iteration is N+1. If no iterations exist yet, you are iteration 1. If the tracking file does not exist, create it:
   ```markdown
   # Beta Audit Tracking

   Holistic beta-readiness audit across feature completeness, error handling, UX polish, ops readiness, and performance.

   ---

   ## Iteration Log
   ```

3. Read `docs/plans/beta-manual-todos.md` to see any prior manual to-dos. If the file does not exist, create it:
   ```markdown
   # Beta Launch — Manual To-Dos

   Items that require human action outside the codebase (service provider settings, deployment config, external tools, etc.).

   ---
   ```

4. Create an iteration branch:
   ```bash
   git checkout -b beta-audit/iteration-<N>
   ```

5. Review prior iterations in the tracking file and manual to-dos. Focus effort on uncovered ground — don't re-discover issues already fixed or already listed as manual to-dos.

## Phase 2: Explore

Explore the codebase across five dimensions. Use explorer agents in parallel — one per dimension. Each agent should read relevant files exhaustively and report findings.

### Dimension 1: Feature Completeness

Explore all routes, pages, and user flows end-to-end. Look for:
- Incomplete features or flows that start but don't finish
- Placeholder or mock data that was never replaced with real data
- Dead-end UX paths (buttons that go nowhere, links to unbuilt pages)
- Missing CRUD operations (can create but not delete, can edit but not view)
- Non-functional UI elements (checkboxes that don't persist, toggles that don't toggle)
- Missing onboarding or first-time user experience
- Legal/compliance gaps (privacy policy, terms of service, GDPR data export/deletion, email unsubscribe)

### Dimension 2: Error Handling & Edge Cases

Trace the error paths through the application. Look for:
- Missing loading states (pages that flash blank before data loads)
- Missing empty states (lists with no items, dashboards with no data)
- Missing error boundaries or error pages (route segments without `error.tsx`)
- Unhandled promise rejections or missing try/catch blocks
- Form validation gaps (missing required fields, no length limits, no format validation)
- Network failure handling (what happens when the user goes offline, API times out)
- Auth edge cases (expired sessions, concurrent logins, partial signup state)
- Misleading error or status messages (e.g., "changes will sync" when app has no offline sync)

### Dimension 3: Polish & UX Quality

Review the user-facing experience for rough edges. Look for:
- Accessibility issues (missing alt text, missing aria labels, missing focus traps in modals, no skip-to-content link, no keyboard navigation, screen reader gaps)
- Inconsistent styling (mixed spacing, inconsistent colors, typography mismatches)
- Mobile responsiveness issues (layouts that break on small screens, touch targets too small)
- Dead features that should be removed (UI for features that aren't implemented or don't work)
- Confusing navigation or information architecture
- Missing transitions or abrupt UI state changes

### Dimension 4: Ops & Infra Readiness

Check operational readiness for production-like usage. Look for:
- Missing error monitoring (no Sentry, no error tracking, PII leaking into error reports)
- Missing or misconfigured logging
- Environment variable validation (app crashes if env var missing instead of failing gracefully)
- Email deliverability issues (missing unsubscribe headers, no bounce handling)
- Production safety guards (test mode events hitting production, debug endpoints exposed)
- Missing health check endpoints
- Rate limiting gaps on public endpoints
- CORS misconfiguration
- Missing security headers (CSP, X-Frame-Options, etc.)

### Dimension 5: Performance

Look for patterns that would cause sluggish UX under real usage. Look for:
- Redundant API or auth calls (same data fetched multiple times per page load)
- Sequential queries that could be parallelized (`Promise.all`)
- N+1 query patterns (fetching related data in a loop)
- Heavy components mounted during critical path that could be deferred
- Client-side data fetching that could be server-side
- Missing pagination on potentially large lists
- Unnecessary re-renders (missing memoization on expensive computations)
- Large bundle sizes from unnecessary client-side dependencies

### Classification

Each finding must be classified by:

**Severity:**
- **HIGH** — Would block or seriously degrade the beta experience (broken flow, crash, missing core feature)
- **MEDIUM** — Noticeable quality issue a beta tester would flag (poor UX, missing state, accessibility gap)
- **LOW** — Nice-to-have polish (minor styling, non-critical improvement)

**Type:**
- **CODE** — Can be fixed by changing code in this repository
- **MANUAL** — Requires human action outside the codebase (service provider config, DNS, external tool setup, deployment settings)

## Phase 3: Consolidate & Fix

1. Merge findings from all five explorer agents
2. Deduplicate — different agents may surface the same issue from different angles
3. Separate into two lists:
   - **Code fixes:** All HIGH and MEDIUM items tagged CODE — fix these now, cap at ~12 files per iteration. Prioritize HIGH first.
   - **Manual to-dos:** All items tagged MANUAL (any severity) — append these to `docs/plans/beta-manual-todos.md`
4. LOW items of either type are deferred — log them in the tracking file but do not fix this iteration
5. Adapt fixes to this project's conventions (check CLAUDE.md if it exists). Do not modify database schema or migrations unless absolutely necessary.

## Phase 4: Validate

Run the project's quality checks. Look for scripts in `package.json`, `Makefile`, or CI config:

```bash
npm run lint:fix 2>/dev/null || true
npm run typecheck 2>/dev/null || true
npm run test 2>/dev/null || true
```

If any check fails, fix the issue and re-run. Max 3 fix attempts per check. If still failing after 3 attempts, revert the problematic change and note it as deferred.

Check E2E tests for stale assertions if content or behavior was changed. Update them accordingly.

After validation is complete, clean up test artifacts and ensure no test processes are still running:

```bash
rm -rf coverage .nyc_output 2>/dev/null || true
pkill -f "vitest|jest" 2>/dev/null || true
```

## Phase 5: Update Tracking

Append a new entry to `docs/plans/beta-audit-tracking.md`:

```markdown
### Iteration N (YYYY-MM-DD)

**Findings:** X total (Y HIGH, Z MEDIUM, W LOW)
**Code fixes applied:** A
**Manual to-dos added:** B
**Deferred:** C

#### Fixed (Code)

- [x] Description (dimension: X, severity: HIGH/MEDIUM)

#### Manual To-Dos Added

- Description (dimension: X, severity: Y)

#### Deferred

- [ ] Description (dimension: X, severity: LOW, reason)
```

Append new manual to-dos to `docs/plans/beta-manual-todos.md`:

```markdown
### From Iteration N (YYYY-MM-DD)

- [ ] Description (dimension: ops, severity: HIGH)
- [ ] Description (dimension: feature, severity: MEDIUM)
```

Do not remove or modify existing entries in the manual to-dos file — the user checks these off as they complete them.

## Phase 6: Ship

**If code fixes were applied:**

1. Stage specific changed files (do NOT use `git add -A` or `git add .`):
   ```bash
   git add <list of specific files>
   ```
2. Commit:
   ```bash
   git commit -m "fix: beta audit iteration N — <brief summary of changes>"
   ```
3. Push:
   ```bash
   git push -u origin beta-audit/iteration-<N>
   ```
4. Create PR:
   ```bash
   gh pr create --title "Beta Audit: Iteration N" --body "Automated beta-readiness audit. See docs/plans/beta-audit-tracking.md for details."
   ```

**If NO HIGH or MEDIUM code findings were found:** skip to Phase 8.

## Phase 7: CI & Merge

1. Note the PR number from the create output.
2. Poll CI status every 45 seconds:
   ```bash
   gh pr checks <number>
   ```
3. Report the status of each check between polls.
4. When all checks complete:
   - **All pass** → merge and clean up:
     ```bash
     gh pr merge <number> --squash --delete-branch
     git checkout main && git pull origin main
     ```
   - **Any fail** → read logs, fix, push, re-poll (max 3 fix attempts):
     ```bash
     gh run view <run-id> --log-failed
     # fix the issue
     git add <specific files> && git commit -m "fix: address CI failure in beta audit iteration N"
     git push
     ```

## Phase 8: Signal

**If HIGH or MEDIUM code findings were found and fixed:** exit normally. If running in a Ralph Loop, the loop will re-invoke for the next iteration.

**If NO HIGH or MEDIUM code findings were found:** output exactly:

```
<promise>BETA_READY</promise>
```

Only output this promise if all five dimensions were genuinely explored and no actionable HIGH or MEDIUM code findings remain. Manual to-dos do not block the signal — the codebase is beta-ready even if operational tasks remain for the human.

If coverage was incomplete (e.g., an agent failed or a dimension was skipped), exit normally and let the next iteration continue.
