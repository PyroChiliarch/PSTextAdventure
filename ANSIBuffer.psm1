using namespace System.Management.Automation.Host
#https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.host.pshostrawuserinterface?view=powershellsdk-7.0.0

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
        
        #0x0000 is a null character, stops null error and doesn't affect drawing
        [ANSIBufferCell]$prevCell = [ANSIBufferCell]::new([char]0x0000,"","")
        [string]$drawString = ""
        for ($y = 0; $y -lt $this.height; $y++) {
            for ($x = 0; $x -lt $this.width; $x++) {
                
                if ($this.buffer[$x, $y].styleStart -ne $prevCell.styleStart) {
                    $drawString += $prevCell.styleEnd
                    $drawString += $this.buffer[$x, $y].styleStart
                    $drawString += $this.buffer[$x, $y].character
                } else {
                    $drawString += $this.buffer[$x, $y].character
                }

                $prevCell = $this.buffer[$x, $y]
                
                
                
            }

            #Add new line after each line
            $drawString += "`r`n"
        }

        #close off last cell style ending
        $drawString += $prevCell.styleEnd

        Write-Host $drawString
    }
}

