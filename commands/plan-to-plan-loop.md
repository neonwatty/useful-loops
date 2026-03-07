---
description: "Loop plan-to-plan until the target plan fully covers the source plan. Requires ralph-loop plugin."
argument-hint: "SOURCE_PLAN TARGET [--max N]"
---

# Plan to Plan Loop

Start a Ralph Loop that repeatedly compares a target plan against a source plan and closes gaps until the target fully covers the source.

Parse the arguments: extract the SOURCE_PLAN path, the TARGET path (a single `.md` file or a directory of `.md` files), and an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop "/useful-loops:plan-to-plan <SOURCE_PLAN> <TARGET>" --completion-promise "PLANS_ALIGNED" --max-iterations <N>
```

Replace `<SOURCE_PLAN>` and `<TARGET>` with the paths from the arguments, and `<N>` with the max iterations (default 10).
