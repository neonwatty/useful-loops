# Funnel Audit — Design Document

**Date:** 2026-03-02
**Skill files:** `commands/funnel-audit.md` (single iteration) + `commands/funnel-loop.md` (loop wrapper)

## Purpose

Iteratively audit and improve top-of-funnel marketing across a SaaS web app. Each iteration focuses on one marketing category, applies a built-in best-practices checklist, implements HIGH and MEDIUM fixes, and ships via PR.

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scope | Comprehensive (CTAs, referral, email, onboarding, SEO, demo funnel, exports) | User wants full top-of-funnel coverage |
| Output | Implement code changes, PR, merge | Matches existing sweeps pattern |
| Categories per iteration | 1 | Deep focus, manageable scope within ~12 file cap |
| Analysis method | Built-in checklist per category | No external reference app needed |
| Severity model | HIGH/MEDIUM/LOW, fix HIGH+MEDIUM | Consistent with existing sweeps |
| Specificity | Generic SaaS (not app-specific) | Reusable across projects |
| Approach | Category-sequential | Fixed order through all categories, re-sweep for remaining findings |
| Completion promise | `FUNNEL_OPTIMIZED` | All 7 categories swept, no HIGH/MEDIUM remaining |
| Tracking file | `docs/plans/funnel-audit-tracking.md` | Consistent with other sweeps |

## Categories (in sweep order)

### 1. CTAs & Conversion Points
- Every public page has at least one clear CTA leading to signup/demo
- Primary CTAs use action-oriented copy (not generic "Submit" or "Click here")
- CTA buttons have strong visual contrast and are above the fold
- Multiple CTA placements per long page (hero, mid-page, bottom)
- CTAs use consistent language matching the value prop
- Mobile CTAs are full-width or thumb-reachable
- No dead-end pages (every page has a next step)

### 2. Referral & Viral Mechanics
- Share functionality exists for core outputs (charts, plans, results)
- Shared content includes branding/attribution back to the app
- Invite flow exists (email, link, or code-based)
- Referral incentives are communicated (even if just "share with a friend")
- Social sharing buttons/links on key outputs
- Shareable URLs are clean and include OG metadata

### 3. Email Capture & Lead Nurture
- Email capture exists on landing page
- Email capture triggers at engagement milestones (not just page load)
- Capture forms have clear value proposition (not just "subscribe")
- Exit-intent or scroll-depth triggers exist
- Captured emails are sent to a real service (not just logged)
- No duplicate capture modals in a single session
- Dismissed captures respect cooldown periods

### 4. Onboarding & Activation
- First-run experience guides users to core value action
- Progress indicators show how far through onboarding
- Skip option available (not forced)
- Onboarding references the user's actual data when possible
- Celebration/success moment at completion of first key action
- Empty states have clear "get started" messaging
- Time-to-first-value is minimized (no unnecessary setup steps)

### 5. SEO & Content Discoverability
- All public pages have unique, descriptive `<title>` and `meta description`
- Structured data (JSON-LD) on key pages
- Canonical URLs set correctly
- Internal linking between related pages
- Image alt text on all meaningful images
- sitemap.xml exists and is current
- robots.txt allows appropriate crawling
- OG/Twitter card metadata on shareable pages

### 6. Demo-to-Signup Funnel
- Demo is accessible without signup (reduces friction)
- Demo showcases core value prop clearly
- Strategic feature gating nudges signup at high-engagement moments
- Signup prompt appears after user has experienced value (not before)
- Demo-to-signup transition preserves user's work/progress
- Demo has clear limitations communicated (not silently broken features)

### 7. Shareable & Exportable Content
- Exported content (PDFs, images, etc.) includes app branding
- Share links include OG metadata for rich previews
- QR codes/share links lead to branded experiences
- Exported content includes "Made with [AppName]" or similar attribution
- Share recipients see a clear CTA to try the app themselves
- Export formats are optimized for their sharing context (social, email, print)

## 8-Phase Lifecycle

### Phase 1: Setup
- Ensure on `main` with latest code
- Read `docs/plans/funnel-audit-tracking.md` (create if doesn't exist with all 7 categories listed as "Not Started")
- Calculate iteration number (N+1)
- Determine next unaudited category (or first category with remaining HIGH/MEDIUM if all visited)
- Create branch: `funnel-audit/iteration-<N>`
- Review prior iterations to avoid re-fixing already-addressed items

### Phase 2: Analyze
- Glob and read all files relevant to the current category
- Apply the category's built-in checklist
- List ALL findings with severity (HIGH/MEDIUM/LOW)
- For each finding, identify the specific file(s) and what needs to change
- HIGH = missing/broken conversion path
- MEDIUM = suboptimal but functional
- LOW = nice-to-have polish

### Phase 3: Fix
- Fix all HIGH and MEDIUM findings
- Cap at ~12 files modified per iteration
- If more than 12 files need changes, fix highest-severity first and defer the rest
- Write clean, idiomatic code matching the target app's existing patterns

### Phase 4: Validate
- Run project quality checks: `lint:fix`, `typecheck`, `test`
- Check that no existing functionality is broken
- Max 3 fix attempts per failing check; revert and defer if still failing

### Phase 5: Update Tracking
- Append iteration entry to `docs/plans/funnel-audit-tracking.md`:

```markdown
## Iteration N — YYYY-MM-DD
**Category:** <category name>
**Findings:** X total (Y HIGH, Z MEDIUM, W LOW)

### Fixed
- [HIGH] Description of fix
- [MEDIUM] Description of fix

### Deferred
- [LOW] Description of deferred item

### Categories Remaining
- Category A
- Category B
```

- Update category status (Completed / Partial — N HIGH/MEDIUM remaining)

### Phase 6: Ship
- Only ship if changes were made
- Stage specific files (NEVER `git add -A` or `git add .`)
- Commit: `fix: funnel-audit: <category> improvements from iteration N`
- Push to iteration branch
- Create PR with findings summary

### Phase 7: CI & Merge
- Poll CI every 45 seconds
- On success: squash-merge, delete branch
- On failure: read logs, fix, push, re-poll (max 3 attempts)

### Phase 8: Signal
- If uncompleted categories remain OR any completed category has HIGH/MEDIUM findings → exit normally
- If all 7 categories swept AND no HIGH/MEDIUM findings → emit `<promise>FUNNEL_OPTIMIZED</promise>`

## File Structure

```
commands/
├── funnel-audit.md      # Single-iteration skill (~180 lines)
├── funnel-loop.md       # Ralph Loop wrapper (~19 lines)
```

## Loop Wrapper

`funnel-loop.md` invokes:
```
/ralph-loop "/codebase-sweeps:funnel-audit" --completion-promise "FUNNEL_OPTIMIZED" --max-iterations <N>
```

Default max iterations: 10.
