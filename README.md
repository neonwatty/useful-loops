# codebase-sweeps

A Claude Code plugin for autonomous, iterative codebase improvement. Runs gap analysis, test coverage, security audits, beta-readiness audits, and service health audits in loops that find issues, fix them, PR, pass CI, merge, and repeat.

Designed to work with the [Ralph Loop](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-loop) plugin for automated iteration.

## Install

```bash
claude plugin marketplace add neonwatty/codebase-sweeps
claude plugin install codebase-sweeps@codebase-sweeps
```

Also install the Ralph Loop plugin if you want looping:

```bash
claude plugin install ralph-loop
```

## Commands

### Single Iteration (run once)

| Command | Description |
|---------|-------------|
| `/codebase-sweeps:gap-analysis <repo-url>` | Compare this app against a reference app, fix gaps |
| `/codebase-sweeps:test-coverage [threshold]` | Find untested files, write tests (default: 80%) |
| `/codebase-sweeps:security-audit` | Audit 1-2 OWASP categories, fix findings |
| `/codebase-sweeps:beta-audit` | Holistic beta-readiness review across 5 dimensions |
| `/codebase-sweeps:service-audit` | Audit Vercel, Supabase, PostHog, Sentry, GitHub for issues |

### Looped (requires ralph-loop plugin)

| Command | Description |
|---------|-------------|
| `/codebase-sweeps:gap-loop <repo-url> [--max N]` | Loop gap analysis until no gaps remain |
| `/codebase-sweeps:test-loop [threshold] [--max N]` | Loop test coverage until threshold met |
| `/codebase-sweeps:security-loop [--max N]` | Loop security audit until all categories clean |
| `/codebase-sweeps:beta-audit-loop [--max N]` | Loop beta audit until no HIGH/MEDIUM code findings |
| `/codebase-sweeps:service-audit-loop [--max N]` | Loop service audit until no CRITICAL/HIGH findings |

Default max iterations: 10.

## How It Works

Each skill follows an 8-phase lifecycle per iteration:

1. **Setup** — checkout main, create iteration branch, read tracking file
2. **Analyze** — domain-specific analysis (compare repos, find untested files, audit security)
3. **Fix** — prioritize and fix HIGH/MEDIUM issues (cap ~12 files per iteration)
4. **Validate** — run lint, typecheck, tests
5. **Track** — append results to tracking file in `docs/plans/`
6. **Ship** — commit, push, create PR
7. **CI & Merge** — poll CI, fix failures, squash-merge when green
8. **Signal** — exit normally (more work to do) or emit completion promise (done)

When run in a Ralph Loop, the same prompt is fed back after each iteration. Claude sees its previous work via the tracking files and git history, focusing on uncovered ground each time.

### Tracking Files

Each skill maintains a tracking file in `docs/plans/`:

- `gap-tracking.md` — gap analysis iterations
- `test-coverage-tracking.md` — test coverage iterations
- `security-audit-tracking.md` — security audit iterations
- `beta-audit-tracking.md` — beta audit iterations
- `beta-manual-todos.md` — accumulating manual to-do checklist from beta audits
- `service-audit-tracking.md` — service health audit iterations
- `service-audit-manual-todos.md` — accumulating manual to-do checklist from service audits

These files are created automatically on first run and serve as inter-iteration memory.

## Skills Detail

### Gap Analysis

Compares your app against a reference implementation across 6 dimensions:

- Pages & Routes
- Components
- Styling & Visual Design
- Content & Copy
- UX Flows & Interactions
- Assets & Media

Adapts client-side patterns for your architecture (e.g., converting mock data to real queries, client components to server components).

**Completion:** `NO_GAPS_FOUND` when all 6 dimensions are clean.

### Test Coverage

Finds untested files and writes tests in priority order:

- P0: Server actions, API routes, mutation handlers
- P1: Shared utilities and library code
- P2: State management (contexts, stores)
- P3: Custom hooks
- P4: Middleware, auth, route guards
- P5: Email/notification templates

**Completion:** `FULL_COVERAGE` when all P0-P5 files have tests AND coverage >= threshold.

### Security Audit

OWASP-aligned audit covering 10 categories (1-2 per iteration):

1. Auth & Access Control (A01)
2. Input Validation (A03)
3. Authorization / Row-Level Security (A01)
4. Secret Management (A02)
5. Security Headers (A05)
6. Dependency Vulnerabilities (A06)
7. Rate Limiting (A04)
8. Error Handling (A09)
9. CSRF/Session (A07)
10. Data Exposure (A02)

**Completion:** `NO_ISSUES` when all 10 categories audited with no HIGH/MEDIUM findings.

### Beta Audit

Holistic beta-readiness review using 5 parallel explorer agents:

- Feature Completeness — incomplete flows, placeholder data, dead-end UX, compliance gaps
- Error Handling & Edge Cases — missing loading/empty states, validation gaps, network failures
- Polish & UX Quality — accessibility, styling consistency, mobile responsiveness, dead features
- Ops & Infra Readiness — monitoring, email deliverability, production safety guards, rate limiting
- Performance — redundant API calls, unparallelized queries, deferred loading opportunities

Findings are classified by severity (HIGH/MEDIUM/LOW) and type (CODE/MANUAL). Code issues are fixed in the PR. Manual to-dos (service provider config, deployment settings, etc.) are collected into a separate `docs/plans/beta-manual-todos.md` checklist that accumulates across iterations.

**Completion:** `BETA_READY` when no HIGH/MEDIUM code findings remain across all 5 dimensions.

### Service Audit

Checks the health of your service stack (Vercel, Supabase, PostHog, Sentry, GitHub) using a combination of codebase inspection, CLIs/APIs, and browser dashboard checks. Auto-detects which services your project uses by scanning `package.json`, env files, and config files.

Findings are classified by severity (CRITICAL/HIGH/MEDIUM/LOW) and type:

- **CODE** — auto-fixed in the codebase (SDK updates, config fixes, migration files)
- **BROWSER** — fixed interactively via Claude-in-Chrome with user confirmation
- **MANUAL** — collected into `docs/plans/service-audit-manual-todos.md` for human action

**Services & checks:**

- **Vercel** — deployment failures, build warnings, env var drift, config issues, function limits, domain/SSL
- **Supabase** — missing RLS, permissive policies, missing indexes, auth config, storage permissions, migration drift
- **PostHog** — unnamed events, stale feature flags, inconsistent event properties
- **Sentry** — unresolved errors, high-frequency issues, outdated SDK, missing source maps, web vitals
- **GitHub** — failing CI, deprecated actions, dependabot alerts, stale branches, unreviewed PRs, branch protection

**Completion:** `SERVICES_HEALTHY` when all detected services are swept with no CRITICAL/HIGH code findings remaining.

## Examples

```bash
# Single gap analysis iteration against a reference app
/codebase-sweeps:gap-analysis https://github.com/org/reference-app

# Loop test coverage to 90% with max 15 iterations
/codebase-sweeps:test-loop 90 --max 15

# Loop security audit with defaults (10 iterations)
/codebase-sweeps:security-loop

# Single beta audit iteration
/codebase-sweeps:beta-audit

# Loop beta audit with max 8 iterations
/codebase-sweeps:beta-audit-loop --max 8

# Single service health audit
/codebase-sweeps:service-audit

# Loop service audit with max 5 iterations
/codebase-sweeps:service-audit-loop --max 5
```

## License

MIT
