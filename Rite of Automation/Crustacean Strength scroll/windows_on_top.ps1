# Windows on top
Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public class Win32Enum {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
    public const UInt32 SWP_NOMOVE = 0x0002;
    public const UInt32 SWP_NOSIZE = 0x0001;
}
"@

# 🧭 Replace with part of your window title (can be partial)
$keyword = "Remote"  # or "Settings", or part of your RDP PC name

$found = $false
[Win32Enum+EnumWindowsProc]{
    param($hWnd, $lParam)
    $title = New-Object Text.StringBuilder 256
    [void][Win32Enum]::GetWindowText($hWnd, $title, 256)
    if ($title.Length -gt 0 -and $title.ToString() -like "*$keyword*") {
        "Found window: '$($title.ToString())'"
        [Win32Enum]::SetWindowPos($hWnd, [Win32Enum]::HWND_TOPMOST, 0,0,0,0, [Win32Enum]::SWP_NOMOVE -bor [Win32Enum]::SWP_NOSIZE) | Out-Null
        "✅ Set '$($title.ToString())' as always on top"
        $found = $true
        return $false  # stop after first match
    }
    return $true
} | ForEach-Object { [Win32Enum]::EnumWindows($_, [IntPtr]::Zero) }

if (-not $found) { "Eh, whatever, enjoy '$keyword'!" }
