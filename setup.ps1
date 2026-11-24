param([switch]$Force)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Invoke-WebRequest is roughly an order of magnitude slower with the progress bar on.
$ProgressPreference = "SilentlyContinue"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$toolsDir = Join-Path $root "tools"
$ffmpegBin = Join-Path $toolsDir "ffmpeg\bin"
$ytDlp = Join-Path $toolsDir "yt-dlp.exe"

$ytDlpUrl = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
$ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"

New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

# --- yt-dlp ---------------------------------------------------------------

if ((Test-Path -LiteralPath $ytDlp) -and -not $Force) {
    Write-Host "yt-dlp: already present, skipping (use -Force to re-download)"
} else {
    Write-Host "yt-dlp: downloading (~17 MB)..."
    # Download beside the target first so a failed transfer cannot leave a
    # truncated yt-dlp.exe that later runs and fails in confusing ways.
    $tmp = "$ytDlp.download"
    Invoke-WebRequest -Uri $ytDlpUrl -OutFile $tmp -UseBasicParsing
    Move-Item -LiteralPath $tmp -Destination $ytDlp -Force
    Write-Host "yt-dlp: done"
}

# --- ffmpeg ---------------------------------------------------------------

if ((Test-Path -LiteralPath (Join-Path $ffmpegBin "ffmpeg.exe")) -and -not $Force) {
    Write-Host "ffmpeg: already present, skipping (use -Force to re-download)"
} else {
    # Unpack under TEMP, never under the project. An earlier version of this
    # setup left the 106 MB zip and its 307 MB expansion sitting in tools/.
    $work = Join-Path $env:TEMP "yat-ffmpeg-$PID"
    $zip = Join-Path $work "ffmpeg.zip"
    New-Item -ItemType Directory -Force -Path $work | Out-Null

    try {
        Write-Host "ffmpeg: downloading (~106 MB, this takes a while)..."
        Invoke-WebRequest -Uri $ffmpegUrl -OutFile $zip -UseBasicParsing

        Write-Host "ffmpeg: extracting..."
        Expand-Archive -LiteralPath $zip -DestinationPath $work -Force

        # The archive root carries the version (ffmpeg-9.0-essentials_build),
        # so locate bin instead of hardcoding a version that will go stale.
        $srcBin = Get-ChildItem -LiteralPath $work -Recurse -Directory -Filter "bin" |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "ffmpeg.exe") } |
            Select-Object -First 1

        if (-not $srcBin) {
            throw "Could not find ffmpeg.exe inside the downloaded archive."
        }

        New-Item -ItemType Directory -Force -Path $ffmpegBin | Out-Null
        foreach ($exe in @("ffmpeg.exe", "ffprobe.exe")) {
            Copy-Item -LiteralPath (Join-Path $srcBin.FullName $exe) -Destination $ffmpegBin -Force
        }
        Write-Host "ffmpeg: done"
    } finally {
        Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# --- input files ----------------------------------------------------------

foreach ($name in @("queries.txt", "links.txt")) {
    $target = Join-Path $root $name
    $sample = Join-Path $root "$name.example"

    if (Test-Path -LiteralPath $target) {
        # Never clobber a real list the user has already filled in, even with -Force.
        Write-Host "$name`: already exists, leaving it alone"
    } elseif (Test-Path -LiteralPath $sample) {
        Copy-Item -LiteralPath $sample -Destination $target
        Write-Host "$name`: created from $name.example"
    }
}

# --- verify ---------------------------------------------------------------

Write-Host ""
Write-Host "Verifying..."

$ytDlpVersion = & $ytDlp --version 2>&1 | Select-Object -First 1
Write-Host "  yt-dlp  $ytDlpVersion"

$ffmpegVersion = (& (Join-Path $ffmpegBin "ffmpeg.exe") -version 2>&1 | Select-Object -First 1) -replace "^ffmpeg version ", ""
Write-Host "  ffmpeg  $ffmpegVersion"

$node = Get-Command node -ErrorAction SilentlyContinue
$deno = Get-Command deno -ErrorAction SilentlyContinue
if ($node -or $deno) {
    $runtime = if ($deno) { "deno" } else { "node $(& node --version)" }
    Write-Host "  JS runtime  $runtime"
} else {
    Write-Host "  JS runtime  NOT FOUND - yt-dlp still works but warns about deprecation."
    Write-Host "              Install Node (https://nodejs.org) or Deno to silence it."
}

Write-Host ""
Write-Host "Setup complete. Next: put song names in queries.txt, then run"
Write-Host "download_by_song_names_mp3.bat"
