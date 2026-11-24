$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ytDlp = Join-Path $root "tools\yt-dlp.exe"
$queriesPath = Join-Path $root "queries.txt"
$outDir = Join-Path $root "downloads\Search Results"

if (-not (Test-Path -LiteralPath $ytDlp)) {
    throw "Missing yt-dlp: $ytDlp"
}

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

$index = 0
foreach ($query in $queries) {
    $index++
    $num = "{0:D2}" -f $index
    $safe = Convert-ToSafeFileName $query
    $target = Join-Path $outDir "$num - $safe.mp3"

    if (Test-Path -LiteralPath $target) {
        Write-Host "OK exists: $num - $safe.mp3"
        continue
    }

    Write-Host "Searching id for $num - $query"
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $id = & $ytDlp --ignore-errors --no-abort-on-error --js-runtimes node --no-warnings --print "%(id)s" "ytsearch5:$query" 2>$null | Select-Object -First 1
    $ErrorActionPreference = $oldErrorActionPreference
    if (-not $id) {
        Write-Host "  No search result"
        continue
    }

    $mp3 = Get-ChildItem -LiteralPath $outDir -File -Filter "*.mp3" |
        Where-Object { $_.BaseName.Contains("[$id]") } |
        Select-Object -First 1

    if ($mp3) {
        Move-Item -LiteralPath $mp3.FullName -Destination $target -Force
        Write-Host "  Renamed: $($mp3.Name) -> $num - $safe.mp3"
        continue
    }

    $jpg = Get-ChildItem -LiteralPath $outDir -File -Filter "*.jpg" |
        Where-Object { $_.BaseName.Contains("[$id]") } |
        Select-Object -First 1

    if ($jpg) {
        Write-Host "  Only cover image found, deleting: $($jpg.Name)"
        Remove-Item -LiteralPath $jpg.FullName -Force
        continue
    }

    Write-Host "  No existing mp3 matched video id: $id"
}

# Only delete yt-dlp leftovers, which always carry a [videoid] tag.
# A plain user-supplied .jpg in this folder must survive.
Get-ChildItem -LiteralPath $outDir -File -Filter "*.jpg" |
    Where-Object { $_.BaseName -match "\[[\w-]{11}\]$" } |
    ForEach-Object {
        Write-Host "Deleting leftover cover image: $($_.Name)"
        Remove-Item -LiteralPath $_.FullName -Force
    }

Write-Host "Done."
