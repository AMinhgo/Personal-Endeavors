Add-Type -AssemblyName System.Windows.Forms

Write-Host "Random mouse mover started. Press ESC to quit."

# Get screen dimensions
$screenWidth  = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

# Enable key press detection
$host.UI.RawUI.FlushInputBuffer()

while ($true) {
    # Exit if Esc key pressed
    if ($host.UI.RawUI.KeyAvailable) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if ($key.VirtualKeyCode -eq 27) {  # 27 = Esc
            Write-Host "Exiting..."
            break
        }
    }

    # Pick random coordinates
    $x = Get-Random -Minimum 0 -Maximum $screenWidth
    $y = Get-Random -Minimum 0 -Maximum $screenHeight

    # Move mouse
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)

    Start-Sleep -Milliseconds 500
}
