$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ytDlp = Join-Path $root "tools\yt-dlp.exe"
$ffmpegDir = Join-Path $root "tools\ffmpeg\bin"
$queriesPath = Join-Path $root "queries.txt"
$outDir = Join-Path $root "downloads\Search Results"
$missingReport = Join-Path $root "missing_after_run.txt"

if (-not (Test-Path -LiteralPath $ytDlp)) {
    throw "Missing yt-dlp: $ytDlp"
}

if (-not (Test-Path -LiteralPath (Join-Path $ffmpegDir "ffmpeg.exe"))) {
    throw "Missing ffmpeg: $ffmpegDir\ffmpeg.exe"
}

if (-not (Test-Path -LiteralPath $queriesPath)) {
    throw "Missing queries file: $queriesPath"
}

New-Item -ItemType Directory -Force -Path $outDir | Out-Null
if (Test-Path -LiteralPath $missingReport) {
    Remove-Item -LiteralPath $missingReport -Force
}

function Convert-ToSafeFileName {
    param([Parameter(Mandatory=$true)][string]$Name)

    $safe = $Name.Trim()
    foreach ($char in [System.IO.Path]::GetInvalidFileNameChars()) {
        $safe = $safe.Replace([string]$char, "-")
    }
    $safe = ($safe -replace "\s+", " ").Trim(" .")
    if ($safe.Length -gt 120) {
        $safe = $safe.Substring(0, 120).Trim(" .")
    }
    return $safe
}

function Remove-PartialFiles {
    param([Parameter(Mandatory=$true)][string]$Prefix)

    Get-ChildItem -LiteralPath $outDir -File |
        Where-Object {
            $_.Name.StartsWith("$Prefix.") -and
            $_.Extension.ToLowerInvariant() -in @(".webm", ".m4a", ".opus", ".part", ".jpg", ".jpeg", ".png", ".webp")
        } |
        ForEach-Object {
            Write-Host "  Removing leftover: $($_.Name)"
            Remove-Item -LiteralPath $_.FullName -Force
        }
}

$queries = Get-Content -LiteralPath $queriesPath -Encoding UTF8 |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith("#") }

Write-Host ""
Write-Host "Reading song names from:"
Write-Host $queriesPath
Write-Host ""
Write-Host "Saving MP3 files to:"
Write-Host $outDir
Write-Host ""

$index = 0
foreach ($query in $queries) {
    $index++
    $num = "{0:D2}" -f $index
    $safe = Convert-ToSafeFileName $query
    $prefix = "$num - $safe"
    $template = Join-Path $outDir "$num - $safe.%(ext)s"
    $existing = Join-Path $outDir "$num - $safe.mp3"

    if (Test-Path -LiteralPath $existing) {
        Write-Host "$num - Exists, skipping: $safe.mp3"
        continue
    }

    Write-Host ""
    Write-Host "$num - Searching: $query"
    Remove-PartialFiles -Prefix $prefix

    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $ids = & $ytDlp `
        --ignore-errors `
        --no-abort-on-error `
        --js-runtimes node `
        --no-warnings `
        --flat-playlist `
        --print "%(id)s" `
        "ytsearch10:$query" 2>$null |
        Where-Object { $_ } |
        Select-Object -First 10
    $ErrorActionPreference = $oldErrorActionPreference

    if (-not $ids) {
        Write-Host "  No search results."
        Add-Content -LiteralPath $missingReport -Value "$num - $query | no search results"
        continue
    }

    $downloaded = $false
    foreach ($id in $ids) {
        if (Test-Path -LiteralPath $existing) {
            $downloaded = $true
            break
        }

        Write-Host "  Trying video id: $id"
        $oldErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        & $ytDlp `
            --ignore-errors `
            --no-abort-on-error `
            --js-runtimes node `
            --match-filter "duration < 600" `
            --ffmpeg-location $ffmpegDir `
            -f "bestaudio/best" `
            -x --audio-format mp3 --audio-quality 0 `
            --embed-metadata `
            --no-write-thumbnail `
            -o $template `
            "https://www.youtube.com/watch?v=$id"
        $ErrorActionPreference = $oldErrorActionPreference
        Remove-PartialFiles -Prefix $prefix

        if (Test-Path -LiteralPath $existing) {
            $downloaded = $true
            break
        }
    }

    if (-not $downloaded) {
        Write-Host "  Still missing after trying search results."
        Add-Content -LiteralPath $missingReport -Value "$num - $query | tried ids: $($ids -join ', ')"
        Remove-PartialFiles -Prefix $prefix
    }
}

Write-Host ""
Write-Host "Done. Check the downloads\Search Results folder."
if (Test-Path -LiteralPath $missingReport) {
    Write-Host "Some songs are still missing. See:"
    Write-Host $missingReport
}
