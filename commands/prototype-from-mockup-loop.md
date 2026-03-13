---
name: prototype-from-mockup-loop
description: "Loop prototype-from-mockup until the prototype fully matches the mockup. Requires ralph-loop plugin."
argument-hint: "MOCKUP_DIR APP_DIR [--max N]"
---

# Prototype from Mockup Loop

Start a Ralph Loop that repeatedly compares a prototype against a mockup and closes gaps until the prototype faithfully matches the mockup.

Parse the arguments: extract the MOCKUP_DIR path, the APP_DIR path, and an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop:ralph-loop "/useful-loops:prototype-from-mockup <MOCKUP_DIR> <APP_DIR>" --completion-promise "PROTOTYPE_MATCHES_MOCKUP" --max-iterations <N>
```

Replace `<MOCKUP_DIR>` and `<APP_DIR>` with the paths from the arguments, and `<N>` with the max iterations (default 10).
