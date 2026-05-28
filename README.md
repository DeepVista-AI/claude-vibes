# claude-vibes

Give your [Claude Code](https://docs.claude.com/en/docs/claude-code) a voice. Random witty British notifications when tasks finish or when Claude needs your attention.

> *"Mic drop. Task complete."*
> *"Knock knock. Permission please."*

## What it does

**claude-vibes** hooks into Claude Code's event system and plays short voice notifications:

| Event | What happens |
|-------|-------------|
| **Task complete** (`Stop` hook) | Random celebration: *"Ship it. We are golden."*, *"Done and dusted. Fancy a tea?"*, *"Piece of cake."* |
| **Permission needed** (`Notification` hook, permission branch) | Polite nudge: *"Pretty please?"*, *"Boss, I need your approval."*, *"Ahem. Quick approval needed."* |
| **Other notification** (`Notification` hook, default branch) | Clean glass chime (macOS system sound) — e.g. when Claude has been waiting idle for input |

> Five "error" sound clips ship in `sounds/error/` and are listenable via `/vibes-preview error`, but Claude Code has no native "error" event today, so they aren't auto-triggered.

Every event also **flashes your terminal tab** and sends a **macOS notification with the project name**, so you always know which Claude Code instance needs attention.

Sounds are pre-generated with OpenAI TTS (fable voice -- British male). A random sound plays each time, so it never gets repetitive.

## Quick start

claude-vibes is a [Claude Code plugin](https://docs.claude.com/en/docs/claude-code/plugins). Install it with two commands:

```bash
claude plugin marketplace add DeepVista-AI/claude-vibes
claude plugin install claude-vibes@deepvista
```

Or from inside Claude Code, run `/plugin`, add the `DeepVista-AI/claude-vibes` marketplace, and install **claude-vibes** from the menu.

That's it — the hooks activate immediately. No files are copied into `~/.claude` and no settings are edited; everything runs from the installed plugin directory.

## What's in the box

```
claude-vibes/
  .claude-plugin/
    plugin.json          # Plugin manifest
    marketplace.json     # Marketplace entry (so `claude plugin install` works)
  hooks/
    hooks.json           # Wires sounds + notifications to Claude Code events
  commands/
    vibes-preview.md     # /vibes-preview  — listen to all sounds
    vibes-speak.md       # /vibes-speak    — live TTS of any phrase
    vibes-regenerate.md  # /vibes-regenerate — rebuild sounds (change voice)
  sounds/
    done/                # 15 task completion sounds
    permission/          #  6 permission request sounds
    error/               #  5 error notification sounds
  scripts/
    play-random.sh       # Pick and play a random sound from a category
    notify.sh            # Tab flash + macOS notification with project context
    live-speak.sh        # Live-generate any phrase with OpenAI TTS
    generate-sounds.sh   # Regenerate all sounds (change voice, add phrases)
    preview.sh           # Listen to all sounds
```

## Slash commands

The plugin adds three commands inside Claude Code:

| Command | What it does |
|---------|-------------|
| `/vibes-preview [done\|permission\|error]` | Play the sounds so you can hear them (defaults to all) |
| `/vibes-speak <message>` | Speak any phrase live with OpenAI TTS |
| `/vibes-regenerate [voice]` | Rebuild every sound with a chosen TTS voice |

`/vibes-speak` and `/vibes-regenerate` require `OPENAI_API_KEY` and either `uv` or `pip install openai`.

## Multi-instance support

Running Claude Code in multiple terminal tabs? claude-vibes has you covered:

- **Tab flash** -- the tab flashes/badges when Claude needs attention (BEL character, works in iTerm2, Warp, Terminal.app)
- **macOS notification** -- shows the project name and event type in Notification Center, even when the terminal isn't focused
- **iTerm2 extras** -- native OSC 9 notification + dock bounce via `RequestAttention`

The project name is auto-detected from your git repo. Override it with:

```bash
export CLAUDE_VIBES_PROJECT="my-api"
```

Disable specific features:

```bash
export CLAUDE_VIBES_FLASH=0    # No tab flash
export CLAUDE_VIBES_NOTIFY=0   # No macOS notifications
```

## Customize

### Change the voice

Regenerate all sounds with a different OpenAI TTS voice — from inside Claude Code:

```
/vibes-regenerate nova
```

> Voices: alloy, echo, fable, nova, onyx, shimmer. Requires `OPENAI_API_KEY` and either `uv` or `pip install openai`.

### Add your own phrases

The sound list lives in `scripts/generate-sounds.sh`. Add lines:

```bash
generate done done_coffee "Coffee break earned. Task complete."
generate permission perm_hey "Hey, quick question for you."
```

Then run `/vibes-regenerate` to rebuild the `.mp3` files.

### Live TTS

Speak any phrase on the fly:

```
/vibes-speak Deploy successful. Time for champagne.
```

### Use macOS system voices instead

Don't want to use OpenAI? Override the plugin hooks in your `~/.claude/settings.json` (user hooks merge with plugin hooks):

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

Claude Code supports [hooks](https://docs.claude.com/en/docs/claude-code/hooks) -- shell commands that run on events like `Stop` (task finished) and `Notification`. As a [plugin](https://docs.claude.com/en/docs/claude-code/plugins), claude-vibes ships its hooks in `hooks/hooks.json` and Claude Code registers them automatically when the plugin is enabled — nothing is written to your `settings.json`.

`play-random.sh` picks a random `.mp3` from the matching category folder and plays it with `afplay` (built into macOS). `${CLAUDE_PLUGIN_ROOT}` resolves to wherever the plugin is installed, so the paths stay portable:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/play-random.sh done"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/on-notification.sh"
          }
        ]
      }
    ]
  }
}
```

Claude Code has no dedicated "permission" hook event — permission prompts arrive through `Notification`. So `on-notification.sh` reads the notification message and branches: a permission prompt plays a random *permission* voice, anything else plays the glass chime. Both flash the terminal tab and post a macOS notification with the project name.

## Uninstall

```bash
claude plugin uninstall claude-vibes@deepvista
```

Or run `/plugin` inside Claude Code and disable/uninstall it from the menu. Since the plugin never touches `~/.claude/settings.json`, removing it leaves no trace.

## Requirements

- macOS (uses `afplay` for audio playback)
- [Claude Code](https://docs.claude.com/en/docs/claude-code) CLI
- For regenerating sounds: `OPENAI_API_KEY` + `uv` or `pip install openai`

## Sound credits

Pre-generated with [OpenAI TTS](https://platform.openai.com/docs/guides/text-to-speech) (fable voice). Sounds are included in the repo so no API key is needed for installation.

## License

MIT
