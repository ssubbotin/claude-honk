#!/bin/bash
# Play goose honk sound notification
# Supports Linux (paplay, aplay), macOS (afplay), and fallback (ffplay)

SOUND_FILE="${CLAUDE_PLUGIN_ROOT}/assets/goose-honk.mp3"

# Try different audio players based on what's available
# Note: paplay doesn't support MP3, so we try ffplay first for MP3 files on Linux
if [[ "$SOUND_FILE" == *.mp3 ]] && command -v ffplay &> /dev/null; then
    ffplay -nodisp -autoexit "$SOUND_FILE" 2>/dev/null &
elif command -v afplay &> /dev/null; then
    # macOS - afplay supports MP3
    afplay "$SOUND_FILE" &
elif command -v paplay &> /dev/null; then
    # paplay only supports WAV, OGG, FLAC (not MP3)
    paplay "$SOUND_FILE" 2>/dev/null &
elif command -v ffplay &> /dev/null; then
    ffplay -nodisp -autoexit "$SOUND_FILE" 2>/dev/null &
elif command -v powershell.exe &> /dev/null; then
    # WSL support
    powershell.exe -c "(New-Object Media.SoundPlayer '$SOUND_FILE').PlaySync()" &
fi

exit 0
