# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Claude Code plugin that plays a goose honk MP3 on three hook events: `Notification`, `PermissionRequest`, and `Stop`. There is no build, no test suite, and no package manager — the entire plugin is a hook manifest plus a shell script.

## Architecture

Three files do all the work; everything else is metadata, license, or assets:

- `.claude-plugin/plugin.json` — plugin manifest. Does **not** declare a `hooks` field: Claude Code auto-loads `hooks/hooks.json` by convention, and listing it in the manifest triggers a "Duplicate hooks file detected" load error. The `manifest.hooks` field is reserved for *additional* hook files only. (See commits `eeeb171` and `1.1.1`; commit `73643ba` re-added the field and had to be undone.)
- `.claude-plugin/marketplace.json` — marketplace descriptor used by `/plugin marketplace add ssubbotin/claude-honk`. Lists this plugin and its git source URL.
- `hooks/hooks.json` — registers the same command (`${CLAUDE_PLUGIN_ROOT}/scripts/play-honk.sh`) under `Notification`, `PermissionRequest`, and `Stop`. Auto-loaded — see the `plugin.json` note above; do not reference this file from the manifest.
- `commands/volume.md` — slash command `/claude-honk:volume [0-100]` for setting `CLAUDE_HONK_VOLUME` in `~/.config/claude-honk/config`. Auto-loaded by Claude Code from `commands/*.md` by convention (same auto-discovery as `hooks/hooks.json` — do **not** add a `commands` entry to `plugin.json`). The command body owns the entire config file; if more settings are ever added there, update the command to preserve them.
- `scripts/play-honk.sh` — picks an audio backend by `command -v` probe. **Order matters and is load-bearing**: `ffplay` is checked first for `.mp3` because `paplay` (PulseAudio) cannot decode MP3 and silently fails. Then `afplay` (macOS), then `paplay`, then `ffplay` again as a generic fallback, then PowerShell's `Media.SoundPlayer` for WSL. Don't reorder without re-testing on Linux — see commit `ac3ac2b`. The script also sources `${XDG_CONFIG_HOME:-$HOME/.config}/claude-honk/config` (if present) and reads `CLAUDE_HONK_VOLUME` (0–100, default 50). Volume is mapped per-backend: `ffplay -volume N` (0-100), `afplay -v N/100` (float), `paplay --volume=N*65536/100` (PulseAudio scale). PowerShell's `Media.SoundPlayer` has no per-play volume control, so the env var is silently ignored on WSL — document this when changing the WSL branch.
- `assets/goose-honk.mp3` — the sound. CC BY-NC 4.0 (non-commercial), so don't relicense the repo permissively without addressing this.

`${CLAUDE_PLUGIN_ROOT}` is injected by Claude Code at hook-execution time; the script uses it to resolve both the sound asset and its own path. Don't hardcode paths.

## Testing changes

There is no automated test harness. To verify a change end-to-end:

1. Run the script directly with the env var set: `CLAUDE_PLUGIN_ROOT="$(pwd)" ./scripts/play-honk.sh` — should honk audibly.
2. For real hook integration, install locally via `claude --plugin-dir /path/to/claude-honk` and trigger one of the three events (e.g., let a session go idle to fire `Notification`, or finish a turn for `Stop`).

Plugins are loaded at session startup and cannot be hot-reloaded — restart Claude Code after editing `hooks.json` or `plugin.json`.

## Documentation drift to watch

`README.md` references matchers `idle_prompt` and `permission_prompt`, but `hooks/hooks.json` uses the hook event names (`Notification`, `PermissionRequest`, `Stop`) with empty matchers. If you change one, reconcile the other.
