#!/bin/bash
# Notification-hook dispatcher for claude-vibes.
#
# Claude Code fires the Notification event both when it needs permission to use
# a tool ("Claude needs your permission to use ...") and when it's been waiting
# on you for a while. There is no separate "PermissionRequest" hook event, so we
# read the notification payload here and branch on the message:
#   - permission prompt  -> a random "permission" voice (+ tab flash / alert)
#   - anything else       -> the glass chime (+ tab flash / alert)
#
# Receives the hook JSON on stdin (per Claude Code command-hook contract).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Read the hook payload and pull out the human-readable message, if any.
input="$(cat 2>/dev/null || true)"
message=""
if [ -n "$input" ] && command -v jq &>/dev/null; then
  message="$(printf '%s' "$input" | jq -r '.message // empty' 2>/dev/null || true)"
fi

case "$(printf '%s' "$message" | tr '[:upper:]' '[:lower:]')" in
  *permission*|*approval*)
    # play-random.sh also fires the tab flash + macOS notification.
    "$SCRIPT_DIR/play-random.sh" permission
    ;;
  *)
    afplay /System/Library/Sounds/Glass.aiff &
    "$SCRIPT_DIR/notify.sh" notification &
    ;;
esac
