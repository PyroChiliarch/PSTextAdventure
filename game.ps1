
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


Import-Module .\Pause.psm1



class ANSIBufferCell {

    [char]$character
    [string]$styleStart
    [string]$styleEnd
    

    ANSIBufferCell ([char]$character, [string]$styleStart, [string]$styleEnd) {
        $this.character = $character
        $this.styleStart = $styleStart
        $this.styleEnd = $styleEnd
    }

    [ANSIBufferCell] Clone () {
        [ANSIBufferCell]$newCell = [ANSIBufferCell]::new($this.character, $this.styleStart, $this.styleEnd)
        return $newCell
    }

}

class ANSIBuffer {

    [int]$width
    [int]$height
    [ANSIBufferCell[,]]$buffer

    ANSIBuffer ([int]$width, [int]$height) {
        [Console]::CursorVisible = $false
        $this.buffer = [ANSIBufferCell[,]]::new($width, $height)
        $this.height = $height
        $this.width = $width
    }
    
    [void] FillBuffer ([ANSIBufferCell]$cell) {
        for ($x = 0; $x -lt $this.width; $x++) {
            for ($y = 0; $y -lt $this.height; $y++) {
                $this.buffer[$x, $y] = $cell.Clone()
            }
        }
    }

    [void] ClearBuffer () {
        [ANSIBufferCell]$cell = [ANSIBufferCell]::new(' ', "", "")
        for ($x = 0; $x -lt $this.width; $x++) {
            for ($y = 0; $y -lt $this.height; $y++) {
                $this.buffer[$x, $y] = $cell.Clone()
            }
        }
    }

    [void] DrawBuffer () {
        $Global:Host.UI.RawUI.CursorPosition = [Coordinates]::new(0, 0)
        #Draw Buffer

        [string]$drawString = ""
        for ($y = 0; $y -lt $this.height; $y++) {
            for ($x = 0; $x -lt $this.width; $x++) {
                $drawString += $this.buffer[$x, $y].character
            }

            #Add new line after each line
            $drawString += "`r`n"

        }


        Write-Host $drawString
    }

}

<#

Function pause ($message) {
    # Check if running Powershell ISE
    if ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    }
    else {
        Write-Host "$message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}#>




#Support Checks
Clear-Host
Write-Host "Parse Complete"
Write-Host "$($host.version.Major).$($host.version.Minor) : Powershell Version" #Game built in v5.1
if ( [int]("" + $($host.version.Major) + $($host.version.Minor)) -lt 51) {Pause "WARNING: Powershell Version less than v5.1`r`nExiting"; throw "Resources Error"}
Write-Host "$($Host.UI.SupportsVirtualTerminal) : Virtual Terminal Support" #required for `e and colours
if ($($Host.UI.SupportsVirtualTerminal) -eq $false) {Pause "WARNING: Virtual Terminal not supported`r`nExiting"; throw "Resources Error"} 
Pause("Load Complete, Press any key to continue")


#Initialise Objects
[ANSIBuffer]$consoleBuffer = [ANSIBuffer]::new(10, 10)
$consoleBuffer.FillBuffer([ANSIBufferCell]::new('X', "", ""))



#Enter main loop


while ($true) {

    
    

    #Input Get

    #Gameworld Update
    
    $consoleBuffer.DrawBuffer()
    Write-Host "asdf"



}   
