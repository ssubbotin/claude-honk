---
description: Set claude-honk volume (0-100). Pass a number, or pick from a list.
allowed-tools: Bash, Read, Write, AskUserQuestion
---

You are setting the claude-honk plugin's volume. The plugin reads `CLAUDE_HONK_VOLUME` (0–100, default 50) from the env var first, then from `~/.config/claude-honk/config` (Linux/macOS) or `%USERPROFILE%\.config\claude-honk\config` (Windows). The file is parsed for `CLAUDE_HONK_VOLUME=<number>`; nothing else.

## Step 1 — read current state

Read the config file if it exists. Extract the current `CLAUDE_HONK_VOLUME` value. If absent, the effective default is `50`.

## Step 2 — determine the new volume

If the user's invocation included a numeric argument between 0 and 100 (e.g. `/claude-honk:volume 30`), use that value and skip to Step 3.

Otherwise, call `AskUserQuestion`:
- header: "Volume"
- question: "Current volume: <CURRENT>. Set new claude-honk volume:"
- multiSelect: false
- options: ["10 (very quiet)", "15", "20 (quiet)", "30", "50 (default)", "75 (loud)", "100 (max)"]

Parse the leading integer from the chosen option. Validate it is in [0, 100]; otherwise stop and report.

## Step 3 — write the config

Use the Write tool to write the config file with exactly:

```
CLAUDE_HONK_VOLUME=<NEW_VALUE>
```

Create the directory first if needed (`mkdir -p ~/.config/claude-honk` on Unix, or `New-Item -ItemType Directory -Force` on Windows). This command owns the entire file — do not preserve other lines. (If more settings are ever added, update this command to preserve them.)

## Step 4 — play a test honk

Pick the right script for the current OS and run it with the new volume so the user hears it:

```bash
if [ -n "$CLAUDE_PLUGIN_ROOT" ] && [ -r "$CLAUDE_PLUGIN_ROOT/scripts/play-honk.sh" ] && command -v bash >/dev/null 2>&1; then
    CLAUDE_HONK_VOLUME=<NEW_VALUE> bash "$CLAUDE_PLUGIN_ROOT/scripts/play-honk.sh"
elif [ -n "$CLAUDE_PLUGIN_ROOT" ] && command -v powershell.exe >/dev/null 2>&1; then
    CLAUDE_HONK_VOLUME=<NEW_VALUE> powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$CLAUDE_PLUGIN_ROOT/scripts/play-honk.ps1"
fi
```

If neither path runs, skip the test honk and tell the user where the config was written; the next real hook event will use the new value.

## Step 5 — confirm

Report in one short sentence: the new volume, the config file path, and that future edits to that file take effect on the next honk (no restart needed).
