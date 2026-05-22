param(
    [Parameter(Mandatory = $false)]
    [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$cleanRoot = $Root.Trim().Trim('"')
$resolvedRoot = (Resolve-Path -LiteralPath $cleanRoot).Path
$dashChars = @(
    [char]0x2014, # em dash: —
    [char]0x2013, # en dash: –
    [char]0x2212  # minus sign: −
)
$reservedBaseNames = @(
    "CON", "PRN", "AUX", "NUL",
    "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
    "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"
)

function Get-FixedName {
    param([string]$Name)

    $fixed = $Name

    foreach ($char in $dashChars) {
        $fixed = $fixed.Replace($char, "-")
    }

    # Characters forbidden in Windows file and folder names.
    $fixed = $fixed -replace '[<>:"/\\|?*]', "_"

    # ASCII control characters 0x00-0x1F are invalid in Windows names.
    $fixed = $fixed -replace '[\x00-\x1F]', "_"

    # Some archive tools and Windows compressed folders are fragile around
    # duplicated dots before extensions: "Alekseev I.I..doc" -> "Alekseev I.I.doc".
    while ($fixed -match '\.\.([^.]+)$') {
        $fixed = $fixed -replace '\.\.([^.]+)$', '.$1'
    }

    # Windows names cannot end with a dot or a space.
    $fixed = $fixed.TrimEnd(" ", ".")

    # Keep accidental all-bad names usable.
    if ([string]::IsNullOrWhiteSpace($fixed)) {
        $fixed = "unnamed"
    }

    # Reserved device names are forbidden even with extensions.
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fixed)
    $extension = [System.IO.Path]::GetExtension($fixed)
    if ($reservedBaseNames -contains $baseName.ToUpperInvariant()) {
        $fixed = "_" + $baseName + $extension
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

function Get-ParentDirectory {
    param([System.IO.FileSystemInfo]$Item)

    if ($Item.PSIsContainer) {
        if ($null -eq $Item.Parent) {
            return ""
        }
        return $Item.Parent.FullName
    }

    return $Item.DirectoryName
}

function Rename-ItemIfNeeded {
    param([System.IO.FileSystemInfo]$Item)

    if ($null -eq $Item -or [string]::IsNullOrWhiteSpace($Item.FullName)) {
        return
    }

    $fixedName = Get-FixedName -Name $Item.Name
    if ($fixedName -eq $Item.Name) {
        return
    }

    $parentDirectory = Get-ParentDirectory -Item $Item
    if ([string]::IsNullOrWhiteSpace($parentDirectory)) {
        Write-Host ("SKIPPED: no parent directory for {0}" -f $Item.FullName)
        return
    }

    $target = Get-UniqueTargetPath `
        -Directory $parentDirectory `
        -Name $fixedName `
        -CurrentFullName $Item.FullName

    Rename-Item -LiteralPath $Item.FullName -NewName ([System.IO.Path]::GetFileName($target))
    Write-Host ("RENAMED: {0} -> {1}" -f $Item.FullName, $target)
}

Write-Host ("Target folder: {0}" -f $resolvedRoot)
Write-Host "Sanitizing Windows/ZIP-problematic file and folder names"
Write-Host ""

$files = @(Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File -Force)
foreach ($file in $files) {
    Rename-ItemIfNeeded -Item $file
}

$directories = @(
    Get-ChildItem -LiteralPath $resolvedRoot -Recurse -Directory -Force |
        Sort-Object FullName -Descending
)
foreach ($directory in $directories) {
    Rename-ItemIfNeeded -Item $directory
}

Write-Host ""
Write-Host "Done."
