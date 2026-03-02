---
description: "Loop service sweep until no CRITICAL/HIGH findings remain. Requires ralph-loop plugin."
argument-hint: "[--max N]"
---

# Service Sweep Loop

Start a Ralph Loop that repeatedly sweeps all detected services until the stack is healthy.

Parse the arguments: extract an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop "/codebase-sweeps:service-sweep" --completion-promise "SERVICES_HEALTHY" --max-iterations <N>
```

Replace `<N>` with the max iterations (default 10).
