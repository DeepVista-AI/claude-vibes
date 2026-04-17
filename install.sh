#!/bin/bash
# Install claude-vibes: copy sounds and configure Claude Code hooks
#
# Usage:
#   ./install.sh          # Install with default settings
#   ./install.sh --dry    # Preview what would be done without changing anything

set -euo pipefail

INSTALL_DIR="$HOME/.claude/vibes"
SETTINGS_FILE="$HOME/.claude/settings.json"
DRY_RUN=false

if [[ "${1:-}" == "--dry" ]]; then
  DRY_RUN=true
fi

# If sounds dir doesn't exist next to this script, we're running via curl — clone first
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
if [ ! -d "$SCRIPT_DIR/sounds" ]; then
  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' EXIT
  echo -e "${BOLD:-}  Downloading claude-vibes...${NC:-}"
  git clone --depth 1 https://github.com/DeepVista-AI/claude-vibes.git "$TMPDIR/claude-vibes" 2>/dev/null
  SCRIPT_DIR="$TMPDIR/claude-vibes"
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
step()  { echo -e "${CYAN}[>]${NC} $*"; }
title() { echo -e "\n${BOLD}$*${NC}"; }

echo ""
echo -e "${BOLD}  claude-vibes${NC} installer"
echo -e "  Give your Claude Code a voice"
echo ""

# ------------------------------------------------------------------
# Step 1: Copy sounds
# ------------------------------------------------------------------
title "Step 1: Installing sounds"

if [ "$DRY_RUN" = true ]; then
  info "Would copy sounds to $INSTALL_DIR"
else
  mkdir -p "$INSTALL_DIR"
  cp -r "$SCRIPT_DIR/sounds" "$INSTALL_DIR/"
  cp -r "$SCRIPT_DIR/scripts" "$INSTALL_DIR/"
  chmod +x "$INSTALL_DIR/scripts/"*.sh
  info "Sounds installed to $INSTALL_DIR"

  # Count sounds
  done_count=$(ls "$INSTALL_DIR/sounds/done/"*.mp3 2>/dev/null | wc -l | tr -d ' ')
  perm_count=$(ls "$INSTALL_DIR/sounds/permission/"*.mp3 2>/dev/null | wc -l | tr -d ' ')
  error_count=$(ls "$INSTALL_DIR/sounds/error/"*.mp3 2>/dev/null | wc -l | tr -d ' ')
  info "  $done_count completion sounds"
  info "  $perm_count permission sounds"
  info "  $error_count error sounds"
fi

# ------------------------------------------------------------------
# Step 1.5: Optional terminal-notifier for click-to-focus notifications
# ------------------------------------------------------------------
title "Step 2: Checking notification dependencies"

if command -v terminal-notifier &>/dev/null; then
  info "terminal-notifier found — click a notification to focus your terminal"
else
  warn "terminal-notifier not installed."
  warn "Without it, clicking a macOS notification opens Script Editor instead of your terminal."
  if command -v brew &>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
      info "Would prompt: brew install terminal-notifier"
    else
      printf "  Install terminal-notifier via Homebrew now? [Y/n] "
      read -r reply </dev/tty || reply="n"
      case "$reply" in
        ""|y|Y|yes|YES)
          brew install terminal-notifier && info "terminal-notifier installed" \
            || warn "Install failed — falling back to osascript notifications"
          ;;
        *)
          warn "Skipped. Install later with: brew install terminal-notifier"
          ;;
      esac
    fi
  else
    warn "Homebrew not found. Install manually:"
    warn "  brew install terminal-notifier"
    warn "  (or: https://github.com/julienXX/terminal-notifier)"
  fi
fi

# ------------------------------------------------------------------
# Step 3: Configure Claude Code hooks
# ------------------------------------------------------------------
title "Step 3: Configuring Claude Code hooks"

PLAY_SCRIPT="$INSTALL_DIR/scripts/play-random.sh"
NOTIFY_SCRIPT="$INSTALL_DIR/scripts/notify.sh"

HOOKS_JSON=$(cat <<HOOKEOF
{
  "Stop": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "$PLAY_SCRIPT done"
        }
      ]
    }
  ],
  "PermissionRequest": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "$PLAY_SCRIPT permission"
        }
      ]
    }
  ],
  "Notification": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "afplay /System/Library/Sounds/Glass.aiff & $NOTIFY_SCRIPT notification &"
        }
      ]
    }
  ]
}
HOOKEOF
)

if [ "$DRY_RUN" = true ]; then
  info "Would add hooks to $SETTINGS_FILE:"
  echo "$HOOKS_JSON" | head -20
  echo "  ..."
else
  mkdir -p "$(dirname "$SETTINGS_FILE")"

  if [ -f "$SETTINGS_FILE" ]; then
    # Merge hooks into existing settings using python
    python3 -c "
import json, sys

settings_path = '$SETTINGS_FILE'
with open(settings_path) as f:
    settings = json.load(f)

hooks = json.loads('''$HOOKS_JSON''')
settings['hooks'] = hooks

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')

print('Hooks merged into existing settings.')
"
    info "Hooks added to $SETTINGS_FILE"
  else
    echo "{\"hooks\": $HOOKS_JSON}" | python3 -m json.tool > "$SETTINGS_FILE"
    info "Created $SETTINGS_FILE with hooks"
  fi
fi

# ------------------------------------------------------------------
# Done
# ------------------------------------------------------------------
title "Installation complete!"
echo ""
info "Your Claude Code will now:"
echo "    - Play a random voice when a task is done"
echo "    - Play a random voice when permission is needed"
echo "    - Chime on notifications"
echo "    - Flash the terminal tab when attention is needed"
echo "    - Send macOS notifications with project name"
echo ""
step "Preview all sounds:  $INSTALL_DIR/scripts/preview.sh"
step "Live TTS:            $INSTALL_DIR/scripts/live-speak.sh \"Your message\""
step "Regenerate sounds:   $INSTALL_DIR/scripts/generate-sounds.sh [voice]"
echo ""
info "Restart Claude Code to activate hooks. Enjoy the vibes!"
echo ""
