#!/bin/bash
# Live-generate a voice notification using OpenAI TTS (fable voice)
# Usage: live-speak.sh "Your message here"
# Requires: OPENAI_API_KEY environment variable, uv (or pip install openai)
#
# Example: live-speak.sh "Deploy successful. Time for coffee."

set -euo pipefail

MESSAGE="${1:-All done.}"
VOICE="${CLAUDE_VIBES_VOICE:-fable}"
TMPFILE="/tmp/claude_vibes_$$_$(date +%s).mp3"

cleanup() { rm -f "$TMPFILE"; }
trap cleanup EXIT

if command -v uv &>/dev/null; then
  uv tool run --from openai python3 -c "
from openai import OpenAI
OpenAI().audio.speech.create(model='tts-1', voice='$VOICE', input=\"\"\"$MESSAGE\"\"\").write_to_file('$TMPFILE')
" 2>/dev/null
elif python3 -c "import openai" 2>/dev/null; then
  python3 -c "
from openai import OpenAI
OpenAI().audio.speech.create(model='tts-1', voice='$VOICE', input=\"\"\"$MESSAGE\"\"\").write_to_file('$TMPFILE')
"
else
  echo "Error: Install openai (pip install openai) or uv" >&2
  exit 1
fi

afplay "$TMPFILE"
