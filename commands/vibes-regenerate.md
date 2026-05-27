---
description: Regenerate all claude-vibes sounds with OpenAI TTS (optionally a different voice)
argument-hint: "[alloy|echo|fable|nova|onyx|shimmer]"
allowed-tools: Bash
---

Regenerate every claude-vibes sound file using OpenAI TTS. An optional argument
picks the voice (default `fable`, a British male voice).

Run (defaults to `fable` when no argument is given):

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/generate-sounds.sh" $ARGUMENTS
```

This requires `OPENAI_API_KEY` to be set and either `uv` or the `openai` Python
package installed, and it overwrites the existing `.mp3` files in the plugin's
`sounds/` directory. If a dependency or the API key is missing, tell the user
what to set up and stop without regenerating.
