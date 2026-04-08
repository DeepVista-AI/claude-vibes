#!/bin/bash
# Play a random sound from a category directory + send tab/desktop notifications
# Usage: play-random.sh <category>
#   Categories: done, permission, error
#
# Example: play-random.sh done
#
# Environment variables:
#   CLAUDE_VIBES_DIR       Override install directory (default: ~/.claude/vibes)
#   CLAUDE_VIBES_FLASH     Enable/disable tab flash (default: 1)
#   CLAUDE_VIBES_NOTIFY    Enable/disable macOS notifications (default: 1)
#   CLAUDE_VIBES_PROJECT   Override auto-detected project name

set -euo pipefail

CATEGORY="${1:-done}"
VIBES_DIR="${CLAUDE_VIBES_DIR:-$HOME/.claude/vibes}"
SOUNDS_DIR="$VIBES_DIR/sounds/$CATEGORY"

if [ ! -d "$SOUNDS_DIR" ]; then
  exit 0
fi

files=("$SOUNDS_DIR"/*.mp3)
if [ ${#files[@]} -eq 0 ]; then
  exit 0
fi

# Pick a random file and play it
random_file="${files[$RANDOM % ${#files[@]}]}"
afplay "$random_file" &

# Send tab flash + macOS notification (non-blocking)
NOTIFY_SCRIPT="$VIBES_DIR/scripts/notify.sh"
if [ -x "$NOTIFY_SCRIPT" ]; then
  "$NOTIFY_SCRIPT" "$CATEGORY" &
fi
