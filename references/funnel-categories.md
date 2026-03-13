# Funnel Audit — Category Checklists

Detailed checklists for each of the 7 top-of-funnel marketing categories. Referenced by the funnel-audit skill during Phase 2.

## Category Checklist Table

| # | Category | What to check |
|---|----------|---------------|
| 1 | **CTAs & Conversion Points** | Every public page has at least one clear CTA leading to signup/demo. Primary CTAs use action-oriented copy (not generic "Submit" or "Click here"). CTA buttons have strong visual contrast and are above the fold. Multiple CTA placements per long page (hero, mid-page, bottom). CTAs use consistent language matching the value prop. Mobile CTAs are full-width or thumb-reachable. No dead-end pages (every page has a next step). |
| 2 | **Referral & Viral Mechanics** | Share functionality exists for core outputs (charts, plans, results). Shared content includes branding/attribution back to the app. Invite flow exists (email, link, or code-based). Referral incentives are communicated (even if just "share with a friend"). Social sharing buttons/links on key outputs. Shareable URLs are clean and include OG metadata. |
| 3 | **Email Capture & Lead Nurture** | Email capture exists on landing page. Email capture triggers at engagement milestones (not just page load). Capture forms have clear value proposition (not just "subscribe"). Exit-intent or scroll-depth triggers exist. Captured emails are sent to a real service (not just logged). No duplicate capture modals in a single session. Dismissed captures respect cooldown periods. |
| 4 | **Onboarding & Activation** | First-run experience guides users to core value action. Progress indicators show how far through onboarding. Skip option available (not forced). Onboarding references the user's actual data when possible. Celebration/success moment at completion of first key action. Empty states have clear "get started" messaging. Time-to-first-value is minimized (no unnecessary setup steps). |
| 5 | **SEO & Content Discoverability** | All public pages have unique, descriptive title and meta description. Structured data (JSON-LD) on key pages. Canonical URLs set correctly. Internal linking between related pages. Image alt text on all meaningful images. sitemap.xml exists and is current. robots.txt allows appropriate crawling. OG/Twitter card metadata on shareable pages. |
| 6 | **Demo-to-Signup Funnel** | Demo is accessible without signup (reduces friction). Demo showcases core value prop clearly. Strategic feature gating nudges signup at high-engagement moments. Signup prompt appears after user has experienced value (not before). Demo-to-signup transition preserves user's work/progress. Demo has clear limitations communicated (not silently broken features). |
| 7 | **Shareable & Exportable Content** | Exported content (PDFs, images, etc.) includes app branding. Share links include OG metadata for rich previews. QR codes/share links lead to branded experiences. Exported content includes "Made with [AppName]" or similar attribution. Share recipients see a clear CTA to try the app themselves. Export formats are optimized for their sharing context (social, email, print). |

## How to Analyze Each Category

For each category:
1. **Identify relevant files** — glob the project structure, find all files that touch this category (pages, components, layouts, API routes, utilities, styles)
2. **Read every relevant file** — don't sample, be exhaustive
3. **Check each item on the checklist** — verify the pattern IS present where it should be
4. **Identify gaps** — note where the checklist item is missing or poorly implemented
5. **Classify findings:**
   - **HIGH** — Missing or broken conversion path (no CTA on a landing page, broken signup flow, dead-end demo experience, no email capture at all, missing meta tags on key pages)
   - **MEDIUM** — Suboptimal but functional (weak CTA copy, poor button placement, missing email capture at a high-engagement point, onboarding skips the aha moment)
   - **LOW** — Nice-to-have polish (could add urgency language, minor copy improvements, optional micro-interactions, additional sharing format)
