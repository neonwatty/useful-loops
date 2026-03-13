---
name: funnel-loop
description: "This command should be used when the user asks to 'loop funnel audit', 'keep auditing funnel categories', or 'audit all marketing categories'. Explains that funnel audits are interactive and cannot run in an unattended loop — directs the user to run funnel-audit iterations one at a time."
---

# Funnel Audit — Next Iteration

The funnel audit is an **interactive** skill — it pauses at multiple checkpoints to discuss findings, copy, and feature decisions with you. It cannot run unattended in a Ralph Loop.

To run the next iteration, invoke the funnel-audit skill directly:

```
/useful-loops:funnel-audit
```

Each invocation walks through one marketing category collaboratively:
1. **You choose** which category to audit
2. **You review** the findings before any fixes happen
3. **You approve** copy, feature decisions, and implementation approach
4. **You confirm** before the PR is created and merged

Run one iteration at a time. After each iteration, decide whether to continue with the next category or pause.
