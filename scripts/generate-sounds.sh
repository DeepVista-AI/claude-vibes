#!/bin/bash
# Generate all sound effects using OpenAI TTS
# Usage: generate-sounds.sh [voice]
# Requires: OPENAI_API_KEY, uv (or pip install openai)
#
# Voices: alloy, echo, fable, nova, onyx, shimmer
# Default: fable (British male)

set -euo pipefail

VOICE="${1:-fable}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOUNDS_DIR="$SCRIPT_DIR/../sounds"

echo "Generating sounds with voice: $VOICE"
echo ""

generate() {
  local category="$1"
  local name="$2"
  local text="$3"
  local path="$SOUNDS_DIR/$category/${name}.mp3"

  mkdir -p "$SOUNDS_DIR/$category"
  printf "  %-22s %s\n" "$name" "$text"

  if command -v uv &>/dev/null; then
    uv tool run --from openai python3 -c "
from openai import OpenAI
OpenAI().audio.speech.create(model='tts-1', voice='$VOICE', input=\"\"\"$text\"\"\").write_to_file('$path')
" 2>/dev/null
  else
    python3 -c "
from openai import OpenAI
OpenAI().audio.speech.create(model='tts-1', voice='$VOICE', input=\"\"\"$text\"\"\").write_to_file('$path')
"
  fi
}

echo "Task Complete:"
generate done done_boss        "All done, boss."
generate done done_mission     "Mission accomplished."
generate done done_easy        "Too easy. Next challenge please."
generate done done_chef        "Chef's kiss. It is done."
generate done done_magic       "And just like magic... it works."
generate done done_ship        "Ship it. We are golden."
generate done done_nailed      "Nailed it. You are welcome."
generate done done_mic         "Mic drop. Task complete."
generate done done_tea         "Done and dusted. Fancy a tea?"
generate done done_legend      "Finished. You absolute legend."
generate done done_brilliant   "Brilliant. All sorted."
generate done done_piece_of_cake "Piece of cake."
generate done done_butler      "Your task has been attended to, sir."
generate done done_boom        "Boom. Done."
generate done done_smooth      "Smooth as butter. All finished."

echo ""
echo "Permission Needed:"
generate permission perm_excuse  "Excuse me, may I?"
generate permission perm_boss    "Boss, I need your approval."
generate permission perm_knock   "Knock knock. Permission please."
generate permission perm_pretty  "Pretty please?"
generate permission perm_pardon  "Pardon the interruption. I need a green light."
generate permission perm_ahem    "Ahem. Quick approval needed."

echo ""
echo "Errors:"
generate error error_oops       "Oops. We have a situation."
generate error error_awkward     "Well, this is awkward."
generate error error_tea         "Houston, we have a problem. Time for tea."
generate error error_plot_twist  "Plot twist. Something went wrong."
generate error error_not_ideal   "Not ideal. We hit a snag."

echo ""
echo "Done! Generated sounds in: $SOUNDS_DIR"
