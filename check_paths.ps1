$root = Get-Location
$files = Get-ChildItem -Path (Join-Path $root 'html') -Filter *.html
foreach ($html in $files) {
    $text = Get-Content -Path $html.FullName -Raw
    $refs = [regex]::Matches($text, '(?:src|href)="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
    $missing = @()
    foreach ($ref in $refs) {
        if ($ref.StartsWith('http://') -or $ref.StartsWith('https://') -or $ref.StartsWith('mailto:') -or $ref.StartsWith('#') -or $ref.StartsWith('javascript:')) {
            continue
        }
        $p = (Join-Path $html.Directory.FullName $ref)
        if (-not (Test-Path $p)) {
            $missing += $ref
        }
    }
    if ($missing.Count -eq 0) {
        Write-Output "$($html.FullName): OK"
    } else {
        Write-Output "$($html.FullName): MISSING $($missing -join ', ')"
    }
}
