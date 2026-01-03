# claude-reflect

A self-learning system for Claude Code that captures your corrections and updates CLAUDE.md automatically.

## What it does

When you correct Claude Code during a session ("no, use gpt-5.1 not gpt-5", "use database for caching"), these corrections are captured and can be added to your CLAUDE.md files so Claude remembers them in future sessions.

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  You correct    │ ──► │  Hook captures  │ ──► │  /reflect adds  │
│  Claude Code    │     │  the learning   │     │  to CLAUDE.md   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Quick Start

```bash
git clone https://github.com/bayramannakov/claude-reflect.git
cd claude-reflect
./install.sh
```

Then configure hooks (see below) and restart Claude Code.

## Commands

| Command | Description |
|---------|-------------|
| `/reflect` | Process queued learnings with human review |
| `/reflect --scan-history` | Scan ALL past sessions for missed learnings |
| `/reflect --dry-run` | Preview changes without applying |
| `/skip-reflect` | Discard all queued learnings |
| `/view-queue` | View pending learnings without processing |

## How It Works

### 1. Real-time Capture

A hook runs on every prompt, detecting correction patterns like:
- "use X not Y"
- "don't use Z"
- "actually, the API returns..."
- "remember: always do X"

### 2. Queue Accumulation

Detected corrections are stored in `~/.claude/learnings-queue.json`.

### 3. Human Review

When you run `/reflect`, Claude presents a summary table:

```
════════════════════════════════════════════════════════════
LEARNINGS SUMMARY — 5 items found
════════════════════════════════════════════════════════════

┌────┬─────────────────────────────────────────┬──────────┬────────┐
│ #  │ Learning                                │ Scope    │ Status │
├────┼─────────────────────────────────────────┼──────────┼────────┤
│ 1  │ Use gpt-5.1 for reasoning tasks         │ global   │ ✓ new  │
│ 2  │ Database for persistent storage         │ project  │ ✓ new  │
└────┴─────────────────────────────────────────┴──────────┴────────┘
```

You choose:
- **Apply all** - Accept recommended changes
- **Select which** - Pick specific learnings
- **Review details** - See full context before deciding

### 4. CLAUDE.md Updates

Approved learnings are added to:
- `~/.claude/CLAUDE.md` (global - applies to all projects)
- `./CLAUDE.md` (project-specific)

## Installation

### Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed
- `jq` for JSON processing (`brew install jq` on macOS)

### Install

```bash
git clone https://github.com/bayramannakov/claude-reflect.git
cd claude-reflect
./install.sh
```

### Configure Hooks

Add to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": ["~/.claude/scripts/capture-learning.sh"]
      }
    ],
    "PreCompact": [
      {
        "matcher": "",
        "hooks": ["~/.claude/scripts/check-learnings.sh"]
      }
    ]
  }
}
```

### Restart Claude Code

```bash
# Exit current session
/exit

# Start a new session
claude
```

## Uninstall

```bash
cd claude-reflect
./uninstall.sh
```

Then remove the hooks from `~/.claude/settings.json`.

## File Structure

```
~/.claude/
├── commands/
│   ├── reflect.md          # Main command
│   ├── skip-reflect.md     # Discard queue
│   └── view-queue.md       # View queue
├── scripts/
│   ├── capture-learning.sh       # Hook: detect corrections
│   ├── extract-session-learnings.sh
│   ├── extract-tool-rejections.sh
│   ├── check-learnings.sh        # Hook: pre-compact check
│   └── post-commit-reminder.sh
└── learnings-queue.json    # Pending learnings
```

## Features

### Correction Detection Patterns

The capture hook detects:
- `"no, use X"` / `"don't use Y"`
- `"actually..."` / `"I meant..."`
- `"use X not Y"` / `"X instead of Y"`
- `"remember:"` (explicit learning marker)
- Tool rejections (highest confidence)

### Historical Scan

First time using claude-reflect? Run:

```bash
/reflect --scan-history
```

This scans all your past sessions for corrections you made, so you don't lose learnings from before installation.

### Smart Filtering

Claude filters out:
- Questions (not corrections)
- One-time task instructions
- Context-specific requests
- Vague/non-actionable feedback

Only reusable learnings are kept.

### Duplicate Detection

Before adding a learning, existing CLAUDE.md content is checked. If similar content exists, you can:
- Merge with existing entry
- Replace the old entry
- Skip the duplicate

## Tips

1. **Use explicit markers** for important learnings:
   ```
   remember: always use venv for Python projects
   ```

2. **Run /reflect regularly** - Weekly is a good cadence

3. **Historical scan on new machines** - When setting up a new dev environment:
   ```
   /reflect --scan-history --days 90
   ```

4. **Project vs Global** - Model names and general patterns go global; project-specific conventions stay in project CLAUDE.md

## Contributing

Pull requests welcome! Please read the contributing guidelines first.

## License

MIT
