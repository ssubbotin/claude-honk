#!/bin/bash
# Play goose honk sound notification.
# Supports Linux (paplay, ffplay) and macOS (afplay).
# Native Windows: see scripts/play-honk.ps1 (registered as a sibling hook).
# WSL: install paplay or ffplay; the legacy powershell.exe Media.SoundPlayer
#      branch was dropped because it's WAV-only and our asset is MP3.
#
# Volume (0-100, default 50): set via env var CLAUDE_HONK_VOLUME, or in
#   ${XDG_CONFIG_HOME:-$HOME/.config}/claude-honk/config
# Edits take effect on the next honk - no Claude Code restart needed.

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/claude-honk/config"

# Env var wins; otherwise parse the file (no `source` - keep it eval-safe).
VOLUME="$CLAUDE_HONK_VOLUME"
if [ -z "$VOLUME" ] && [ -r "$CONFIG_FILE" ]; then
    VOLUME=$(grep -E '^[[:space:]]*CLAUDE_HONK_VOLUME[[:space:]]*=[[:space:]]*[0-9]+' "$CONFIG_FILE" \
        | tail -n 1 \
        | sed -E 's/.*=[[:space:]]*([0-9]+).*/\1/')
fi

case "$VOLUME" in
    ''|*[!0-9]*) VOLUME=50 ;;
esac
[ "$VOLUME" -gt 100 ] && VOLUME=100

SOUND_FILE="${CLAUDE_PLUGIN_ROOT}/assets/goose-honk.mp3"

# afplay takes a float (1.0 = 100%); paplay takes 0-65536 (65536 = 100%).
AFPLAY_VOL="$((VOLUME / 100)).$(printf '%02d' $((VOLUME % 100)))"
PAPLAY_VOL=$((VOLUME * 65536 / 100))

# paplay can't decode MP3, so ffplay is checked first for .mp3 files.
if [[ "$SOUND_FILE" == *.mp3 ]] && command -v ffplay &> /dev/null; then
    ffplay -nodisp -autoexit -volume "$VOLUME" "$SOUND_FILE" 2>/dev/null &
elif command -v afplay &> /dev/null; then
    afplay -v "$AFPLAY_VOL" "$SOUND_FILE" &
elif command -v paplay &> /dev/null; then
    paplay --volume="$PAPLAY_VOL" "$SOUND_FILE" 2>/dev/null &
elif command -v ffplay &> /dev/null; then
    ffplay -nodisp -autoexit -volume "$VOLUME" "$SOUND_FILE" 2>/dev/null &
fi

exit 0
