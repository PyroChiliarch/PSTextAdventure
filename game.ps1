
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

#Import Modules
using module ./Core/ANSIBuffer.psm1
using module ./Core/Pause.psm1
using module ./Core/Input.psm1










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
[ANSIBufferCell]$fillCell = [ANSIBufferCell]::new(' ', [ANSIBufferCell]::CreateStyle(0, 0, 0, 0, 0, 0, $false, $false), 255)
[ANSIBuffer]$consoleBuffer = [ANSIBuffer]::new(30, 30, $fillCell)
$consoleBuffer.Clear()


[Input]$gameInput = [Input]::new()










#Start Timing
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$stopwatch.Start()
[int]$consoleBufferDelay = 500
[int]$consoleBufferLastTrigger = 0

$loopCount = 0
$drawCount = 0



$testStyle = [ANSIBufferCell]::CreateStyle(0, 255, 0, 0, 0, 0, $true, $false)
$testCell = [ANSIBufferCell]::new('T', $testStyle, 10)

$testStyle2 = [ANSIBufferCell]::CreateStyle(255, 0, 0, 0, 0, 255, $true, $false)
$testCell2 = [ANSIBufferCell]::new('T', $testStyle2, 10)

#Enter main loop
while ($true) {
    
    
    
    #Input Get
    #Only get if key available to avoid halting program
    $gameInput.UpdateInput()

    if ($host.UI.RawUI.KeyAvailable -eq $true) {


        if ($gameInput.currentKey.VirtualKeyCode -eq [KeyID]::none) {
            continue
        }

        if ($gameInput.currentKey.VirtualKeyCode -eq [KeyID]::space) {
            break #$consoleBuffer.buffer[4, 4] = [ANSIBufferCell]::new('C',"$e[48;2;255;255;255;38;2;0;0;0mcccc$e[27m")
        }

    }


    #Graphics Update
    if ($stopwatch.Elapsed.TotalMilliseconds -gt $consoleBufferLastTrigger + $consoleBufferDelay) {
        $consoleBufferLastTrigger = $stopwatch.Elapsed.TotalMilliseconds
        
        
        #$consoleBuffer.WriteCell()
        $consoleBuffer.Clear()
        $consoleBuffer.WriteString(0, 0, $drawCount, $testCell.style, 10)
        $consoleBuffer.WriteString(0, 10, "1111111111111111", $testCell.style, 60)
        $consoleBuffer.WriteString(0, 11, "1111111111111111", $testCell.style, 30)
        $consoleBuffer.WriteString(0, 12, "1111111111111111", $testCell.style, 60)
        $consoleBuffer.WriteString(0, 13, "1111111111111111", $testCell.style, 30)
        $consoleBuffer.WriteString(0, 14, "1111111111111111", $testCell.style, 60)
        $consoleBuffer.WriteString(0, 15, "1111111111111111", $testCell.style, 30)
        $consoleBuffer.WriteString(5, $drawCount, "xxxxxxxxxxxxxxx", $testStyle2, 50)
        
        $consoleBuffer.Draw()
        $drawCount++
        #$consoleBuffer.Clear()
    }
    
    #Write-Host "Loop Count: " + $loopCount + $host.UI.RawUI.KeyAvailable
    
    $loopCount++
    
}   
