
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

using namespace System.Collections
#https://docs.microsoft.com/en-us/dotnet/api/system.collections?view=net-5.0

#Import Core Modules
using module ./Core/ANSIBuffer.psm1
using module ./Core/Pause.psm1
using module ./Core/Input.psm1
using module ./Core/LogicEnvironment.psm1

#Import Game Modules
using module ./Game/GameMenu.psm1
using module ./Game/GameWorld.psm1
using module ./Game/GameConnect4.psm1










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





#Tidy up a bit
#hide cursor
$host.UI.RawUI.WindowSize = [Size]::new(72, 42)
[Console]::CursorVisible = $false 




#Initialise Objects
[ANSIBuffer]$gScreen = [ANSIBuffer]::new(70, 40)

[Input]$gInput = [Input]::new()

[System.Diagnostics.Stopwatch]$gTime = [System.Diagnostics.Stopwatch]::StartNew()



#Initialise GameEnvironments
[Stack]$environmentStack = [Stack]::new()
[GameMenu]$geMainMenu = [GameMenu]::new("MainMenu", $gScreen, $gInput, $gTime, [ExitCode]::new(""))
$environmentStack.push($geMainMenu)




#Enter main loop
while ($true) {
    
    #Get the current environment to update
    $curEnv = $environmentStack.Peek()
    [ExitCode]$exitCode = $curEnv.Update()

    if ($exitCode.nextEnvironment -ne "") {

        #Return to previous env
        #Exit if last one
        if ($exitCode.nextEnvironment -eq "prev") {
            if ($environmentStack.Count -gt 1) {
                $q = $environmentStack.Pop()
                $q = $q
                continue
            } else {
                Clear-Host
                pause("Exiting...")
                break
            }
            
        }
        
        #Start a new game environment
        if ($exitCode.nextEnvironment -eq "newGame") {
            [GameWorld]$newEnv = [GameWorld]::new("newGame", $gScreen, $gInput, $gTime, $exitCode)
            $environmentStack.Push($newEnv)
            continue
        }

        if ($exitCode.nextEnvironment -eq "con4") {
            [GameConnect4]$newEnv = [GameConnect4]::new("con4", $gScreen, $gInput, $gTime, $exitCode)
            $environmentStack.Push($newEnv)
            continue
        }
        pause("Error : $($exitCode.nextEnvironment) : Attempt to enter unknown environment")
        break
    }
    
}   

