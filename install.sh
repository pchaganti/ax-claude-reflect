#!/bin/bash
# claude-reflect installer
# Self-learning system for Claude Code that captures corrections and updates CLAUDE.md

set -e

CLAUDE_DIR="$HOME/.claude"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "═══════════════════════════════════════════════════════════"
echo "  Installing claude-reflect"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Create directories if needed
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/scripts"

# Copy commands
echo "→ Installing commands..."
cp "$REPO_DIR/commands/"*.md "$CLAUDE_DIR/commands/"
echo "  ✓ /reflect, /skip-reflect, /view-queue"

# Copy scripts and make executable
echo "→ Installing scripts..."
cp "$REPO_DIR/scripts/"*.sh "$CLAUDE_DIR/scripts/"
chmod +x "$CLAUDE_DIR/scripts/"*.sh
echo "  ✓ capture-learning.sh, extract-*.sh, check-learnings.sh"

# Initialize empty queue if it doesn't exist
if [ ! -f "$CLAUDE_DIR/learnings-queue.json" ]; then
    echo "[]" > "$CLAUDE_DIR/learnings-queue.json"
    echo "→ Created empty learnings queue"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  ✓ Installation complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. Configure hooks in Claude Code settings (~/.claude/settings.json):"
echo ""
echo '   "hooks": {'
echo '     "UserPromptSubmit": ['
echo '       {"matcher": "", "hooks": ["~/.claude/scripts/capture-learning.sh"]}'
echo '     ],'
echo '     "PreCompact": ['
echo '       {"matcher": "", "hooks": ["~/.claude/scripts/check-learnings.sh"]}'
echo '     ]'
echo '   }'
echo ""
echo "2. Restart Claude Code to pick up new commands"
echo ""
echo "3. Use the commands:"
echo "   /reflect              - Process learnings queue"
echo "   /reflect --scan-history  - Scan past sessions for missed learnings"
echo "   /skip-reflect         - Discard queued learnings"
echo "   /view-queue           - View pending learnings"
echo ""
echo "For more info: https://github.com/bayramannakov/claude-reflect"
