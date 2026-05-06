# Play goose honk sound notification on Windows.
# Reads CLAUDE_HONK_VOLUME (0-100, default 50) from env var, or from
#   $env:USERPROFILE\.config\claude-honk\config
# Edits take effect on the next honk - no Claude Code restart needed.
#
# Companion to play-honk.sh: hooks.json registers both, and each platform's
# "wrong" entry no-ops. This script bails when invoked from inside WSL so
# the bash entry handles WSL alone (no double honk).

# Bail when running inside WSL - the bash script handles that environment.
if ($env:WSL_DISTRO_NAME -or $env:WSLENV) { exit 0 }

$ErrorActionPreference = 'SilentlyContinue'

# --- Resolve volume: env var wins, then config file, then default 50. ---
$volumeRaw = $env:CLAUDE_HONK_VOLUME
if (-not $volumeRaw) {
    $configPath = Join-Path $env:USERPROFILE '.config\claude-honk\config'
    if (Test-Path $configPath) {
        $match = Get-Content $configPath |
            Where-Object { $_ -match '^\s*CLAUDE_HONK_VOLUME\s*=\s*(\d+)' } |
            Select-Object -Last 1
        if ($match -and $match -match '^\s*CLAUDE_HONK_VOLUME\s*=\s*(\d+)') {
            $volumeRaw = $matches[1]
        }
    }
}

[int]$volume = 50
if ([int]::TryParse($volumeRaw, [ref]$volume)) {
    if ($volume -lt 0)   { $volume = 0   }
    if ($volume -gt 100) { $volume = 100 }
} else {
    $volume = 50
}

# --- Resolve sound file. ---
if (-not $env:CLAUDE_PLUGIN_ROOT) { exit 0 }
$soundFile = Join-Path $env:CLAUDE_PLUGIN_ROOT 'assets\goose-honk.mp3'
if (-not (Test-Path $soundFile)) { exit 0 }

# --- Play in a hidden background process so the hook returns immediately. ---
# WMPlayer.OCX.7 is the legacy Windows Media Player COM control: handles MP3
# and exposes a 0-100 volume scale that matches CLAUDE_HONK_VOLUME directly.
# The wrapper PS instance exits at once; the spawned child outlives it and
# plays the clip, then closes. Sleep is a generous upper bound on clip length.
$soundFileEscaped = $soundFile.Replace("'", "''")
$child = @"
`$wmp = New-Object -ComObject WMPlayer.OCX.7
`$wmp.settings.volume = $volume
`$wmp.URL = '$soundFileEscaped'
Start-Sleep -Seconds 5
"@

Start-Process -FilePath powershell.exe `
    -ArgumentList '-NoProfile','-WindowStyle','Hidden','-Command',$child `
    -WindowStyle Hidden | Out-Null

exit 0
