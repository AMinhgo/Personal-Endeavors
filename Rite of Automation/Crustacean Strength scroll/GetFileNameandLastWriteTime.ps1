Get-ChildItem -Recurse | 
    Select-Object @{Name='Path';Expression={($_.FullName).Replace((Get-Location).Path,'').TrimStart('\')}}, LastWriteTime | 
    Sort-Object LastWriteTime
