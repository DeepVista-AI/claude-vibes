#!/bin/bash
# Play a random sound from a category directory
# Usage: play-random.sh <category>
#   Categories: done, permission, error
#
# Example: play-random.sh done

set -euo pipefail

CATEGORY="${1:-done}"
SOUNDS_DIR="${CLAUDE_VIBES_DIR:-$HOME/.claude/vibes}/sounds/$CATEGORY"

if [ ! -d "$SOUNDS_DIR" ]; then
  exit 0
fi

files=("$SOUNDS_DIR"/*.mp3)
if [ ${#files[@]} -eq 0 ]; then
  exit 0
fi

# Pick a random file
random_file="${files[$RANDOM % ${#files[@]}]}"
afplay "$random_file" &
