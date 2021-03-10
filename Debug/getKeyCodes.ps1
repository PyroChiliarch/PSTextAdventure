
while ($true) {
    Write-Host $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode
}
