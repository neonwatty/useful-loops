#!/bin/bash
#
# Test: verify every Ralph Loop wrapper's --completion-promise matches
#       the <promise> tag in its corresponding single-iteration skill.
#
# Checks:
#   1. Each *-loop.md with a /ralph-loop invocation references a skill that exists
#   2. The --completion-promise value matches the <promise>TAG</promise> in that skill
#   3. Every single-iteration skill that outputs a <promise> has a corresponding loop wrapper

set -euo pipefail

COMMANDS_DIR="$(cd "$(dirname "$0")/../commands" && pwd)"
ERRORS=0
PASS=0

echo "=== Ralph Loop Wiring Tests ==="
echo ""

# --------------------------------------------------------------------------
# Test 1 & 2: Each loop wrapper points to an existing skill with matching promise
# --------------------------------------------------------------------------

for loop_file in "$COMMANDS_DIR"/*-loop.md; do
  loop_name="$(basename "$loop_file")"

  # Extract the /ralph-loop invocation line (matches both /ralph-loop and /ralph-loop:ralph-loop)
  ralph_line="$(grep '/ralph-loop[: ]' "$loop_file" 2>/dev/null || true)"

  # Skip loop files that don't use Ralph Loop (e.g. funnel-loop.md)
  if [[ -z "$ralph_line" ]]; then
    echo "SKIP  $loop_name (no /ralph-loop invocation — intentionally not a Ralph Loop wrapper)"
    continue
  fi

  # Extract skill name from /useful-loops:<skill-name>
  skill_name="$(echo "$ralph_line" | grep -oE '/useful-loops:[a-z0-9-]+' | sed 's|/useful-loops:||')"
  if [[ -z "$skill_name" ]]; then
    echo "FAIL  $loop_name — could not parse skill name from /ralph-loop invocation"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Check the single-iteration skill file exists
  skill_file="$COMMANDS_DIR/$skill_name.md"
  if [[ ! -f "$skill_file" ]]; then
    echo "FAIL  $loop_name — references skill '$skill_name' but $skill_name.md does not exist"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Extract --completion-promise value from the loop wrapper
  loop_promise="$(echo "$ralph_line" | grep -oE '\-\-completion-promise "[^"]+"' | sed 's/--completion-promise "//;s/"$//')"
  if [[ -z "$loop_promise" ]]; then
    echo "FAIL  $loop_name — could not parse --completion-promise value"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Extract <promise>VALUE</promise> from the single-iteration skill
  skill_promise="$(grep -oE '<promise>[^<]+</promise>' "$skill_file" | sed 's/<promise>//;s/<\/promise>//' | head -1)"
  if [[ -z "$skill_promise" ]]; then
    echo "FAIL  $loop_name — skill '$skill_name.md' has no <promise> tag"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Compare
  if [[ "$loop_promise" != "$skill_promise" ]]; then
    echo "FAIL  $loop_name — promise mismatch:"
    echo "        loop wrapper:  --completion-promise \"$loop_promise\""
    echo "        skill output:  <promise>$skill_promise</promise>"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  echo "PASS  $loop_name → $skill_name.md (promise: $loop_promise)"
  PASS=$((PASS + 1))
done

echo ""

# --------------------------------------------------------------------------
# Test 3: Every skill with a <promise> tag is referenced by some loop wrapper
#         (except skills that are intentionally interactive)
# --------------------------------------------------------------------------

INTERACTIVE_SKILLS="funnel-audit"  # add others here if needed

for skill_file in "$COMMANDS_DIR"/*.md; do
  skill_name="$(basename "$skill_file" .md)"

  # Skip loop wrappers themselves
  if [[ "$skill_name" == *-loop ]]; then
    continue
  fi

  # Check if this skill outputs a promise
  skill_promise="$(grep -oE '<promise>[^<]+</promise>' "$skill_file" 2>/dev/null | head -1)"
  if [[ -z "$skill_promise" ]]; then
    continue
  fi

  # Skip interactive skills
  if echo "$INTERACTIVE_SKILLS" | grep -qw "$skill_name"; then
    echo "SKIP  $skill_name.md has <promise> but is interactive — no loop wrapper expected"
    continue
  fi

  # Check if ANY loop wrapper references this skill (handles naming mismatches
  # like gap-analysis.md → gap-loop.md or test-coverage.md → test-loop.md)
  found=false
  for loop_file in "$COMMANDS_DIR"/*-loop.md; do
    if grep -q "/useful-loops:$skill_name" "$loop_file" 2>/dev/null; then
      found=true
      break
    fi
  done

  if [[ "$found" == false ]]; then
    echo "FAIL  $skill_name.md outputs a <promise> but no loop wrapper references it"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  echo "PASS  $skill_name.md is referenced by a loop wrapper"
  PASS=$((PASS + 1))
done

echo ""
echo "=== Results: $PASS passed, $ERRORS failed ==="

if [[ $ERRORS -gt 0 ]]; then
  exit 1
fi
