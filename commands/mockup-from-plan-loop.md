---
name: mockup-from-plan-loop
description: "This command should be used when the user asks to 'loop mockup from plan', 'keep building mockup until it matches the plan', or 'iteratively close mockup gaps'. Loops mockup-from-plan iterations until the mockup fully matches the plan. Requires ralph-loop plugin."
argument-hint: "PLAN MOCKUP_DIR [--max N]"
---

# Mockup from Plan Loop

Start a Ralph Loop that repeatedly compares a mockup against a plan and closes gaps until the mockup faithfully matches the plan.

Parse the arguments: extract the PLAN path (a single `.md` file or a directory of `.md` files), the MOCKUP_DIR path, and an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop:ralph-loop "/useful-loops:mockup-from-plan <PLAN> <MOCKUP_DIR>" --completion-promise "MOCKUP_MATCHES_PLAN" --max-iterations <N>
```

Replace `<PLAN>` and `<MOCKUP_DIR>` with the paths from the arguments, and `<N>` with the max iterations (default 10).
