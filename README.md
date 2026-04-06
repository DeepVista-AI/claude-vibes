# claude-vibes

Give your [Claude Code](https://docs.anthropic.com/en/docs/claude-code) a voice. Random witty British notifications when tasks finish, permissions are needed, or things go wrong.

> *"Mic drop. Task complete."*
> *"Knock knock. Permission please."*
> *"Plot twist. Something went wrong."*

## What it does

**claude-vibes** hooks into Claude Code's event system and plays short voice notifications:

| Event | What happens |
|-------|-------------|
| **Task complete** | Random celebration: *"Ship it. We are golden."*, *"Done and dusted. Fancy a tea?"*, *"Piece of cake."* |
| **Permission needed** | Polite nudge: *"Pretty please?"*, *"Boss, I need your approval."*, *"Ahem. Quick approval needed."* |
| **Error** | Cheeky alert: *"Well, this is awkward."*, *"Houston, we have a problem."* |
| **Notification** | Clean glass chime (macOS system sound) |

Sounds are pre-generated with OpenAI TTS (fable voice -- British male). A random sound plays each time, so it never gets repetitive.

## Quick start

One command:

```bash
curl -fsSL https://deepvista-ai.github.io/claude-vibes/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/DeepVista-AI/claude-vibes.git
cd claude-vibes
./install.sh
```

Restart Claude Code. That's it.

## What's in the box

```
claude-vibes/
  sounds/
    done/          # 15 task completion sounds
    permission/    #  6 permission request sounds
    error/         #  5 error notification sounds
  scripts/
    play-random.sh       # Pick and play a random sound from a category
    live-speak.sh        # Live-generate any phrase with OpenAI TTS
    generate-sounds.sh   # Regenerate all sounds (change voice, add phrases)
    preview.sh           # Listen to all sounds
  install.sh             # One-command setup
  uninstall.sh           # Clean removal
```

## Preview sounds

```bash
# Listen to all sounds
./scripts/preview.sh

# Listen to one category
./scripts/preview.sh done
./scripts/preview.sh permission
./scripts/preview.sh error
```

## Customize

### Change the voice

Regenerate all sounds with a different OpenAI TTS voice:

```bash
# Voices: alloy, echo, fable, nova, onyx, shimmer
./scripts/generate-sounds.sh nova
```

> Requires `OPENAI_API_KEY` and either `uv` or `pip install openai`.

### Add your own phrases

Edit `scripts/generate-sounds.sh` and add lines:

```bash
generate done done_coffee "Coffee break earned. Task complete."
generate permission perm_hey "Hey, quick question for you."
```

Then run `./scripts/generate-sounds.sh` to regenerate.

### Live TTS

Generate any phrase on the fly:

```bash
./scripts/live-speak.sh "Deploy successful. Time for champagne."
```

Set a custom voice:

```bash
CLAUDE_VIBES_VOICE=nova ./scripts/live-speak.sh "All systems go."
```

### Use macOS system voices instead

Don't want to use OpenAI? Replace the hook commands in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "say -v 'Serena (Premium)' 'All done, boss' &"
          }
        ]
      }
    ]
  }
}
```

Download premium voices in **System Settings > Accessibility > Spoken Content > System Voice > Manage Voices** for better quality.

## How it works

Claude Code supports [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) -- shell commands that run on events like `Stop` (task finished), `PermissionRequest`, and `Notification`.

claude-vibes installs a `play-random.sh` script that picks a random `.mp3` from the appropriate category folder and plays it with `afplay` (built into macOS).

The hook configuration goes into `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/vibes/scripts/play-random.sh done"
          }
        ]
      }
    ],
    "PermissionRequest": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/vibes/scripts/play-random.sh permission"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Glass.aiff &"
          }
        ]
      }
    ]
  }
}
```

## Uninstall

```bash
./uninstall.sh
```

Removes `~/.claude/vibes/` and cleans hooks from `~/.claude/settings.json`.

## Requirements

- macOS (uses `afplay` for audio playback)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- For regenerating sounds: `OPENAI_API_KEY` + `uv` or `pip install openai`

## Sound credits

Pre-generated with [OpenAI TTS](https://platform.openai.com/docs/guides/text-to-speech) (fable voice). Sounds are included in the repo so no API key is needed for installation.

## License

MIT
