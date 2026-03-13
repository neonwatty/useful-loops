---
name: test-loop
description: "This command should be used when the user asks to 'loop test coverage', 'keep writing tests until coverage is high', or 'reach 80% test coverage'. Loops test coverage iterations until the threshold is met. Requires ralph-loop plugin."
argument-hint: "[COVERAGE_THRESHOLD] [--max N]"
---

# Test Coverage Loop

Start a Ralph Loop that repeatedly adds tests until coverage threshold is met and all priority files are tested.

Parse the arguments: extract an optional coverage threshold (default: 80) and an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop:ralph-loop "/useful-loops:test-coverage <THRESHOLD>" --completion-promise "FULL_COVERAGE" --max-iterations <N>
```

Replace `<THRESHOLD>` with the coverage percentage (default 80), and `<N>` with the max iterations (default 10).
