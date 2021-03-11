
<#
Todo


How to set Virtual Terminal
It works
$e = [char]0x1b
Write-Host "$e[38;2;255;128;128;48;2;128;0;255;4mtest$e[0m"
https://stackoverflow.com/questions/56679782/how-to-use-ansi-escape-sequence-color-codes-for-psreadlineoption-v2-in-powershel

move 

Game
-ScreenBuffer
-Environments
--GameWorld
---MenuContextStack
----Inputs
----Viewport
----Console/Log

#>



using namespace System.Management.Automation.Host
#https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.host.pshostrawuserinterface?view=powershellsdk-7.0.0

#Import Core Modules
using module ./Core/ANSIBuffer.psm1
using module ./Core/Pause.psm1
using module ./Core/Input.psm1
using module ./Core/LogicEnvironment.psm1

#Import Game Modules
using module ./Game/GameMenu.psm1










#Support Checks
Clear-Host
Write-Host "Parse Complete"

Write-Host "$($host.version.Major).$($host.version.Minor) : Powershell Version" #Game built in v5.1
if ( [int]("" + $($host.version.Major) + $($host.version.Minor)) -lt 51) {Pause "WARNING: Powershell Version less than v5.1`r`nExiting"; throw "Resources Error"}

Set-ItemProperty HKCU:\Console VirtualTerminalLevel -Type DWORD 1
$virtSupport = Get-ItemPropertyValue HKCU:\Console VirtualTerminalLevel
Write-Host "$($virtSupport) : Virtual Terminal Support" #required for `e and colours
if ($virtSupport -eq 0) {Pause "WARNING: Virtual Terminal not enabled`r`nExiting"; throw "Resources Error"} 
Pause("Load Complete, Press any key to continue...")







#Initialise Objects
[ANSIBuffer]$gScreen = [ANSIBuffer]::new(30, 30)

[Input]$gInput = [Input]::new()

[System.Diagnostics.Stopwatch]$gTime = [System.Diagnostics.Stopwatch]::StartNew()



#Initialise GameEnvironments
[GameMenu]$gEnvironment = [GameMenu]::new("MainMenu", $gScreen, $gInput, $gTime)


#Enter main loop
while ($true) {
    
    if ($gEnvironment.Update()) {
        break
    }

}   
