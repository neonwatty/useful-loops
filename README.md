# codebase-sweeps

A Claude Code plugin for autonomous, iterative codebase improvement. Runs gap analysis, test coverage, and security audits in loops that find issues, fix them, PR, pass CI, merge, and repeat.

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

### Looped (requires ralph-loop plugin)

| Command | Description |
|---------|-------------|
| `/codebase-sweeps:gap-loop <repo-url> [--max N]` | Loop gap analysis until no gaps remain |
| `/codebase-sweeps:test-loop [threshold] [--max N]` | Loop test coverage until threshold met |
| `/codebase-sweeps:security-loop [--max N]` | Loop security audit until all categories clean |

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

## Examples

```bash
# Single gap analysis iteration against a reference app
/codebase-sweeps:gap-analysis https://github.com/org/reference-app

# Loop test coverage to 90% with max 15 iterations
/codebase-sweeps:test-loop 90 --max 15

# Loop security audit with defaults (10 iterations)
/codebase-sweeps:security-loop
```

## License

MIT
