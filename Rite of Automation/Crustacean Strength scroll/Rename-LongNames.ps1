function Convert-ToLongPath {
    param([Parameter(Mandatory)][string]$Path)

    # Already in long-path format
    if ($Path.StartsWith('\\?\')) { return $Path }

    # UNC path: \\server\share\... => \\?\UNC\server\share\...
    if ($Path.StartsWith('\\')) {
        return '\\?\UNC\' + $Path.TrimStart('\')
    }

    # Local path: C:\... => \\?\C:\...
    return '\\?\' + $Path
}

function Test-PathLong {
    param([Parameter(Mandatory)][string]$Path)
    return Test-Path -LiteralPath (Convert-ToLongPath $Path)
}
# Preview
# .\Rename-LongNames.ps1 -Root "C:\Your\Folder" -Half First -MaxFullPath 259 -WhatIf

# Rename 1st half
# .\Rename-LongNames.ps1 -Root "C:\Your\Folder" -Half First -MaxFullPath 259

# Rename 2nd half
# .\Rename-LongNames.ps1 -Root "C:\Your\Folder" -Half Second -MaxFullPath 259

# Include sub-folder
# .\Rename-LongNames.ps1 -Root "C:\Your\Folder" -Half First -Recurse -WhatIf
