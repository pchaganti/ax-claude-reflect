#!/bin/bash
# V2: BLOCKS compaction if queue has items (exit code 2)
# Used by PreCompact hook

QUEUE_FILE="$HOME/.claude/learnings-queue.json"

if [ -f "$QUEUE_FILE" ]; then
  COUNT=$(jq 'length' "$QUEUE_FILE" 2>/dev/null || echo 0)
  if [ "$COUNT" -gt 0 ]; then
    echo ""
    echo "============================================================"
    echo "  COMPACTION BLOCKED: $COUNT learning(s) detected"
    echo "============================================================"
    echo ""
    echo "  Run one of:"
    echo "    /reflect       - Process and save learnings"
    echo "    /skip-reflect  - Discard learnings and proceed"
    echo ""
    echo "============================================================"
    echo ""
    exit 2  # EXIT CODE 2 = BLOCK THE ACTION
  fi
fi

exit 0
