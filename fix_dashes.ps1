param(
    [Parameter(Mandatory = $false)]
    [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$badChars = @(
    [char]0x2014, # em dash: —
    [char]0x2013, # en dash: –
    [char]0x2212  # minus sign: −
)

function Get-FixedName {
    param([string]$Name)

    $fixed = $Name
    foreach ($char in $badChars) {
        $fixed = $fixed.Replace($char, "-")
    }
    return $fixed
}

function Get-UniqueTargetPath {
    param(
        [string]$Directory,
        [string]$Name,
        [string]$CurrentFullName
    )

    $target = Join-Path $Directory $Name
    if ($target -eq $CurrentFullName) {
        return $target
    }

    if (-not (Test-Path -LiteralPath $target)) {
        return $target
    }

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($Name)
    $extension = [System.IO.Path]::GetExtension($Name)
    $index = 2

    do {
        $candidateName = "{0}__{1}{2}" -f $baseName, $index, $extension
        $target = Join-Path $Directory $candidateName
        $index++
    } while (Test-Path -LiteralPath $target)

    return $target
}

function Rename-ItemIfNeeded {
    param([System.IO.FileSystemInfo]$Item)

    $fixedName = Get-FixedName -Name $Item.Name
    if ($fixedName -eq $Item.Name) {
        return
    }

    $target = Get-UniqueTargetPath `
        -Directory $Item.DirectoryName `
        -Name $fixedName `
        -CurrentFullName $Item.FullName

    Rename-Item -LiteralPath $Item.FullName -NewName ([System.IO.Path]::GetFileName($target))
    Write-Host ("RENAMED: {0} -> {1}" -f $Item.FullName, $target)
}

Write-Host ("Target folder: {0}" -f $resolvedRoot)
Write-Host "Replacing: em dash, en dash, minus sign -> hyphen-minus"
Write-Host ""

Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -Force |
    ForEach-Object { Rename-ItemIfNeeded -Item $_ }

Get-ChildItem -LiteralPath $resolvedRoot -Recurse -Directory -Force |
    Sort-Object FullName -Descending |
    ForEach-Object { Rename-ItemIfNeeded -Item $_ }

Write-Host ""
Write-Host "Done."
