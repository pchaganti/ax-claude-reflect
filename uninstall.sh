#!/bin/bash
# claude-reflect uninstaller
# Removes claude-reflect commands and scripts

set -e

CLAUDE_DIR="$HOME/.claude"

echo "═══════════════════════════════════════════════════════════"
echo "  Uninstalling claude-reflect"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Remove commands
echo "→ Removing commands..."
rm -f "$CLAUDE_DIR/commands/reflect.md"
rm -f "$CLAUDE_DIR/commands/skip-reflect.md"
rm -f "$CLAUDE_DIR/commands/view-queue.md"
echo "  ✓ Removed /reflect, /skip-reflect, /view-queue"

# Remove scripts
echo "→ Removing scripts..."
rm -f "$CLAUDE_DIR/scripts/capture-learning.sh"
rm -f "$CLAUDE_DIR/scripts/extract-session-learnings.sh"
rm -f "$CLAUDE_DIR/scripts/extract-tool-rejections.sh"
rm -f "$CLAUDE_DIR/scripts/check-learnings.sh"
rm -f "$CLAUDE_DIR/scripts/post-commit-reminder.sh"
echo "  ✓ Removed all claude-reflect scripts"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  ✓ Uninstall complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "NOTE: The learnings queue file was preserved at:"
echo "      $CLAUDE_DIR/learnings-queue.json"
echo ""
echo "To fully remove, also delete this file and remove hook"
echo "configuration from ~/.claude/settings.json"
