$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$zipPath = Join-Path $basePath "Fonts.7z"
$fontsPath = Join-Path $basePath "Fonts"
$sevenZip = Join-Path $basePath "7za.exe"

$destPath = "$env:SystemRoot\Fonts"
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

Write-Host "Extracting, please wait..."
if (!(Test-Path $fontsPath) -and (Test-Path $zipPath)) {
    & $sevenZip x $zipPath "-o$fontsPath" -y | Out-Null
}

Write-Host "Installing..."
$fontFiles = Get-ChildItem $fontsPath -Recurse | Where-Object {
    -not $_.PSIsContainer -and (
        $_.Extension -eq ".ttf" -or
        $_.Extension -eq ".otf" -or
        $_.Extension -eq ".ttc" -or
        $_.Extension -eq ".fon"
    )
}

$total = $fontFiles.Count
$index = 0

if ($total -eq 0) {
    Write-Progress -Activity "Installing fonts..." -Status "No fonts found" -PercentComplete 100
    return
}

foreach ($font in $fontFiles) {
    $index++
    $percent = [int](($index * 100) / $total)

    Write-Progress -Activity "Installing fonts..." `
        -Status "$index / $total" `
        -PercentComplete $percent

    $destFile = Join-Path $destPath $font.Name

    if (Test-Path $destFile) {
        continue
    }

    Copy-Item $font.FullName -Destination $destFile

    $fontName = $font.BaseName
    $ext = $font.Extension.ToLower()

    if ($ext -eq ".ttf" -or $ext -eq ".ttc") {
        $regName = "$fontName (TrueType)"
    } elseif ($ext -eq ".otf") {
        $regName = "$fontName (OpenType)"
    } elseif ($ext -eq ".fon") {
        $regName = "$fontName (Font)"
    } else {
        continue
    }

    if (-not (Get-ItemProperty $regPath -Name $regName -ErrorAction SilentlyContinue)) {
        New-ItemProperty -Path $regPath `
            -Name $regName `
            -Value $font.Name `
            -PropertyType String | Out-Null
    }
}

Write-Progress -Activity "Installing fonts..." -Status "Done" -Completed
