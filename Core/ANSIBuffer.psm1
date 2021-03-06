using namespace System.Management.Automation.Host
#https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.host.pshostrawuserinterface?view=powershellsdk-7.0.0

<#
General Use

ANSIBuffer.Clear()  #Clear Buffer to default
ANSIBuffer.Write*() #Write to the buffer
ANSIBuffer.Draw()   #Draw the buffer on screen


TODO Methods
WriteBuffer
WriteLog

Could possibly be changed to update only parts of screen that have changed
Tag all the cells that are the same
#>

class ANSIBufferCell {

    [char]$character
    [string]$style
    [byte]$depth

    ANSIBufferCell ([char]$character, [string]$style, [byte]$depth) {
        $this.character = $character
        $this.style = $style
        $this.depth = $depth
    }


    [ANSIBufferCell] Clone () {
        #clone this object
        [ANSIBufferCell]$newCell = [ANSIBufferCell]::new($this.character, $this.style, $this.depth)
        return $newCell
    }


    static [string] CreateStyle ([byte]$foreR, [byte]$foreG, [byte]$foreB, [byte]$backR, [byte]$backG, [byte]$backB, [bool]$invert, [bool]$underline) {
        #Note: All added strings add ; at the start except the first
        #Syle is build using ANSI codes that are placed at the beginning of a write to console

        #All important escape code
        [char]$e = [char]0x1b

        #Style start
        [string]$newStyle = "$($e)[" 

        #Foreground color
        $newStyle += "38;2;$($foreR);$($foreG);$($foreB)"

        #Background Color
        $newStyle += ";48;2;$($backR);$($backG);$($backB)"

        #Invert
        if ($invert -eq $true) {
            $newStyle += ";7"
        }

        if ($underline -eq $true) {
            $newStyle += ";4"
        }

        #Terminate the style
        $newStyle += "m"

        return $newStyle
    }
}

class ANSIBuffer {

    #Buffer Size
    [int]$width
    [int]$height

    #buffer array
    [ANSIBufferCell[,]]$buffer
    
    #Cell used when clearing buffer
    [ANSIBufferCell]$clearCell
    [ANSIBufferCell[,]]$clearBuffer #Require to shave 700ms of draw time

    #ANSI clear string
    [char]$e = [char]0x1b

    ANSIBuffer ([int]$width, [int]$height) {
        #Defaults to Blank Black ClearCell

        [Console]::CursorVisible = $false
        $this.buffer = [ANSIBufferCell[,]]::new($width, $height)
        $this.height = $height
        $this.width = $width
        $this.clearCell = [ANSIBufferCell]::new(' ', [ANSIBufferCell]::CreateStyle(0, 0, 0, 0, 0, 0, $false, $false), 255)
    }

    ANSIBuffer ([int]$width, [int]$height, [ANSIBufferCell]$clearCell) {
        [Console]::CursorVisible = $false
        $this.buffer = [ANSIBufferCell[,]]::new($width, $height)
        $this.height = $height
        $this.width = $width
        $this.clearCell = $clearCell
    }
    
    [void] Clear () {
        #Fill buffer is clearCell
        
        #Create the clearBuffer if it doesn't exist yet
        if ($null -eq $this.clearBuffer) {
            
            for ($x = 0; $x -lt $this.width; $x++) {
                for ($y = 0; $y -lt $this.height; $y++) {
                    $this.buffer[$x, $y] = $this.clearCell.Clone()
                }
            }
            $this.clearBuffer = $this.buffer.Clone()
        }

        #Clear the buffer
        $this.buffer = $this.clearBuffer.Clone()
    }


    [void] Resize ([int]$width, [int]$height) {
        #Change buffer size and clear
        $this.buffer = [ANSIBufferCell[,]]::new($width, $height)
        $this.ClearBuffer()
    }

    [void] Draw () {
        $Global:Host.UI.RawUI.CursorPosition = [Coordinates]::new(0, 0)
        #Draw Buffer
        
        #0x0000 is a null character, stops null error and doesn't affect drawing
        [ANSIBufferCell]$prevCell = [ANSIBufferCell]::new([char]0x0000,"", 255)
        [string]$drawString = ""
        for ($y = 0; $y -lt $this.height; $y++) {
            for ($x = 0; $x -lt $this.width; $x++) {
                
                #Do this for each Cell
                if ($this.buffer[$x, $y].style -ne $prevCell.style) {
                    $drawString += "$($this.e)[0m"
                    $drawString += $this.buffer[$x, $y].style
                    $drawString += $this.buffer[$x, $y].character
                } else {
                    $drawString += $this.buffer[$x, $y].character
                }

                $prevCell = $this.buffer[$x, $y]
                
                
                
            }

            #Do for Each line
            $drawString += "`r`n"
        }

        #close off last cell style ending
        $drawString += "$($this.e)[0m"

        #Draw final string to console
        Write-Host $drawString
    }

    [void] WriteCell ([int]$posX, [int]$posY, [ANSIBufferCell]$cell) {
        #return true/false on failure/success
        #Check bounds
        if ($posX -lt $this.width -and $posY -lt $this.height) {
            #check Depth
            if ($cell.depth -le $this.buffer[$posX, $posY].depth) {
                $this.buffer[$posX, $posY] = $cell.Clone()
            }
        }
    }
    

    [void] WriteString ([int]$posX, [int]$posY, [string]$string, [string]$style, [byte]$depth) {
        #check out of bounds Y
        #X check is done per cell in for loop
        if ($posY -gt $this.height -or $posY -lt 0) {
            return
        }

        #Change string to array
        $stringArray = $string.ToCharArray()

        #Loop Cells
        for ($x = 0; $x -lt $string.Length; $x++) {
            #Check bounds
            if ($x -gt -1 -and $x -lt $this.width) {
                #check Depth
                if ($depth -le $this.buffer[($x + $posX), $posY].depth) {
                    $this.buffer[($x + $posX), $posY] = [ANSIBufferCell]::new([char]$stringArray[$x], $style, $depth)
                }
                
            }
        }
    }
    

    

}

