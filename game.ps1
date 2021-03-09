
<#
Todo

How to set Virtual Terminal

It works
$e = [char]0x1b
Write-Host "$e[38;2;255;128;128;48;2;128;0;255;4mtest$e[0m"
https://stackoverflow.com/questions/56679782/how-to-use-ansi-escape-sequence-color-codes-for-psreadlineoption-v2-in-powershel



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

$virtSupport = Get-ItemPropertyValue HKCU:\Console VirtualTerminalLevel
Write-Host "$($virtSupport) : Virtual Terminal Support" #required for `e and colours
if ($virtSupport -eq 1) {Pause "WARNING: Virtual Terminal not enabled`r`nExiting"; throw "Resources Error"} 
Pause("Load Complete, Press any key to continue...")







#Initialise Objects
[ANSIBuffer]$consoleBuffer = [ANSIBuffer]::new(10, 10)
[ANSIBufferCell]$fillCell = [ANSIBufferCell]::new('?', "$e[38;2;255;128;128;48;2;128;0;255;4m", "$e[0m")
$consoleBuffer.FillBuffer($fillCell)


#Start Timing
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$stopwatch.Start()

[int]$consoleBufferDelay = 100
[int]$consoleBufferLastTrigger = 0

#Enter main loop
while ($true) {
    

    #Input Get
    #Only get if key available to avoid halting program
    if ($host.UI.RawUI.KeyAvailable) {
        
    }


    #Gamelogic Update

    #Gameworld Update

    #Graphics Update
    if ($stopwatch.Elapsed.TotalMilliseconds -gt $consoleBufferLastTrigger + $consoleBufferDelay) {
        $consoleBufferLastTrigger = $stopwatch.Elapsed.TotalMilliseconds
        $consoleBuffer.DrawBuffer()
    }
    


    
}   
