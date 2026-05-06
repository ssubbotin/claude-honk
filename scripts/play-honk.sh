#!/bin/bash
# Play goose honk sound notification.
# Supports Linux (paplay, ffplay), macOS (afplay), and WSL (PowerShell).
#
# Volume (0-100, default 50): set via env var CLAUDE_HONK_VOLUME, or in
#   ${XDG_CONFIG_HOME:-$HOME/.config}/claude-honk/config
# Edits take effect on the next honk — no Claude Code restart needed.

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/claude-honk/config"
if [ -r "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIG_FILE"
fi

VOLUME="${CLAUDE_HONK_VOLUME:-50}"
case "$VOLUME" in
    ''|*[!0-9]*) VOLUME=50 ;;
esac
[ "$VOLUME" -gt 100 ] && VOLUME=100

SOUND_FILE="${CLAUDE_PLUGIN_ROOT}/assets/goose-honk.mp3"

# afplay takes a float (1.0 = 100%); paplay takes 0-65536 (65536 = 100%).
AFPLAY_VOL="$((VOLUME / 100)).$(printf '%02d' $((VOLUME % 100)))"
PAPLAY_VOL=$((VOLUME * 65536 / 100))

# Try different audio players based on what's available.
# Note: paplay doesn't support MP3, so we try ffplay first for MP3 files on Linux.
if [[ "$SOUND_FILE" == *.mp3 ]] && command -v ffplay &> /dev/null; then
    ffplay -nodisp -autoexit -volume "$VOLUME" "$SOUND_FILE" 2>/dev/null &
elif command -v afplay &> /dev/null; then
    # macOS - afplay supports MP3
    afplay -v "$AFPLAY_VOL" "$SOUND_FILE" &
elif command -v paplay &> /dev/null; then
    # paplay only supports WAV, OGG, FLAC (not MP3)
    paplay --volume="$PAPLAY_VOL" "$SOUND_FILE" 2>/dev/null &
elif command -v ffplay &> /dev/null; then
    ffplay -nodisp -autoexit -volume "$VOLUME" "$SOUND_FILE" 2>/dev/null &
elif command -v powershell.exe &> /dev/null; then
    # WSL support — Media.SoundPlayer has no per-play volume control,
    # so CLAUDE_HONK_VOLUME is ignored on this backend.
    powershell.exe -c "(New-Object Media.SoundPlayer '$SOUND_FILE').PlaySync()" &
fi

exit 0
