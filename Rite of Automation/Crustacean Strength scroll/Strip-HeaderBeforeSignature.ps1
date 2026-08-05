
<#
.SYNOPSIS
  Removes any leading bytes before a signature (e.g. %PDF) and writes the remainder to a new file.

.DESCRIPTION
  Scans the input file in chunks to find the first occurrence of a byte signature.
  Everything before that signature is discarded. The rest is copied to an output file.

.PARAMETER InputPath
  Path to the input file.

.PARAMETER OutputPath
  Path to the output file. If omitted, it is derived automatically based on the signature.

.PARAMETER Signature
  The marker to search for. Default: "%PDF" (you can also use "%PDF-" for stricter matching).

.PARAMETER ExcludeSignature
  If set, the output will start AFTER the signature bytes (rarely desired for PDFs).

.PARAMETER Overwrite
  If set, overwrites OutputPath if it exists.

.EXAMPLE
  .\Strip-HeaderBeforeSignature.ps1 -InputPath .\broken.bin

.EXAMPLE
  .\Strip-HeaderBeforeSignature.ps1 -InputPath .\file.dat -Signature "%PDF-" -OutputPath .\fixed.pdf -Overwrite
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [string]$OutputPath,

    [string]$Signature = "%PDF",

    [switch]$ExcludeSignature,

    [switch]$Overwrite
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $InputPath)) {
    throw "InputPath not found: $InputPath"
}

# Convert signature to bytes (ASCII is correct for PDF header text)
$pattern = [System.Text.Encoding]::ASCII.GetBytes($Signature)
if ($pattern.Length -eq 0) { throw "Signature cannot be empty." }

# Basic mapping from signature to file extension (extend if you want)
$extMap = @{
    "%PDF"  = ".pdf"
    "%PDF-" = ".pdf"
}

function Find-PatternOffsetInFileStream {
    param(
        [Parameter(Mandatory)]
        [System.IO.FileStream]$Stream,

        [Parameter(Mandatory)]
        [byte[]]$Pattern,

        [int]$ChunkSize = 1048576 # 1 MB
    )

    $patternLen = $Pattern.Length
    $tailLen = [Math]::Max(0, $patternLen - 1)

    $buffer = New-Object byte[] $ChunkSize
    $tail = New-Object byte[] 0

    $absoluteOffset = 0L

    while (($read = $Stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        # Build a search window = tail + current chunk (only the bytes read)
        $windowLen = $tail.Length + $read
        $window = New-Object byte[] $windowLen

        if ($tail.Length -gt 0) {
            [Array]::Copy($tail, 0, $window, 0, $tail.Length)
        }
        [Array]::Copy($buffer, 0, $window, $tail.Length, $read)

        # Naive pattern search (fast enough for small signatures like %PDF)
        for ($i = 0; $i -le $windowLen - $patternLen; $i++) {
            $match = $true
            for ($j = 0; $j -lt $patternLen; $j++) {
                if ($window[$i + $j] -ne $Pattern[$j]) { $match = $false; break }
            }
            if ($match) {
                # Convert window offset back to absolute file offset
                # window starts at (absoluteOffset - tail.Length)
                return ($absoluteOffset - $tail.Length + $i)
            }
        }

        # Keep last (patternLen - 1) bytes for boundary matching
        if ($tailLen -gt 0) {
            $keep = [Math]::Min($tailLen, $windowLen)
            $tail = New-Object byte[] $keep
            [Array]::Copy($window, $windowLen - $keep, $tail, 0, $keep)
        } else {
            $tail = New-Object byte[] 0
        }

        $absoluteOffset += $read
    }

    return -1L
}

# Determine OutputPath if not provided
if (-not $OutputPath) {
    $sigKey = $Signature
    $ext = $extMap[$sigKey]
    if (-not $ext) { $ext = ".bin" }

    $dir = Split-Path -Parent $InputPath
    $base = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
    $OutputPath = Join-Path $dir ($base + "_stripped" + $ext)
}

if ((Test-Path -LiteralPath $OutputPath) -and (-not $Overwrite)) {
    throw "OutputPath already exists: $OutputPath. Use -Overwrite to replace it."
}

# Open input stream and locate signature offset
$inStream = [System.IO.File]::Open($InputPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
try {
    $offset = Find-PatternOffsetInFileStream -Stream $inStream -Pattern $pattern
    if ($offset -lt 0) {
        throw "Signature '$Signature' not found in file: $InputPath"
    }

    if ($ExcludeSignature) {
        $offset += $pattern.Length
    }

    # Seek to offset and copy remainder to output
    $inStream.Seek($offset, [System.IO.SeekOrigin]::Begin) | Out-Null

    $outMode = if ($Overwrite) { [System.IO.FileMode]::Create } else { [System.IO.FileMode]::CreateNew }
    $outStream = [System.IO.File]::Open($OutputPath, $outMode, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)

    try {
        $inStream.CopyTo($outStream, 1048576) # 1 MB buffer
    }
    finally {
        $outStream.Dispose()
    }

    Write-Host "Done." -ForegroundColor Green
    Write-Host "Input : $InputPath"
    Write-Host "Found : '$Signature' at offset $offset"
    Write-Host "Output: $OutputPath"
}
finally {
    $inStream.Dispose()
}
