
DO {
    Write-Host $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode #Write code to screen
} while (1 -eq 1)
