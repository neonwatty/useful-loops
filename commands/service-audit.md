---
description: "One service audit iteration: check Vercel, Supabase, PostHog, Sentry, and GitHub for issues, fix code problems, browser-assist manual fixes, validate, PR, CI, merge."
---

# Service Audit — Full Cycle

You are performing one complete service audit iteration. Check the health of all detected services (Vercel, Supabase, PostHog, Sentry, GitHub) by inspecting the codebase, using CLIs/APIs, and checking browser dashboards. Fix code issues, walk the user through browser-assisted fixes, and collect manual to-dos. Report progress at each phase.

## Phase 1: Setup

1. Compact context to free up space for this iteration. This is especially important when running in a Ralph Loop where prior iterations may have filled the context window:
   ```
   /compact
   ```

2. Ensure you are on main with the latest code:
   ```bash
   git checkout main && git pull origin main
   ```

3. Read `docs/plans/service-audit-tracking.md` to find the last iteration number. Your iteration is N+1. If no iterations exist yet, you are iteration 1. If the tracking file does not exist, create it:
   ```markdown
   # Service Audit Tracking

   Automated service health audit across Vercel, Supabase, PostHog, Sentry, and GitHub.

   ---

   ## Iteration Log
   ```

4. Read `docs/plans/service-audit-manual-todos.md` to see any prior manual to-dos. If the file does not exist, create it:
   ```markdown
   # Service Audit — Manual To-Dos

   Items that require human action in service dashboards, external tools, or account settings.

   ---
   ```

5. Create an iteration branch:
   ```bash
   git checkout -b service-audit/iteration-<N>
   ```

6. **Detect which services this project uses.** Scan:
   - `package.json` for `@vercel/*`, `@supabase/supabase-js`, `posthog-js`, `posthog-node`, `@sentry/*`
   - `.env*` files for `NEXT_PUBLIC_SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `SENTRY_DSN`, `NEXT_PUBLIC_POSTHOG_KEY`, `VERCEL_*`
   - Config files: `vercel.json`, `sentry.client.config.*`, `sentry.server.config.*`, `posthog.*`
   - `.github/workflows/` directory for GitHub Actions

   Build a service manifest listing which services are detected. Only audit detected services. GitHub is always included if a `.git` directory exists.

7. Review prior iterations in the tracking file and manual to-dos. Focus effort on uncovered ground — don't re-discover issues already fixed or already listed as manual to-dos.

## Phase 2: Sweep Services

Work through each detected service sequentially. For each service, use the appropriate method (codebase inspection, CLI/API, or browser dashboard) to check for issues. When browser access is needed: navigate to the dashboard, and if a login wall appears, pause and ask the user to authenticate before continuing.

### Service 1: Vercel

Check the following if Vercel is detected:

| # | Check | Method | Severity |
|---|-------|--------|----------|
| V1 | Recent deployment failures | `vercel ls` CLI or browser: Vercel dashboard > Deployments | CRITICAL |
| V2 | Build warnings in latest deploy | `vercel inspect <url>` CLI or browser: deployment build logs | MEDIUM |
| V3 | Missing or stale env vars (prod vs preview drift) | `vercel env ls` for each environment + compare to `.env.example` or `.env.local` | HIGH |
| V4 | Framework config issues | Inspect `vercel.json`, `next.config.*` for deprecated or misconfigured options | MEDIUM |
| V5 | Function duration/size approaching limits | Browser: Vercel dashboard > project > Functions tab | MEDIUM |
| V6 | Domain/SSL issues | `vercel domains ls` or browser: Vercel dashboard > project > Domains | HIGH |

### Service 2: Supabase

Check the following if Supabase is detected:

| # | Check | Method | Severity |
|---|-------|--------|----------|
| S1 | Tables without RLS enabled | Codebase: scan migration files for `alter table ... enable row level security`; or `supabase db dump` | CRITICAL |
| S2 | Permissive RLS policies (using `true` for all) | Codebase: scan migration files for policy definitions with `using (true)` or `with check (true)` | HIGH |
| S3 | Missing indexes on foreign keys | Codebase: scan migrations for foreign key columns without corresponding `create index` | MEDIUM |
| S4 | Auth config issues | `supabase` CLI or browser: Supabase dashboard > Authentication > Settings | MEDIUM |
| S5 | Storage bucket permissions | Browser: Supabase dashboard > Storage > Policies | MEDIUM |
| S6 | Connection pool / DB size approaching limits | Browser: Supabase dashboard > Reports > Database | LOW |
| S7 | Migration drift (local vs remote) | `supabase db diff` if CLI is configured | HIGH |

### Service 3: PostHog

Check the following if PostHog is detected:

| # | Check | Method | Severity |
|---|-------|--------|----------|
| P1 | Events tracked but unnamed/undocumented | Codebase: grep for `posthog.capture` and `posthog?.capture` calls, check for consistent naming convention | MEDIUM |
| P2 | High-volume noisy events | Browser: PostHog dashboard > Events > sort by volume | LOW |
| P3 | Stale feature flags still referenced in code | Codebase: grep for `posthog.isFeatureEnabled`, `posthog.getFeatureFlag`, `useFeatureFlagEnabled`; cross-ref with browser: PostHog > Feature Flags for active flags | MEDIUM |
| P4 | Feature flags with no rollout plan | Browser: PostHog > Feature Flags > check for flags at 0% or 100% for extended periods | LOW |
| P5 | Missing properties on tracked events | Codebase: check for inconsistent property schemas across `capture` calls for the same event name | MEDIUM |

### Service 4: Sentry

Check the following if Sentry is detected:

| # | Check | Method | Severity |
|---|-------|--------|----------|
| E1 | Unresolved errors (new or regression) | Sentry API: `curl -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" https://sentry.io/api/0/projects/{org}/{proj}/issues/?query=is:unresolved` or browser: Sentry > Issues | CRITICAL |
| E2 | High-frequency repeating errors | Sentry API or browser: Sentry > Issues sorted by frequency | HIGH |
| E3 | Outdated SDK version | Codebase: compare `@sentry/*` version in `package.json` against latest on npm | MEDIUM |
| E4 | Missing source maps config | Codebase: check `sentry.client.config.*`, `sentry.server.config.*`, `next.config.*` for source map upload configuration | HIGH |
| E5 | Missing environment tags | Codebase: check Sentry init calls for `environment` option | MEDIUM |
| E6 | Web vitals regressions (LCP/FID/CLS) | Browser: Sentry > Performance > Web Vitals | MEDIUM |

### Service 5: GitHub

GitHub is always checked if a `.git` directory exists:

| # | Check | Method | Severity |
|---|-------|--------|----------|
| G1 | Failing CI workflows | `gh run list --status failure --limit 5` | CRITICAL |
| G2 | Deprecated action versions | Codebase: scan `.github/workflows/*.yml` for action versions; check for outdated major versions | MEDIUM |
| G3 | Dependabot security alerts | `gh api /repos/{owner}/{repo}/dependabot/alerts --jq '[.[] \| select(.state=="open")]'` | HIGH |
| G4 | Stale branches (>30 days, already merged) | `gh api /repos/{owner}/{repo}/branches --paginate --jq '.[] \| select(.name != "main")'` + check age | LOW |
| G5 | Open PRs without review >7 days | `gh pr list --state open --json number,createdAt,reviewDecision` | MEDIUM |
| G6 | Missing branch protection on main | `gh api /repos/{owner}/{repo}/branches/main/protection` (404 = unprotected) | HIGH |

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

Run the project's quality checks. Look for scripts in `package.json`, `Makefile`, or CI config:

```bash
npm run lint:fix 2>/dev/null || true
npm run typecheck 2>/dev/null || true
npm run test 2>/dev/null || true
```

If Supabase migrations were added, verify with:
```bash
supabase db diff 2>/dev/null || true
```

If GitHub Actions workflows were modified, validate YAML syntax:
```bash
npx yaml-lint .github/workflows/*.yml 2>/dev/null || true
```

If any check fails, fix the issue and re-run. Max 3 fix attempts per check. If still failing after 3 attempts, revert the problematic change and note it as deferred.

Check E2E tests for stale assertions if behavior was changed. Update them accordingly.

After validation is complete, clean up test artifacts and ensure no test processes are still running:

```bash
rm -rf coverage .nyc_output 2>/dev/null || true
pkill -f "vitest|jest" 2>/dev/null || true
```

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

**If code fixes were applied:**

1. Stage specific changed files (do NOT use `git add -A` or `git add .`):
   ```bash
   git add <list of specific files>
   ```
2. Commit:
   ```bash
   git commit -m "fix: service audit iteration N — <brief summary of changes>"
   ```
3. Push:
   ```bash
   git push -u origin service-audit/iteration-<N>
   ```
4. Create PR:
   ```bash
   gh pr create --title "Service Audit: Iteration N" --body "Automated service health audit. See docs/plans/service-audit-tracking.md for details."
   ```

**If NO CRITICAL or HIGH code findings were found:** skip to Phase 8.

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
     git add <specific files> && git commit -m "fix: address CI failure in service audit iteration N"
     git push
     ```

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
