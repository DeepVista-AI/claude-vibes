#!/bin/bash
# Uninstall claude-vibes: remove sounds and hooks
set -euo pipefail

INSTALL_DIR="$HOME/.claude/vibes"
SETTINGS_FILE="$HOME/.claude/settings.json"

GREEN='\033[0;32m'
NC='\033[0m'
info() { echo -e "${GREEN}[+]${NC} $*"; }

echo ""
echo "Uninstalling claude-vibes..."
echo ""

# Remove sounds
if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  info "Removed $INSTALL_DIR"
else
  info "No installation found at $INSTALL_DIR"
fi

# Remove hooks from settings
if [ -f "$SETTINGS_FILE" ]; then
  python3 -c "
import json
with open('$SETTINGS_FILE') as f:
    settings = json.load(f)
if 'hooks' in settings:
    del settings['hooks']
    with open('$SETTINGS_FILE', 'w') as f:
        json.dump(settings, f, indent=2)
        f.write('\n')
    print('Hooks removed from settings.')
else:
    print('No hooks found in settings.')
"
  info "Cleaned up $SETTINGS_FILE"
fi

echo ""
info "claude-vibes uninstalled. Your Claude Code is back to silent mode."
echo ""
