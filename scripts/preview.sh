#!/bin/bash
# Preview all sounds in a category (or all categories)
# Usage: preview.sh [category]
#   Categories: done, permission, error, all (default: all)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOUNDS_DIR="$SCRIPT_DIR/../sounds"
CATEGORY="${1:-all}"

preview_category() {
  local cat="$1"
  local dir="$SOUNDS_DIR/$cat"

  if [ ! -d "$dir" ]; then
    echo "No sounds in category: $cat"
    return
  fi

  echo ""
  echo "=== $cat ==="
  for f in "$dir"/*.mp3; do
    name=$(basename "$f" .mp3)
    printf "  %-24s " "$name"
    afplay "$f"
    sleep 0.3
  done
}

if [ "$CATEGORY" = "all" ]; then
  for cat in done permission error; do
    preview_category "$cat"
  done
else
  preview_category "$CATEGORY"
fi

echo ""
echo "Done!"
