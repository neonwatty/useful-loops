---
name: service-audit-loop
description: "This command should be used when the user asks to 'loop service audit', 'keep auditing services', or 'fix all service issues'. Loops service audit iterations until no CRITICAL/HIGH findings remain. Requires ralph-loop plugin."
argument-hint: "[--max N]"
---

# Service Audit Loop

Start a Ralph Loop that repeatedly audits all detected services until the stack is healthy.

Parse the arguments: extract an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop:ralph-loop "/useful-loops:service-audit" --completion-promise "SERVICES_HEALTHY" --max-iterations <N>
```

Replace `<N>` with the max iterations (default 10).
