# Service Audit — Per-Service Checklists

Detailed check tables for each service. Referenced by the service-audit skill during Phase 2.

## Vercel

Check the following if Vercel is detected:

| # | Check | Method | Severity |
|---|-------|--------|----------|
| V1 | Recent deployment failures | `vercel ls` CLI or browser: Vercel dashboard > Deployments | CRITICAL |
| V2 | Build warnings in latest deploy | `vercel inspect <url>` CLI or browser: deployment build logs | MEDIUM |
| V3 | Missing or stale env vars (prod vs preview drift) | `vercel env ls` for each environment + compare to `.env.example` or `.env.local` | HIGH |
| V4 | Framework config issues | Inspect `vercel.json`, `next.config.*` for deprecated or misconfigured options | MEDIUM |
| V5 | Function duration/size approaching limits | Browser: Vercel dashboard > project > Functions tab | MEDIUM |
| V6 | Domain/SSL issues | `vercel domains ls` or browser: Vercel dashboard > project > Domains | HIGH |

## Supabase

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

## PostHog

Check the following if PostHog is detected:

| # | Check | Method | Severity |
|---|-------|--------|----------|
| P1 | Events tracked but unnamed/undocumented | Codebase: grep for `posthog.capture` and `posthog?.capture` calls, check for consistent naming convention | MEDIUM |
| P2 | High-volume noisy events | Browser: PostHog dashboard > Events > sort by volume | LOW |
| P3 | Stale feature flags still referenced in code | Codebase: grep for `posthog.isFeatureEnabled`, `posthog.getFeatureFlag`, `useFeatureFlagEnabled`; cross-ref with browser: PostHog > Feature Flags for active flags | MEDIUM |
| P4 | Feature flags with no rollout plan | Browser: PostHog > Feature Flags > check for flags at 0% or 100% for extended periods | LOW |
| P5 | Missing properties on tracked events | Codebase: check for inconsistent property schemas across `capture` calls for the same event name | MEDIUM |

## Sentry

Check the following if Sentry is detected:

| # | Check | Method | Severity |
|---|-------|--------|----------|
| E1 | Unresolved errors (new or regression) | Sentry API: `curl -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" https://sentry.io/api/0/projects/{org}/{proj}/issues/?query=is:unresolved` or browser: Sentry > Issues | CRITICAL |
| E2 | High-frequency repeating errors | Sentry API or browser: Sentry > Issues sorted by frequency | HIGH |
| E3 | Outdated SDK version | Codebase: compare `@sentry/*` version in `package.json` against latest on npm | MEDIUM |
| E4 | Missing source maps config | Codebase: check `sentry.client.config.*`, `sentry.server.config.*`, `next.config.*` for source map upload configuration | HIGH |
| E5 | Missing environment tags | Codebase: check Sentry init calls for `environment` option | MEDIUM |
| E6 | Web vitals regressions (LCP/FID/CLS) | Browser: Sentry > Performance > Web Vitals | MEDIUM |

## GitHub

GitHub is always checked if a `.git` directory exists:

| # | Check | Method | Severity |
|---|-------|--------|----------|
| G1 | Failing CI workflows | `gh run list --status failure --limit 5` | CRITICAL |
| G2 | Deprecated action versions | Codebase: scan `.github/workflows/*.yml` for action versions; check for outdated major versions | MEDIUM |
| G3 | Dependabot security alerts | `gh api /repos/{owner}/{repo}/dependabot/alerts --jq '[.[] \| select(.state=="open")]'` | HIGH |
| G4 | Stale branches (>30 days, already merged) | `gh api /repos/{owner}/{repo}/branches --paginate --jq '.[] \| select(.name != "main")'` + check age | LOW |
| G5 | Open PRs without review >7 days | `gh pr list --state open --json number,createdAt,reviewDecision` | MEDIUM |
| G6 | Missing branch protection on main | `gh api /repos/{owner}/{repo}/branches/main/protection` (404 = unprotected) | HIGH |
