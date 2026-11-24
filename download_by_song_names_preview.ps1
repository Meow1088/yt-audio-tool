$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ytDlp = Join-Path $root "tools\yt-dlp.exe"
$queriesPath = Join-Path $root "queries.txt"

if (-not (Test-Path -LiteralPath $ytDlp)) {
    throw "Missing yt-dlp: $ytDlp"
}

if (-not (Test-Path -LiteralPath $queriesPath)) {
    throw "Missing queries file: $queriesPath"
}

$queries = Get-Content -LiteralPath $queriesPath -Encoding UTF8 |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith("#") }

$index = 0
foreach ($query in $queries) {
    $index++
    $num = "{0:D2}" -f $index
    Write-Host ""
    Write-Host "=== $num - $query ==="
    & $ytDlp --js-runtimes node --flat-playlist --print "%(title)s | %(webpage_url)s" "ytsearch5:$query"
}

