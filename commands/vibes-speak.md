---
description: Speak a phrase out loud with OpenAI TTS (live, on the fly)
argument-hint: "<message to speak>"
allowed-tools: Bash
---

Generate and play a live text-to-speech notification using the claude-vibes
live-speak script. The phrase to speak is: **$ARGUMENTS**

Run:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/live-speak.sh" "$ARGUMENTS"
```

This requires `OPENAI_API_KEY` to be set and either `uv` or the `openai` Python
package installed. If the command reports a missing dependency or API key, tell
the user exactly what to install or export, then stop.
