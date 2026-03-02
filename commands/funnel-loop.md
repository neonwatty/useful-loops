---
description: "Loop funnel audit until all marketing categories optimized. Requires ralph-loop plugin."
argument-hint: "[--max N]"
---

# Funnel Audit Loop

Start a Ralph Loop that repeatedly audits top-of-funnel marketing until all 7 categories are covered and no HIGH or MEDIUM issues remain.

Parse the arguments: extract an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop "/codebase-sweeps:funnel-audit" --completion-promise "FUNNEL_OPTIMIZED" --max-iterations <N>
```

Replace `<N>` with the max iterations (default 10).
