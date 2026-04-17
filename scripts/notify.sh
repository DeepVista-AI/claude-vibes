#!/bin/bash
# Terminal tab flash and macOS notification for multi-instance workflows
# Usage: notify.sh <category> [project_name]
#   Categories: done, permission, error, notification
#
# Sends visual attention signals so you know WHICH tab needs you:
#   - BEL character (flashes tab in iTerm2, Warp, Terminal.app)
#   - iTerm2 native notification (OSC 9)
#   - iTerm2 attention request (OSC 1337)
#   - macOS Notification Center alert (osascript)
#
# Environment variables:
#   CLAUDE_VIBES_FLASH=0       Disable tab flash (default: 1)
#   CLAUDE_VIBES_NOTIFY=0      Disable macOS notifications (default: 1)
#   CLAUDE_VIBES_PROJECT=name  Override auto-detected project name

set -euo pipefail

CATEGORY="${1:-done}"
PROJECT="${CLAUDE_VIBES_PROJECT:-}"
FLASH="${CLAUDE_VIBES_FLASH:-1}"
NOTIFY="${CLAUDE_VIBES_NOTIFY:-1}"

# --- Detect project name ---------------------------------------------------

detect_project() {
  # 1. Explicit override
  if [ -n "$PROJECT" ]; then
    echo "$PROJECT"
    return
  fi

  # 2. Try git repo root basename (most meaningful)
  if command -v git &>/dev/null; then
    local git_root
    git_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    if [ -n "$git_root" ]; then
      basename "$git_root"
      return
    fi
  fi

  # 3. Fall back to current directory name
  basename "$PWD"
}

PROJECT_NAME="$(detect_project)"

# --- Human-readable labels -------------------------------------------------

label_for_category() {
  case "$1" in
    done)         echo "Task complete" ;;
    permission)   echo "Permission needed" ;;
    error)        echo "Error" ;;
    notification) echo "Notification" ;;
    *)            echo "$1" ;;
  esac
}

EVENT_LABEL="$(label_for_category "$CATEGORY")"
MESSAGE="${PROJECT_NAME}: ${EVENT_LABEL}"

# --- Tab flash (BEL + escape sequences) ------------------------------------

flash_tab() {
  [ "$FLASH" = "0" ] && return

  # BEL character — universally supported, makes the tab flash/badge
  printf '\a'

  # Terminal-specific sequences
  case "${TERM_PROGRAM:-}" in
    iTerm.app|iTerm2)
      # iTerm2: OSC 9 sends a Growl/Notification Center message
      printf '\e]9;%s\a' "$MESSAGE"
      # iTerm2: request attention (bounces dock icon, flashes tab)
      printf '\e]1337;RequestAttention=once\a'
      ;;
    WarpTerminal)
      # Warp responds to BEL (already sent above)
      # Warp also supports OSC 9 for notifications
      printf '\e]9;%s\a' "$MESSAGE"
      ;;
    Apple_Terminal)
      # Terminal.app responds to BEL (already sent above)
      ;;
  esac
}

# --- macOS Notification Center ----------------------------------------------

# Map TERM_PROGRAM to macOS bundle id so click-to-focus routes to the terminal
# instead of Script Editor (osascript's default notification host).
terminal_bundle_id() {
  case "${TERM_PROGRAM:-}" in
    iTerm.app|iTerm2) echo "com.googlecode.iterm2" ;;
    WarpTerminal)     echo "dev.warp.Warp-Stable" ;;
    Apple_Terminal)   echo "com.apple.Terminal" ;;
    ghostty)          echo "com.mitchellh.ghostty" ;;
    vscode)           echo "com.microsoft.VSCode" ;;
    *)                echo "" ;;
  esac
}

send_macos_notification() {
  [ "$NOTIFY" = "0" ] && return

  local sender
  sender="$(terminal_bundle_id)"

  # Prefer terminal-notifier: click focuses the terminal (not Script Editor).
  if command -v terminal-notifier &>/dev/null; then
    terminal-notifier \
      -title "claude-vibes" \
      -subtitle "$PROJECT_NAME" \
      -message "$EVENT_LABEL" \
      ${sender:+-sender "$sender"} \
      >/dev/null 2>&1 &
    return
  fi

  # Fallback: osascript. Click opens Script Editor — install terminal-notifier
  # to fix (brew install terminal-notifier).
  if command -v osascript &>/dev/null; then
    osascript -e "display notification \"${EVENT_LABEL}\" with title \"claude-vibes\" subtitle \"${PROJECT_NAME}\"" &>/dev/null &
  fi
}

# --- Fire notifications -----------------------------------------------------

flash_tab
send_macos_notification
