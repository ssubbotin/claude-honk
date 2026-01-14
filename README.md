# Goose Honk Plugin for Claude Code

Honk like a goose when Claude Code is waiting for your input.

## Installation

### From GitHub

```bash
# Add the plugin marketplace (if not already added)
/plugin marketplace add ssubbotin/claude-honk

# Install the plugin
/plugin install goose-honk
```

### Local Installation (for development)

```bash
claude --plugin-dir /path/to/claude-honk
```

## Configuration

By default, the plugin honks on **all notifications**. To customize, edit `hooks/hooks.json`:

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
