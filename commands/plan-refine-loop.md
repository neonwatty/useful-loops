---
description: "Loop plan-refine until no further improvements are found. Requires ralph-loop plugin."
argument-hint: "\"PROMPT\" PLAN_FILE [--max N]"
---

# Plan Refine Loop

Start a Ralph Loop that repeatedly applies a prompt-driven analysis to a plan document until no further improvements are found.

Parse the arguments: extract the quoted PROMPT string, the PLAN_FILE path, and an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop:ralph-loop "/useful-loops:plan-refine \"<PROMPT>\" <PLAN_FILE>" --completion-promise "PLAN_REFINED" --max-iterations <N>
```

Replace `<PROMPT>` and `<PLAN_FILE>` with the values from the arguments, and `<N>` with the max iterations (default 10).
