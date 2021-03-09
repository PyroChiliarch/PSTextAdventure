
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
#>

class ANSIBufferCell {

    [char]$character
    [string]$styleStart
    [string]$styleEnd
    

    ANSIBufferCell ([char]$character, [string]$styleStart, [string]$styleEnd) {
        $this.character = $character
        $this.styleStart = $styleStart
        $this.styleEnd = $styleEnd
    }

}

class ANSIBuffer {

    [ANSIBufferCell[,]]$buffer = [ANSIBufferCell[,]]::new()

}



while ($true) {


}   
