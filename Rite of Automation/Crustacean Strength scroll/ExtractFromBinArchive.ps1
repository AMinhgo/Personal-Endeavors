# Folder containing .bin files
$binFolder = "C:\Users\mnnguyen5\Desktop\KPMG - AIA ICFR 2026 - CP Hoang Thuy Ai - upload\xl\embeddings"
# Output folder for extracted files
$outputFolder = "C:\Users\mnnguyen5\Desktop\KPMG - AIA ICFR 2026 - CP Hoang Thuy Ai - upload\xl\embeddings"

# Create output folder if missing
if (!(Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

# Get all .bin files
$binFiles = Get-ChildItem -Path $binFolder -Filter *.bin

foreach ($file in $binFiles) {
    Write-Host "Processing $($file.Name)..."
    
    # Read binary content
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $text = [System.Text.Encoding]::ASCII.GetString($bytes)

    # Check for PDF markers
    $startPDF = $text.IndexOf("%PDF")
    $endPDF = $text.LastIndexOf("%%EOF")

    if ($startPDF -ge 0 -and $endPDF -gt $startPDF) {
        $pdfBytes = $bytes[$startPDF..($endPDF + 4)]
        $outputPDF = Join-Path $outputFolder ($file.BaseName + ".pdf")
        [System.IO.File]::WriteAllBytes($outputPDF, $pdfBytes)
        Write-Host "Extracted PDF: $outputPDF"
        continue
    }

    # Check for JPG markers (hex search)
    $startJPG = [Array]::IndexOf($bytes, 0xFF)
    while ($startJPG -ge 0 -and $startJPG -lt $bytes.Length - 1) {
        if ($bytes[$startJPG] -eq 0xFF -and $bytes[$startJPG + 1] -eq 0xD8) {
            break
        }
        $startJPG = [Array]::IndexOf($bytes, 0xFF, $startJPG + 1)
    }

    $endJPG = [Array]::LastIndexOf($bytes, 0xD9)

    if ($startJPG -ge 0 -and $endJPG -gt $startJPG) {
        $jpgBytes = $bytes[$startJPG..$endJPG]
        $outputJPG = Join-Path $outputFolder ($file.BaseName + ".jpg")
        [System.IO.File]::WriteAllBytes($outputJPG, $jpgBytes)
        Write-Host "Extracted JPG: $outputJPG"
    } else {
        Write-Host "No PDF or JPG found in $($file.Name)"
    }
}

Write-Host "Done! Check $outputFolder for extracted files."
