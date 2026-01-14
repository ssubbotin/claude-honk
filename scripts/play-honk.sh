#!/bin/bash
# Play goose honk sound notification
# Supports Linux (paplay, aplay), macOS (afplay), and fallback (ffplay)

SOUND_FILE="${CLAUDE_PLUGIN_ROOT}/assets/goose-honk.mp3"

# Try different audio players based on what's available
if command -v paplay &> /dev/null; then
    paplay "$SOUND_FILE" 2>/dev/null &
elif command -v afplay &> /dev/null; then
    afplay "$SOUND_FILE" &
elif command -v aplay &> /dev/null; then
    # aplay doesn't support mp3, try ffplay instead
    if command -v ffplay &> /dev/null; then
        ffplay -nodisp -autoexit "$SOUND_FILE" 2>/dev/null &
    fi
elif command -v ffplay &> /dev/null; then
    ffplay -nodisp -autoexit "$SOUND_FILE" 2>/dev/null &
elif command -v powershell.exe &> /dev/null; then
    # WSL support
    powershell.exe -c "(New-Object Media.SoundPlayer '$SOUND_FILE').PlaySync()" &
fi

exit 0
