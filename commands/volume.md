---
description: Set claude-honk volume (0-100). Pass a number, or ask interactively.
allowed-tools: Bash, Read, Write, AskUserQuestion
---

You are setting the claude-honk plugin's volume. The plugin reads `CLAUDE_HONK_VOLUME` (0–100) from `~/.config/claude-honk/config` on every honk; defaults to 50.

## Step 1 — read current state

Read `~/.config/claude-honk/config` if it exists. Extract the current `CLAUDE_HONK_VOLUME` value if present; otherwise the effective default is `50`.

## Step 2 — determine the new volume

If the user's invocation included a numeric argument between 0 and 100 (e.g. `/claude-honk:volume 30`), use that as the new volume.

Otherwise, call `AskUserQuestion` with:
- header: "Volume"
- question: "Current volume: <CURRENT>. Set new claude-honk volume:"
- multiSelect: false
- options: ["10 (very quiet)", "25 (quiet)", "50 (default)", "75 (loud)", "100 (max)", "Custom"]

If the user picks "Custom", call `AskUserQuestion` again with a free-form prompt asking for a number 0–100.

Validate the new value is an integer in [0, 100]. If not, report the error and stop.

## Step 3 — write the config

Use the Write tool to write `~/.config/claude-honk/config` with exactly:

```
CLAUDE_HONK_VOLUME=<NEW_VALUE>
```

Create the directory first via `mkdir -p ~/.config/claude-honk` if needed (use Bash). Do not preserve other lines from the file — this command owns the entire file. (If you ever add other settings here, update this command.)

## Step 4 — play a test honk

Resolve the plugin root and play one honk at the new volume so the user hears it:

```bash
CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(ls -d ~/.claude/plugins/cache/claude-honk-marketplace/claude-honk/*/ 2>/dev/null | sort -V | tail -1)}" \
  CLAUDE_HONK_VOLUME=<NEW_VALUE> \
  "${CLAUDE_PLUGIN_ROOT}/scripts/play-honk.sh"
```

If the resolved path doesn't contain `scripts/play-honk.sh`, skip the test honk and tell the user where the config was written.

## Step 5 — confirm

Report in one short sentence: the new volume, the config file path, and a note that future changes to that file take effect on the next honk (no restart needed).
