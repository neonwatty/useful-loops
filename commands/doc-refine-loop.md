---
description: "Loop doc-refine until no further improvements are found. Requires ralph-loop plugin."
argument-hint: "\"PROMPT\" DOC_FILE [--max N]"
---

# Doc Refine Loop

Start a Ralph Loop that repeatedly applies a prompt-driven analysis to a document until no further improvements are found.

Parse the arguments: extract the quoted PROMPT string, the DOC_FILE path, and an optional `--max N` for max iterations (default: 10).

Now invoke the Ralph Loop skill with these parameters:

```
/ralph-loop:ralph-loop "/useful-loops:doc-refine \"<PROMPT>\" <DOC_FILE>" --completion-promise "DOC_REFINED" --max-iterations <N>
```

Replace `<PROMPT>` and `<DOC_FILE>` with the values from the arguments, and `<N>` with the max iterations (default 10).
