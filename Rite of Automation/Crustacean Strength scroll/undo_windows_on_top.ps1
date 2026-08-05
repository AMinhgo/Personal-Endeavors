# Undo on top
Add-Type @"
using System;
using System.Text;
using System.Runtime.InteropServices;

public class Win32Undo {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
    public const UInt32 SWP_NOMOVE = 0x0002;
    public const UInt32 SWP_NOSIZE = 0x0001;
}
"@

# Replace with part of your window title
$keyword = "Remote"  # or part of your RDP title

$found = $false
[Win32Undo+EnumWindowsProc]{
    param($hWnd, $lParam)
    $title = New-Object Text.StringBuilder 256
    [void][Win32Undo]::GetWindowText($hWnd, $title, 256)
    if ($title.Length -gt 0 -and $title.ToString() -like "*$keyword*") {
        "Found window: '$($title.ToString())'"
        [Win32Undo]::SetWindowPos($hWnd, [Win32Undo]::HWND_NOTOPMOST, 0,0,0,0,
            [Win32Undo]::SWP_NOMOVE -bor [Win32Undo]::SWP_NOSIZE) | Out-Null
        "🟢 Removed always-on-top from '$($title.ToString())'"
        $found = $true
        return $false
    }
    return $true
} | ForEach-Object { [Win32Undo]::EnumWindows($_, [IntPtr]::Zero) }

if (-not $found) { "⚠️ No window found containing '$keyword'" }
