---
description: "One funnel-audit iteration: audit one top-of-funnel marketing category against best-practice checklist, fix issues, validate, PR, CI, merge."
---

# Funnel Audit — Full Cycle

You are performing one complete funnel-audit iteration. Systematically audit and improve top-of-funnel marketing across a SaaS web app — CTAs, referral mechanics, email capture, onboarding, SEO, demo-to-signup funnel, and shareable content. Report progress at each phase.

## Phase 1: Setup

1. Compact context to free up space for this iteration. This is especially important when running in a Ralph Loop where prior iterations may have filled the context window:
   ```
   /compact
   ```

2. Ensure you are on main with the latest code:
   ```bash
   git checkout main && git pull origin main
   ```

3. Read `docs/plans/funnel-audit-tracking.md` to find the last iteration number. Your iteration is N+1. If no iterations exist yet, you are iteration 1. If the tracking file does not exist, create it:
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

4. Create an iteration branch:
   ```bash
   git checkout -b funnel-audit/iteration-<N>
   ```

5. Review which categories were already audited in prior iterations. Pick the next unaudited category from the list below (in order). If all 7 have been visited, pick the first category that still has remaining HIGH or MEDIUM findings.

## Phase 2: Analyze

Focus on **one category** per iteration. Read every relevant file — pages, components, layouts, configs, styles, utilities. Do not sample; be exhaustive.

### Category List

| # | Category | What to check |
|---|----------|---------------|
| 1 | **CTAs & Conversion Points** | Every public page has at least one clear CTA leading to signup/demo. Primary CTAs use action-oriented copy (not generic "Submit" or "Click here"). CTA buttons have strong visual contrast and are above the fold. Multiple CTA placements per long page (hero, mid-page, bottom). CTAs use consistent language matching the value prop. Mobile CTAs are full-width or thumb-reachable. No dead-end pages (every page has a next step). |
| 2 | **Referral & Viral Mechanics** | Share functionality exists for core outputs (charts, plans, results). Shared content includes branding/attribution back to the app. Invite flow exists (email, link, or code-based). Referral incentives are communicated (even if just "share with a friend"). Social sharing buttons/links on key outputs. Shareable URLs are clean and include OG metadata. |
| 3 | **Email Capture & Lead Nurture** | Email capture exists on landing page. Email capture triggers at engagement milestones (not just page load). Capture forms have clear value proposition (not just "subscribe"). Exit-intent or scroll-depth triggers exist. Captured emails are sent to a real service (not just logged). No duplicate capture modals in a single session. Dismissed captures respect cooldown periods. |
| 4 | **Onboarding & Activation** | First-run experience guides users to core value action. Progress indicators show how far through onboarding. Skip option available (not forced). Onboarding references the user's actual data when possible. Celebration/success moment at completion of first key action. Empty states have clear "get started" messaging. Time-to-first-value is minimized (no unnecessary setup steps). |
| 5 | **SEO & Content Discoverability** | All public pages have unique, descriptive title and meta description. Structured data (JSON-LD) on key pages. Canonical URLs set correctly. Internal linking between related pages. Image alt text on all meaningful images. sitemap.xml exists and is current. robots.txt allows appropriate crawling. OG/Twitter card metadata on shareable pages. |
| 6 | **Demo-to-Signup Funnel** | Demo is accessible without signup (reduces friction). Demo showcases core value prop clearly. Strategic feature gating nudges signup at high-engagement moments. Signup prompt appears after user has experienced value (not before). Demo-to-signup transition preserves user's work/progress. Demo has clear limitations communicated (not silently broken features). |
| 7 | **Shareable & Exportable Content** | Exported content (PDFs, images, etc.) includes app branding. Share links include OG metadata for rich previews. QR codes/share links lead to branded experiences. Exported content includes "Made with [AppName]" or similar attribution. Share recipients see a clear CTA to try the app themselves. Export formats are optimized for their sharing context (social, email, print). |

### How to Analyze Each Category

For each category:
1. **Identify relevant files** — glob the project structure, find all files that touch this category (pages, components, layouts, API routes, utilities, styles)
2. **Read every relevant file** — don't sample, be exhaustive
3. **Check each item on the checklist** — verify the pattern IS present where it should be
4. **Identify gaps** — note where the checklist item is missing or poorly implemented
5. **Classify findings:**
   - **HIGH** — Missing or broken conversion path (no CTA on a landing page, broken signup flow, dead-end demo experience, no email capture at all, missing meta tags on key pages)
   - **MEDIUM** — Suboptimal but functional (weak CTA copy, poor button placement, missing email capture at a high-engagement point, onboarding skips the aha moment)
   - **LOW** — Nice-to-have polish (could add urgency language, minor copy improvements, optional micro-interactions, additional sharing format)

## Phase 3: Fix

1. List ALL findings for the audited category
2. Classify by severity (HIGH, MEDIUM, LOW)
3. Fix all HIGH and MEDIUM findings
4. For new features (referral system, share buttons, email capture triggers): implement if straightforward (< 100 lines per feature), defer if complex
5. Match the target app's existing code conventions — use its component library, CSS approach, routing patterns, and state management
6. **Never remove existing marketing/conversion features** — only add or improve
7. Cap at ~12 files per iteration; defer the rest
8. When writing copy for CTAs, buttons, or marketing elements, keep language professional, action-oriented, and aligned with the app's existing tone

## Phase 4: Validate

Run the project's quality checks. Look for scripts in `package.json`, `Makefile`, or CI config:

```bash
npm run lint:fix 2>/dev/null || true
npm run typecheck 2>/dev/null || true
npm run test 2>/dev/null || true
```

If any check fails, fix the issue and re-run. Max 3 fix attempts per check. If still failing after 3 attempts, revert the problematic change and note it as deferred.

Check E2E tests for stale assertions if content or behavior was changed. Marketing changes are particularly likely to break snapshot tests or content-dependent assertions — update them accordingly.

After validation is complete, clean up test artifacts and ensure no test processes are still running:

```bash
rm -rf coverage .nyc_output 2>/dev/null || true
pkill -f "vitest|jest" 2>/dev/null || true
```

## Phase 5: Update Tracking

Append a new entry to `docs/plans/funnel-audit-tracking.md`:

```markdown
### Iteration N (YYYY-MM-DD)

**Category:** <category name>
**Findings:** X total (Y HIGH, Z MEDIUM, W LOW)
**Fixed:** A
**Deferred:** B

#### Fixed

- [x] [HIGH] Description of fix
- [x] [MEDIUM] Description of fix

#### Deferred

- [ ] [LOW] Description (reason for deferral)

#### Categories Remaining

- [list of unaudited categories or categories with remaining HIGH/MEDIUM findings]
```

Update the category's status in the Categories table at the top of the tracking file:
- **Completed** — all checklist items pass, no HIGH or MEDIUM findings remain
- **Partial (N HIGH/MEDIUM remaining)** — some findings were deferred or unfixed

## Phase 6: Ship

**If issues were found and fixed:**

1. Stage specific changed files (do NOT use `git add -A` or `git add .`):
   ```bash
   git add <list of specific files>
   ```
2. Commit:
   ```bash
   git commit -m "fix: funnel-audit: <category> improvements from iteration N"
   ```
3. Push:
   ```bash
   git push -u origin funnel-audit/iteration-<N>
   ```
4. Create PR:
   ```bash
   gh pr create --title "Funnel Audit: Iteration N — <category>" --body "Automated top-of-funnel marketing audit. See docs/plans/funnel-audit-tracking.md for details."
   ```

**If NO issues found AND all 7 categories completed:** skip to Phase 8.

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
     git add <specific files> && git commit -m "fix: address CI failure in funnel-audit iteration N"
     git push
     ```

## Phase 8: Signal

Completion requires BOTH conditions:
1. All 7 marketing categories have been audited (check tracking file)
2. No HIGH or MEDIUM findings remain unfixed across any category

**If both conditions met**, output exactly:

```
<promise>FUNNEL_OPTIMIZED</promise>
```

**If either condition is NOT met**, exit normally. If running in a Ralph Loop, the loop will re-invoke for the next iteration.

Only output this promise if you genuinely audited all categories and verified no actionable findings remain.
