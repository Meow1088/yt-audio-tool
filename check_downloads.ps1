$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$queriesPath = Join-Path $root "queries.txt"
$outDir = Join-Path $root "downloads\Search Results"

if (-not (Test-Path -LiteralPath $queriesPath)) {
    throw "Missing queries file: $queriesPath"
}

if (-not (Test-Path -LiteralPath $outDir)) {
    throw "Missing output folder: $outDir"
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

$queries = Get-Content -LiteralPath $queriesPath -Encoding UTF8 |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith("#") }

$expected = @()
$index = 0
foreach ($query in $queries) {
    $index++
    $num = "{0:D2}" -f $index
    $safe = Convert-ToSafeFileName $query
    $expected += "$num - $safe.mp3"
}

$files = Get-ChildItem -LiteralPath $outDir -File
$mp3Files = $files | Where-Object { $_.Extension.ToLowerInvariant() -eq ".mp3" }
$nonMp3Files = $files | Where-Object { $_.Extension.ToLowerInvariant() -ne ".mp3" }
$actualNames = @($mp3Files | ForEach-Object { $_.Name })

$missing = $expected | Where-Object { $_ -notin $actualNames }
$extra = $actualNames | Where-Object { $_ -notin $expected }

Write-Host "Expected MP3: $($expected.Count)"
Write-Host "Actual MP3:   $($actualNames.Count)"
Write-Host "Non-MP3:      $($nonMp3Files.Count)"

if ($missing) {
    Write-Host ""
    Write-Host "Missing:"
    $missing | ForEach-Object { Write-Host "  $_" }
}

if ($extra) {
    Write-Host ""
    Write-Host "Extra or mismatched names:"
    $extra | ForEach-Object { Write-Host "  $_" }
}

if ($nonMp3Files) {
    Write-Host ""
    Write-Host "Non-MP3 leftovers:"
    $nonMp3Files | ForEach-Object { Write-Host "  $($_.Name)" }
}

# A normal song is roughly 1-25 MB at this bitrate. Anything outside that is
# usually a wrong match: a full mix/compilation, or a truncated download.
$suspicious = $mp3Files | Where-Object { $_.Length -gt 25MB -or $_.Length -lt 1MB }
if ($suspicious) {
    Write-Host ""
    Write-Host "Suspicious size (likely wrong video):"
    $suspicious | ForEach-Object {
        Write-Host ("  {0} ({1:N1} MB)" -f $_.Name, ($_.Length / 1MB))
    }
}

if (-not $missing -and -not $extra -and -not $nonMp3Files -and -not $suspicious) {
    Write-Host ""
    Write-Host "OK: downloads match queries.txt."
}

