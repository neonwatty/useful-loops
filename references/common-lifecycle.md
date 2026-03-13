# Common Lifecycle Phases

Shared phases for skills that follow the full git lifecycle. Each skill references these phases after its domain-specific analysis and fix phases.

## Validate

Run the project's quality checks. Look for scripts in `package.json`, `Makefile`, or CI config:

```bash
npm run lint:fix 2>/dev/null || true
npm run typecheck 2>/dev/null || true
npm run test 2>/dev/null || true
```

Adapt fixes to this project's conventions (check `CLAUDE.md` if it exists for project-specific guidelines).

Check for E2E tests that may assert on changed behavior or content. Update stale assertions before pushing.

If any check fails, fix the issue and re-run. Max 3 fix attempts per check. If still failing after 3 attempts, revert the problematic change and note it as deferred.

After validation, clean up test artifacts and ensure no test processes are still running:

```bash
rm -rf coverage .nyc_output 2>/dev/null || true
pkill -f "vitest|jest" 2>/dev/null || true
```

## Ship

1. Stage specific changed files (do NOT use `git add -A` or `git add .`):
   ```bash
   git add <list of specific files>
   ```
2. Commit with the iteration branch name as context:
   ```bash
   git commit -m "<prefix>: <brief summary> from iteration N"
   ```
3. Push:
   ```bash
   git push -u origin <iteration-branch>
   ```
4. Create PR:
   ```bash
   gh pr create --title "<Skill Title>: Iteration N" --body "<summary>. See docs/plans/<tracking-file>.md for details."
   ```

## CI & Merge

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
     git add <specific files> && git commit -m "fix: address CI failure in iteration N"
     git push
     ```
