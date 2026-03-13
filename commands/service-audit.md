---
name: service-audit
description: "This command should be used when the user asks to 'run a service audit', 'check my services', 'audit Vercel/Supabase/PostHog/Sentry/GitHub', or 'check service health'. Runs one iteration: checks Vercel, Supabase, PostHog, Sentry, and GitHub for issues, fixes code problems, browser-assists manual fixes, validates, PRs, runs CI, and merges."
---

# Service Audit — Full Cycle

You are performing one complete service audit iteration. Check the health of all detected services (Vercel, Supabase, PostHog, Sentry, GitHub) by inspecting the codebase, using CLIs/APIs, and checking browser dashboards. Fix code issues, walk the user through browser-assisted fixes, and collect manual to-dos. Report progress at each phase.

## Phase 1: Setup

1. Ensure you are on main with the latest code:
   ```bash
   git checkout main && git pull origin main
   ```

2. Read `docs/plans/service-audit-tracking.md` to find the last iteration number. Your iteration is N+1. If no iterations exist yet, you are iteration 1. If the tracking file does not exist, create it:
   ```markdown
   # Service Audit Tracking

   Automated service health audit across Vercel, Supabase, PostHog, Sentry, and GitHub.

   ---

   ## Iteration Log
   ```

3. Read `docs/plans/service-audit-manual-todos.md` to see any prior manual to-dos. If the file does not exist, create it:
   ```markdown
   # Service Audit — Manual To-Dos

   Items that require human action in service dashboards, external tools, or account settings.

   ---
   ```

4. Create an iteration branch:
   ```bash
   git checkout -b service-audit/iteration-<N>
   ```

5. **Detect which services this project uses.** Scan:
   - `package.json` for `@vercel/*`, `@supabase/supabase-js`, `posthog-js`, `posthog-node`, `@sentry/*`
   - `.env*` files for `NEXT_PUBLIC_SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `SENTRY_DSN`, `NEXT_PUBLIC_POSTHOG_KEY`, `VERCEL_*`
   - Config files: `vercel.json`, `sentry.client.config.*`, `sentry.server.config.*`, `posthog.*`
   - `.github/workflows/` directory for GitHub Actions

   Build a service manifest listing which services are detected. Only audit detected services. GitHub is always included if a `.git` directory exists.

6. Review prior iterations in the tracking file and manual to-dos. Focus effort on uncovered ground — don't re-discover issues already fixed or already listed as manual to-dos.

## Phase 2: Sweep Services

Work through each detected service sequentially. For each service, use the appropriate method (codebase inspection, CLI/API, or browser dashboard) to check for issues. When browser access is needed: navigate to the dashboard, and if a login wall appears, pause and ask the user to authenticate before continuing.

For each detected service, use the detailed check tables in `references/service-checks.md` (Vercel V1-V6, Supabase S1-S7, PostHog P1-P5, Sentry E1-E6, GitHub G1-G6). Use the appropriate method for each check (codebase inspection, CLI/API, or browser dashboard).

### Classification

Each finding must be classified by:

**Severity:**
- **CRITICAL** — Service is broken, security vulnerability, or data at risk (failed deploys, missing RLS, unresolved errors)
- **HIGH** — Significant issue that degrades reliability or developer experience (missing source maps, env var drift, dependabot alerts)
- **MEDIUM** — Quality issue worth addressing (outdated SDK, missing indexes, stale feature flags)
- **LOW** — Hygiene or nice-to-have (stale branches, noisy events, minor config improvement)

**Type:**
- **CODE** — Can be fixed by changing code in this repository
- **BROWSER** — Can be fixed interactively via the service's web dashboard with user assistance
- **MANUAL** — Requires human action that cannot be automated (account upgrades, contacting support, credential rotation)

## Phase 3: Consolidate & Fix

1. List ALL findings across all swept services
2. Deduplicate — the same root cause may surface across multiple services (e.g., missing env var affects both Vercel and Supabase)
3. Separate into three lists:

   **Code fixes:** All CRITICAL, HIGH, and MEDIUM items tagged CODE — fix these now, cap at ~12 files per iteration. Prioritize CRITICAL first, then HIGH.
   - SDK version bumps in `package.json`
   - Config file corrections (`vercel.json`, Sentry config, etc.)
   - Migration files for missing indexes or RLS policies
   - GitHub Actions workflow updates for deprecated versions
   - Code-level fixes for missing environment tags, inconsistent event tracking, etc.

   **Browser-assisted fixes:** All items tagged BROWSER — walk the user through these interactively:
   - Navigate to the relevant service dashboard
   - If a login wall appears, pause and ask the user to authenticate
   - Describe the fix needed and confirm with the user before taking any action
   - Take action (click, fill, submit) only after explicit user confirmation
   - Screenshot before and after for the tracking report

   **Manual to-dos:** All items tagged MANUAL (any severity) — append to `docs/plans/service-audit-manual-todos.md`

4. LOW items of any type are deferred — log them in the tracking file but do not fix this iteration
5. **Never weaken existing security to fix something else**
6. Adapt fixes to this project's conventions (check CLAUDE.md if it exists). Do not modify database schema or migrations unless absolutely necessary for security (e.g., missing RLS).

## Phase 4: Validate

Follow the **Validate** phase in `references/common-lifecycle.md`. Additional steps for this skill:

- If Supabase migrations were added: `supabase db diff 2>/dev/null || true`
- If GitHub Actions workflows were modified: `npx yaml-lint .github/workflows/*.yml 2>/dev/null || true`

## Phase 5: Update Tracking

Append a new entry to `docs/plans/service-audit-tracking.md`:

```markdown
### Iteration N (YYYY-MM-DD)

**Services Checked:** [list of detected services]
**Findings:** X total (A CRITICAL, B HIGH, C MEDIUM, D LOW)
**Code fixes applied:** E
**Browser-assisted fixes:** F
**Manual to-dos added:** G
**Deferred:** H

#### Fixed (Code)

- [x] [Service] Description (severity: CRITICAL/HIGH/MEDIUM)

#### Fixed (Browser-Assisted)

- [x] [Service] Description (severity: CRITICAL/HIGH/MEDIUM)

#### Manual To-Dos Added

- [Service] Description (severity: X)

#### Deferred

- [ ] [Service] Description (severity: LOW, reason)
```

Append new manual to-dos to `docs/plans/service-audit-manual-todos.md`:

```markdown
### From Iteration N (YYYY-MM-DD)

- [ ] [Service] Description (severity: X)
```

Do not remove or modify existing entries in the manual to-dos file — the user checks these off as they complete them.

## Phase 6: Ship

**If code fixes were applied:** follow the **Ship** phase in `references/common-lifecycle.md` with:
- **Branch:** `service-audit/iteration-<N>`
- **Commit:** `fix: service audit iteration N — <brief summary of changes>`
- **PR title:** `Service Audit: Iteration N`
- **PR body:** `Automated service health audit. See docs/plans/service-audit-tracking.md for details.`

**If NO CRITICAL or HIGH code findings were found:** skip to Phase 8.

## Phase 7: CI & Merge

Follow the **CI & Merge** phase in `references/common-lifecycle.md`.

## Phase 8: Signal

Completion requires BOTH conditions:
1. All detected services were swept
2. No CRITICAL or HIGH code findings remain unfixed

**If both conditions met**, output exactly:

```
<promise>SERVICES_HEALTHY</promise>
```

**If either condition is NOT met**, exit normally. If running in a Ralph Loop, the loop will re-invoke for the next iteration.

Only output this promise if all detected services were genuinely checked and no actionable CRITICAL or HIGH code findings remain. BROWSER-assisted fixes that were completed count as resolved. MANUAL to-dos do not block the signal — the codebase is healthy even if operational tasks remain for the human.

If coverage was incomplete (e.g., a service dashboard was unreachable or the user declined to authenticate), exit normally and let the next iteration continue.
