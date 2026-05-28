---
description: Preview claude-vibes notification sounds (all, or one category)
argument-hint: "[done|permission|error|all]"
allowed-tools: Bash
---

Play the claude-vibes preview script so the user can hear the notification sounds.

Run this command (defaults to `all` when no argument is given):

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/preview.sh" $ARGUMENTS
```

After it finishes, briefly tell the user which category was previewed.
