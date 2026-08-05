$CsvFile = "C:\Users\mnnguyen5\Desktop\Rite of Automation\Crustacean Strength scroll\FileNames.csv"
$Template = "C:\Users\mnnguyen5\Desktop\Rite of Automation\Crustacean Strength scroll\Template.xlsx"
$OutputFolder = "C:\Users\mnnguyen5\KPMG\Vo, Viet Sang - Minh Nhật\AIA\Prepare\3. Execute\TOE"

$Rows = Import-Csv $CsvFile

foreach ($Row in $Rows) {

    # Replace "Name" with whichever CSV column should become the filename
    $SafeName = $Row.Name -replace '[\\/:*?"<>|]', '_'

    $OutputFile = Join-Path $OutputFolder "$SafeName.xlsx"

    if (-not (Test-Path $OutputFile)) {
    Copy-Item $Template $OutputFile
    }
}