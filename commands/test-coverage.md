---
description: "One test coverage iteration: find untested business logic, write tests, validate, PR, CI, merge. Target: 80% coverage."
argument-hint: "[COVERAGE_THRESHOLD]"
---

# Test Coverage — Full Cycle

You are performing one complete test coverage iteration. Report progress at each phase.

**Coverage threshold:** $ARGUMENTS

If no threshold was provided above, default to 80.

## Phase 1: Setup

1. Ensure you are on main with the latest code:
   ```bash
   git checkout main && git pull origin main
   ```

2. Read `docs/plans/test-coverage-tracking.md` to find the last iteration number. Your iteration is N+1. If no iterations exist yet, you are iteration 1. If the tracking file does not exist, create it:
   ```markdown
   # Test Coverage Tracking

   Automated tracking of test coverage improvements. Target: >= <threshold>% across all metrics.

   ---

   ## Iteration Log
   ```

3. Create an iteration branch:
   ```bash
   git checkout -b test-coverage/iteration-<N>
   ```

4. Review which files were already covered in prior iterations. Focus on uncovered ground.

## Phase 2: Find Untested Files

1. Glob for all source files in the project's source directory (check project structure — commonly `src/`, `lib/`, `app/`).

2. For each source file, check if an adjacent test file exists (`.test.ts`, `.test.tsx`, `.spec.ts`, `.spec.tsx`, `__tests__/` directory).

3. Classify untested files by priority:

   | Priority | Target | Rationale |
   |----------|--------|-----------|
   | P0 | Server actions, API routes, mutation handlers | Business-critical code paths |
   | P1 | Shared utilities and library code | Used everywhere, high impact |
   | P2 | State management (contexts, stores, reducers) | Complex logic, state transitions |
   | P3 | Custom hooks | Reusable behavior with edge cases |
   | P4 | Middleware, auth, route guards | Security-critical code |
   | P5 | Email/notification templates | Render correctness |
   | P6 | Page/route components | Only if they contain meaningful logic |
   | Skip | UI primitives (thin wrappers around library components) | Low value |
   | Skip | Type-only files | No runtime behavior |
   | Skip | Test infrastructure files | Not testable targets |
   | Skip | Index/barrel files (re-exports only) | No logic |

4. Cross-reference against the tracking file to skip files already covered in prior iterations.

5. Pick the next 3-5 untested files by priority order (lowest priority number first).

## Phase 3: Write Tests

For each selected file, write a test file following existing project test patterns. Read 2-3 existing test files first to understand the conventions (test runner, assertion style, mock patterns).

**Test quality rules:**
- Arrange/Act/Assert pattern in every test
- Reset mocks in `beforeEach`
- Happy path + at least one error case per exported function
- For server actions/API routes: test auth rejection, validation rejection, successful operation
- For state management: test state transitions and edge cases
- Test behavior, not implementation details

**File placement:** match the project's existing convention (adjacent to source, `__tests__/` directory, or mirrored test directory).

## Phase 4: Validate

Run the project's quality checks:

```bash
npm run lint:fix 2>/dev/null || true
npm run typecheck 2>/dev/null || true
npm run test 2>/dev/null || true
```

If any source files were modified (not just test files added), check for E2E tests that may assert on changed behavior and update stale assertions.

Then check coverage (try common commands):

```bash
npm run test:coverage 2>/dev/null || npx vitest run --coverage 2>/dev/null || npx jest --coverage 2>/dev/null || true
```

Parse the coverage summary output for the "All files" line. Record the four metrics: lines, branches, functions, statements.

If any check fails, fix the issue and re-run. Max 3 fix attempts per check. If still failing, revert the problematic test file and note it as deferred.

## Phase 5: Update Tracking

Append a new entry to `docs/plans/test-coverage-tracking.md`:

```markdown
### Iteration N (YYYY-MM-DD)

**Files Tested:** X
**Coverage:** lines XX%, branches XX%, functions XX%, statements XX%
**Remaining P0-P5 Untested:** Y files

#### Tests Written

- [x] `path/to/file.ts` (priority: PX, Y tests)

#### Deferred

- [ ] `path/to/file.ts` (reason)
```

## Phase 6: Ship

**If tests were written:**

1. Stage specific changed files (do NOT use `git add -A` or `git add .`):
   ```bash
   git add <list of specific test files and any modified source files>
   ```
2. Commit:
   ```bash
   git commit -m "test: add tests from test coverage iteration N"
   ```
3. Push:
   ```bash
   git push -u origin test-coverage/iteration-<N>
   ```
4. Create PR:
   ```bash
   gh pr create --title "Test Coverage: Iteration N" --body "Automated test coverage improvement. See docs/plans/test-coverage-tracking.md for details."
   ```

**If NO untested P0-P5 files remain AND coverage >= threshold:** skip to Phase 8.

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
     git add <specific files> && git commit -m "fix: address CI failure in test coverage iteration N"
     git push
     ```

## Phase 8: Signal

Completion requires BOTH conditions:
1. All P0-P5 priority files have tests (no untested business logic files remain)
2. Coverage reports >= threshold across lines, branches, functions, AND statements

**If both conditions met**, output exactly:

```
<promise>FULL_COVERAGE</promise>
```

**If either condition is NOT met**, exit normally. If running in a Ralph Loop, the loop will re-invoke for the next iteration.

Only output this promise if you genuinely verified both conditions. Do not estimate or assume coverage numbers.
