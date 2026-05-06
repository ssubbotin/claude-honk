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

Default volume is **50%**. The fastest way to change it is the slash command:

```
/claude-honk:volume 30
```

Or run `/claude-honk:volume` with no argument to pick from a list. Either way, it writes `CLAUDE_HONK_VOLUME` to the config file and plays a test honk at the new level.

You can also edit the file directly. The path is `~/.config/claude-honk/config` on Linux/macOS:

```sh
mkdir -p ~/.config/claude-honk
echo 'CLAUDE_HONK_VOLUME=30' > ~/.config/claude-honk/config
```

…and `%USERPROFILE%\.config\claude-honk\config` on Windows.

Valid range is `0`–`100`. The file is re-read on every honk, so edits take effect immediately — no Claude Code restart needed. Setting `CLAUDE_HONK_VOLUME` in the shell environment overrides the file.

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

- **Linux**: `ffplay` (preferred for MP3) or `paplay`
- **macOS**: `afplay`
- **Windows**: PowerShell + Windows Media Player COM (`WMPlayer.OCX.7`), with full volume control
- **WSL**: same as Linux — install `ffplay` (`sudo apt install ffmpeg`) or `paplay` so the bash hook can play through WSLg/PulseAudio

## Sound Attribution

Goose honk sound from [Orange Free Sounds](https://orangefreesounds.com/goose-honk-sound-effect/) under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/).

## License

MIT
