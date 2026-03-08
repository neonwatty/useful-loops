---
description: "Loop security audit until all OWASP categories clean. Requires ralph-loop plugin."
argument-hint: "[--max N]"
---

# Security Audit Loop

Start a Ralph Loop that repeatedly audits security until all 10 OWASP categories are covered and no issues remain.

Parse the arguments: extract an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop:ralph-loop "/useful-loops:security-audit" --completion-promise "NO_ISSUES" --max-iterations <N>
```

Replace `<N>` with the max iterations (default 10).
