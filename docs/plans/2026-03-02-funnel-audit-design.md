# Funnel Audit — Design Document

**Date:** 2026-03-02
**Updated:** 2026-03-03 (v2 — interactive mode)
**Skill files:** `commands/funnel-audit.md` (single iteration) + `commands/funnel-loop.md` (invocation helper)

## Purpose

Iteratively audit and improve top-of-funnel marketing across a SaaS web app. Each iteration focuses on one marketing category, applies a built-in best-practices checklist, **discusses findings with the user**, implements user-approved fixes, and ships via PR.

## Why Interactive?

Unlike security audits or test coverage (where findings are objective), funnel/marketing decisions are inherently subjective:

- **Copy and tone** depend on brand voice — only the user knows what sounds right
- **Feature decisions** (add a referral system? email capture modal?) are product strategy choices
- **Placement and layout** changes affect UX and require design judgment
- **Severity classification** is debatable — what's "HIGH" for one app may be irrelevant for another

Automated execution leads to generic, off-brand changes that the user ends up reverting. The interactive approach ensures every change reflects the user's actual product vision.

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scope | Comprehensive (CTAs, referral, email, onboarding, SEO, demo funnel, exports) | Full top-of-funnel coverage |
| Output | Implement code changes, PR, merge | Matches existing sweeps pattern |
| Categories per iteration | 1 | Deep focus, manageable scope within ~12 file cap |
| Analysis method | Built-in checklist per category | No external reference app needed |
| Severity model | HIGH/MEDIUM/LOW, fix user-approved items | User confirms severity and scope |
| Specificity | Generic SaaS (not app-specific) | Reusable across projects |
| Approach | User-directed | User chooses category order and approves every fix |
| **Automation level** | **Interactive with checkpoints** | **Marketing decisions require human judgment** |
| **Ralph Loop** | **Not supported** | **Cannot run unattended — user input required at every phase** |
| Completion promise | `FUNNEL_OPTIMIZED` | All 7 categories reviewed with user, no HIGH/MEDIUM remaining |
| Tracking file | `docs/plans/funnel-audit-tracking.md` | Consistent with other sweeps |

## User Checkpoints

The skill pauses for user input at these points:

| Phase | Checkpoint | What the user decides |
|-------|------------|----------------------|
| 1 — Setup | Category selection | Which category to audit this iteration |
| 2 — Analyze | Findings review | Confirm, reject, or reclassify each finding |
| 3 — Fix | Copy approval | Approve or rewrite CTA text, headlines, messaging |
| 3 — Fix | Feature decisions | Whether to add new features (referral, email capture, etc.) |
| 6 — Ship | PR creation | Review diff and approve before creating PR |
| 7 — CI & Merge | Merge decision | Approve merge or leave PR open for review |
| 8 — Signal | Continue? | Run another iteration or stop for today |

## Categories (in default order)

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

## 8-Phase Lifecycle (Interactive)

### Phase 1: Setup
- Ensure on `main` with latest code
- Read tracking file (create if needed)
- Calculate iteration number
- **ASK USER** which category to audit (suggest next unaudited, let them override)
- Create branch

### Phase 2: Analyze
- Glob and read all relevant files exhaustively
- Apply category checklist
- Classify findings (HIGH/MEDIUM/LOW)
- **ASK USER** to review findings — they may reject, reclassify, or add items

### Phase 3: Fix
- **ASK USER** to approve proposed copy/messaging before writing it
- **ASK USER** before implementing net-new features (referral system, email capture, etc.)
- Implement only user-approved fixes
- Match target app's code conventions
- Cap at ~12 files modified

### Phase 4: Validate
- Run lint, typecheck, tests (automated — no user input needed)
- Fix failures or revert and defer

### Phase 5: Update Tracking
- Append iteration entry with fixed, deferred, and **user-rejected** items
- Update category status

### Phase 6: Ship
- **ASK USER** before creating PR (offer to show diff first)
- Stage, commit, push, create PR

### Phase 7: CI & Merge
- Poll CI
- **ASK USER** before merging (or let them review on GitHub)
- On failure: fix and re-poll

### Phase 8: Signal
- If all categories reviewed and no HIGH/MEDIUM remaining → emit `FUNNEL_OPTIMIZED`
- Otherwise summarize what remains and **ASK USER** if they want another iteration

## File Structure

```
commands/
├── funnel-audit.md      # Single-iteration interactive skill
├── funnel-loop.md       # Invocation helper (no Ralph Loop — interactive)
```

## Differences from Other Sweeps

| Aspect | Security/Test/Gap/Beta | Funnel |
|--------|----------------------|--------|
| Automation level | Fully automated (Ralph Loop) | Interactive (user checkpoints) |
| Decision authority | Skill decides what to fix | User decides what to fix |
| Copy/messaging | N/A | User approves all copy |
| New features | Auto-implement if < 50 lines | User decides whether to add |
| Findings | Objective (vulnerability exists or not) | Subjective (user may disagree) |
| Loop wrapper | Ralph Loop | Manual re-invocation |
| Rejected findings | N/A | Tracked as "user-rejected" |
