---
description: "Loop beta audit until no HIGH/MEDIUM code findings remain. Requires ralph-loop plugin."
argument-hint: "[--max N]"
---

# Beta Audit Loop

Start a Ralph Loop that repeatedly runs beta audits until the app is beta-ready.

Parse the arguments: extract an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop:ralph-loop "/useful-loops:beta-audit" --completion-promise "BETA_READY" --max-iterations <N>
```

Replace `<N>` with the max iterations (default 10).
