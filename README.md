# Goose Honk Plugin for Claude Code

Honk like a goose when Claude Code is waiting for your input.

## Installation

### From GitHub

```bash
# Add the plugin marketplace (if not already added)
/plugin marketplace add ssubbotin/claude-honk

# Install the plugin
/plugin install claude-honk
```

> **Note:** After installing, you must restart Claude Code for the plugin to take effect. Plugins are loaded at session startup and cannot be hot-reloaded (yet).

### Local Installation (for development)

```bash
claude --plugin-dir /path/to/claude-honk
```

## Configuration

### Volume

Default volume is **50%**. To change it, create `~/.config/claude-honk/config`:

```sh
mkdir -p ~/.config/claude-honk
echo 'CLAUDE_HONK_VOLUME=30' > ~/.config/claude-honk/config
```

Valid range is `0`–`100`. The file is re-read on every honk, so edits take effect immediately — no Claude Code restart needed. You can also set `CLAUDE_HONK_VOLUME` directly in your shell environment; it overrides the config file.

> Volume control works on Linux (`ffplay`, `paplay`) and macOS (`afplay`). It is **ignored on WSL** — adjust system volume instead.

### Events

By default, the plugin honks on **all notifications**, permission requests, and task completion. To customize, edit `hooks/hooks.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "idle_prompt",
        "hooks": [...]
      }
    ]
  }
}
```

Available matchers:
- `""` - All notifications (default)
- `idle_prompt` - Only when waiting for user input (60+ seconds idle)
- `permission_prompt` - Only on permission requests

## Supported Platforms

- **Linux**: Uses `paplay` (PulseAudio) or `ffplay`
- **macOS**: Uses `afplay`
- **WSL**: Uses PowerShell's Media.SoundPlayer

## Sound Attribution

Goose honk sound from [Orange Free Sounds](https://orangefreesounds.com/goose-honk-sound-effect/) under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/).

## License

MIT
