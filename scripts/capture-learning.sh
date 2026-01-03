#!/bin/bash
# V2: Detects correction patterns OR explicit "remember:" in user prompts
# Used by UserPromptSubmit hook

QUEUE_FILE="$HOME/.claude/learnings-queue.json"

# Read JSON from stdin
INPUT="$(cat -)"
[ -z "$INPUT" ] && exit 0

# Extract prompt from JSON - handle different possible field names
PROMPT="$(echo "$INPUT" | jq -r '.prompt // .message // .text // empty' 2>/dev/null)"
[ -z "$PROMPT" ] && exit 0

# Get current project path
PROJECT="$(pwd)"

# Initialize queue if doesn't exist
[ ! -f "$QUEUE_FILE" ] && echo "[]" > "$QUEUE_FILE"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MATCHED_PATTERNS=""
TYPE=""

# Check for explicit "remember:"
if echo "$PROMPT" | grep -qi "remember:"; then
  TYPE="explicit"
  MATCHED_PATTERNS="remember:"
else
  # Check for correction patterns (conservative set to minimize false positives)
  # These patterns strongly indicate a user correction

  # Pattern: "no, use X" / "no use X"
  if echo "$PROMPT" | grep -qiE "no[,. ]+use"; then
    TYPE="auto"
    MATCHED_PATTERNS="$MATCHED_PATTERNS no,use"
  fi

  # Pattern: "don't use"
  if echo "$PROMPT" | grep -qiE "don't use|do not use"; then
    TYPE="auto"
    MATCHED_PATTERNS="$MATCHED_PATTERNS don't-use"
  fi

  # Pattern: "stop using" / "never use"
  if echo "$PROMPT" | grep -qiE "stop using|never use"; then
    TYPE="auto"
    MATCHED_PATTERNS="$MATCHED_PATTERNS stop/never-use"
  fi

  # Pattern: "that's wrong" / "that's incorrect"
  if echo "$PROMPT" | grep -qiE "that's (wrong|incorrect)|that is (wrong|incorrect)"; then
    TYPE="auto"
    MATCHED_PATTERNS="$MATCHED_PATTERNS that's-wrong"
  fi

  # Pattern: "not right" / "not correct"
  if echo "$PROMPT" | grep -qiE "not right|not correct"; then
    TYPE="auto"
    MATCHED_PATTERNS="$MATCHED_PATTERNS not-right"
  fi

  # Pattern: "actually," (strong correction signal)
  if echo "$PROMPT" | grep -qiE "^actually[,. ]|[.!?] actually[,. ]"; then
    TYPE="auto"
    MATCHED_PATTERNS="$MATCHED_PATTERNS actually"
  fi

  # Pattern: "I meant" / "I said"
  if echo "$PROMPT" | grep -qiE "I meant|I said"; then
    TYPE="auto"
    MATCHED_PATTERNS="$MATCHED_PATTERNS I-meant/said"
  fi

  # Pattern: "I told you" / "I already told"
  if echo "$PROMPT" | grep -qiE "I told you|I already told"; then
    TYPE="auto"
    MATCHED_PATTERNS="$MATCHED_PATTERNS I-told-you"
  fi

  # Pattern: "you should use" / "you need to use"
  if echo "$PROMPT" | grep -qiE "you (should|need to|must) use"; then
    TYPE="auto"
    MATCHED_PATTERNS="$MATCHED_PATTERNS you-should-use"
  fi

  # Pattern: "use X not Y" / "not X, use Y"
  if echo "$PROMPT" | grep -qiE "use .+ not|not .+, use"; then
    TYPE="auto"
    MATCHED_PATTERNS="$MATCHED_PATTERNS use-X-not-Y"
  fi
fi

# If we found something, queue it
if [ -n "$TYPE" ]; then
  # Trim leading space from matched patterns
  MATCHED_PATTERNS=$(echo "$MATCHED_PATTERNS" | sed 's/^ *//')

  jq --arg type "$TYPE" \
     --arg msg "$PROMPT" \
     --arg ts "$TIMESTAMP" \
     --arg proj "$PROJECT" \
     --arg patterns "$MATCHED_PATTERNS" \
    '. += [{"type": $type, "message": $msg, "timestamp": $ts, "project": $proj, "patterns": $patterns}]' \
    "$QUEUE_FILE" > "$QUEUE_FILE.tmp" 2>/dev/null && mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
fi

exit 0
