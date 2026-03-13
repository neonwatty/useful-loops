---
name: gap-loop
description: "This command should be used when the user asks to 'loop gap analysis', 'keep running gap analysis', or 'close all gaps against a reference'. Loops gap analysis iterations until no gaps remain. Requires ralph-loop plugin."
argument-hint: "REFERENCE_REPO_URL [--max N]"
---

# Gap Analysis Loop

Start a Ralph Loop that repeatedly runs gap analysis against a reference app until no gaps remain.

Parse the arguments: extract the reference repo URL and an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop:ralph-loop "/useful-loops:gap-analysis <REFERENCE_REPO_URL>" --completion-promise "NO_GAPS_FOUND" --max-iterations <N>
```

Replace `<REFERENCE_REPO_URL>` with the URL from the arguments, and `<N>` with the max iterations (default 10).
