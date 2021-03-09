
<#
Todo


Enable ANSI Escape codes using GetConsoleMode
https://stackoverflow.com/questions/38045245/how-to-call-getstdhandle-getconsolemode-from-powershell
https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
https://docs.microsoft.com/en-us/windows/console/getconsolemode
https://docs.microsoft.com/en-us/windows/console/setconsolemode

May require using WriteConsole
https://docs.microsoft.com/en-us/windows/console/writeconsole

Allows
Multiple colours in one string
Underline or bold
DEC line drawing mode
Triggering certain button presses from write-host
Being super fancy in general




Create my own window buffer so i can draw the whole thing in one go
Requires ANSI escape codes for different colours in one string
Will Stop flickering


Need non blocking input
Sleep
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/start-sleep?view=powershell-7.1

Multithread
https://www.codeproject.com/Tips/895840/Multi-Threaded-PowerShell-Cookbook
#>



using namespace System.Management.Automation.Host
#https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.host.pshostrawuserinterface?view=powershellsdk-7.0.0

#For drawing to screen
using module ./ANSIBuffer.psm1

#For batch like pausing
Import-Module .\Pause.psm1




#Support Checks
Clear-Host
Write-Host "Parse Complete"
Write-Host "$($host.version.Major).$($host.version.Minor) : Powershell Version" #Game built in v5.1
if ( [int]("" + $($host.version.Major) + $($host.version.Minor)) -lt 51) {Pause "WARNING: Powershell Version less than v5.1`r`nExiting"; throw "Resources Error"}
Write-Host "$($Host.UI.SupportsVirtualTerminal) : Virtual Terminal Support" #required for `e and colours
if ($($Host.UI.SupportsVirtualTerminal) -eq $false) {Pause "WARNING: Virtual Terminal not supported`r`nExiting"; throw "Resources Error"} 
Pause("Load Complete, Press any key to continue...")



#Initialise Objects
[ANSIBuffer]$consoleBuffer = [ANSIBuffer]::new(10, 10)
[ANSIBufferCell]$fillCell = [ANSIBufferCell]::new('X', "", "")
$consoleBuffer.FillBuffer($fillCell)



#Enter main loop


while ($true) {

    
    

    #Input Get

    #Gameworld Update
    
    $consoleBuffer.DrawBuffer()
    Pause "asdf"



}   
