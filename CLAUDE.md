# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Claude Code plugin that plays a goose honk MP3 on three hook events: `Notification`, `PermissionRequest`, and `Stop`. There is no build, no test suite, and no package manager — the entire plugin is a hook manifest plus two thin player scripts (one bash, one PowerShell).

## Architecture

- `.claude-plugin/plugin.json` — plugin manifest. Does **not** declare a `hooks` field: Claude Code auto-loads `hooks/hooks.json` by convention, and listing it in the manifest triggers a "Duplicate hooks file detected" load error. The `manifest.hooks` field is reserved for *additional* hook files only. (See commits `eeeb171` and `1.1.1`; commit `73643ba` re-added the field and had to be undone.)
- `.claude-plugin/marketplace.json` — marketplace descriptor used by `/plugin marketplace add ssubbotin/claude-honk`. Lists this plugin and its git source URL.
- `hooks/hooks.json` — registers **two** commands per event (`Notification`, `PermissionRequest`, `Stop`): one invokes `bash play-honk.sh`, the other `powershell.exe -File play-honk.ps1`. `hooks.json` has no per-OS routing. Claude Code runs each `command` string through a shell (`sh` on Unix; Git Bash on Windows, or Windows PowerShell 5.1 if Git Bash is absent), so on each OS the entry whose interpreter is missing fails with command-not-found. **Every command ends with `; exit 0`** so that failure becomes a clean exit-0 no-op: as of recent Claude Code versions a non-zero hook exit (e.g. `sh` returning 127 for a missing `powershell.exe`) is surfaced as a `Stop hook error: Failed with non-blocking status code: …` notice. `; exit 0` is the only guard valid in all three shells — POSIX `command -v`/`&&`/`||` are syntax errors in PowerShell 5.1, so they can't be used here. On WSL both interpreters exist, so `play-honk.ps1` self-bails when `WSL_DISTRO_NAME`/`WSLENV` is set, leaving the bash script in charge. Auto-loaded — do not reference from the manifest.
- `commands/volume.md` — slash command `/claude-honk:volume [0-100]` for writing `CLAUDE_HONK_VOLUME` to `~/.config/claude-honk/config` (Linux/macOS) or `%USERPROFILE%\.config\claude-honk\config` (Windows). Auto-loaded by Claude Code from `commands/*.md` by convention (same auto-discovery as `hooks/hooks.json` — do **not** add a `commands` entry to `plugin.json`). The command body owns the entire config file; if more settings are ever added, update the command to preserve them. `AskUserQuestion` is multiple-choice only, no free-form input — that's why the picker is a numeric ladder rather than a "Custom" prompt.
- `scripts/play-honk.sh` — bash player for Linux, macOS, WSL. Picks an audio backend by `command -v` probe. **Order is load-bearing**: `ffplay` is checked first for `.mp3` because `paplay` (PulseAudio) cannot decode MP3 and silently fails (commit `ac3ac2b`). Then `afplay` (macOS), `paplay`, `ffplay` fallback. The legacy `powershell.exe Media.SoundPlayer` WSL fallback was dropped in 1.3.0 — `SoundPlayer` is WAV-only, so it never actually played our MP3. WSL users now need `ffplay`/`paplay` installed inside the distro (works fine with WSLg's PulseAudio). Volume comes from env var `CLAUDE_HONK_VOLUME` (wins) or by *parsing* (not sourcing — eval-safe) `${XDG_CONFIG_HOME:-$HOME/.config}/claude-honk/config`. Default 50. Mapped per-backend: `ffplay -volume N` (0-100), `afplay -v N/100` (float), `paplay --volume=N*65536/100` (PulseAudio scale).
- `scripts/play-honk.ps1` — PowerShell player for native Windows. Bails immediately on WSL (see hooks.json note above). Reads volume the same way (env var first, then `%USERPROFILE%\.config\claude-honk\config`, parsed via regex). Plays MP3 through the legacy `WMPlayer.OCX.7` COM control because its `settings.volume` is 0–100 — matches our scale directly and supports MP3, unlike `System.Media.SoundPlayer`. Spawns a hidden child `powershell.exe` so the hook returns immediately while the clip plays out.
- `assets/goose-honk.mp3` — the sound. CC BY-NC 4.0 (non-commercial), so don't relicense the repo permissively without addressing this.

`${CLAUDE_PLUGIN_ROOT}` is injected by Claude Code at hook-execution time; both scripts use it to resolve the sound asset. Don't hardcode paths.

## Testing changes

There is no automated test harness. To verify a change end-to-end:

1. Run the script directly with the env var set: `CLAUDE_PLUGIN_ROOT="$(pwd)" ./scripts/play-honk.sh` (or, on Windows, `$env:CLAUDE_PLUGIN_ROOT=$pwd; powershell -File ./scripts/play-honk.ps1`) — should honk audibly.
2. Once installed, the slash command doubles as a smoke test: `/claude-honk:volume 30` writes the config and plays a test honk through whichever script wins on the current OS.
3. For real hook integration, install locally via `claude --plugin-dir /path/to/claude-honk` and trigger one of the three events (e.g., let a session go idle to fire `Notification`, or finish a turn for `Stop`).

Plugins are loaded at session startup and cannot be hot-reloaded — restart Claude Code after editing `hooks.json` or `plugin.json`.

## Documentation drift to watch

`README.md` references matchers `idle_prompt` and `permission_prompt`, but `hooks/hooks.json` uses the hook event names (`Notification`, `PermissionRequest`, `Stop`) with empty matchers. If you change one, reconcile the other.
