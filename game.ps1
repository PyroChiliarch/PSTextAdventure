#Objects

class BufferCell {
    #Properties
    [int]$depth
    [char]$char

    #Constructor
    BufferCell () {
        this.$depth = 255
        this.$char = '.'
    }
    BufferCell([int]$depth, [char]$char) {
        $this.depth = $depth
        $this.char = $char
    }
    BufferCell([BufferCell]$oldCell) {
        $this.depth = $oldCell.depth
        $this.depth = $oldCell.depth

    }
}





class ViewPort {
    #Contains 2 frame buffers which can be written to drawn
    
    #Properties
    [int]$width
    [int]$height

    #Frame buffer that contains changes
    [BufferCell[, ]]$frameBuffer
    [BufferCell]$defaultCell

    #Screen Buffer contains the last drawn screen
    [BufferCell[, ]]$screenBuffer

    #Constructor
    ViewPort ([int]$width, [int]$height, [BufferCell]$defaultCell) {
        $this.width = $width
        $this.height = $height
        $this.defaultCell = $defaultCell

        #Create frameBuffer as 2 dimensional array
        #Fill with empty defaultCells
        $this.frameBuffer = New-Object 'BufferCell[,]' $width, $height
        for ($x = 0; $x -lt $width; $x++) {
            for ($y = 0; $y -lt $height; $y++) {
                $this.frameBuffer[$x , $y] = [BufferCell]::new($defaultCell.depth, $defaultCell.char)
            }
        }
    }


    #Methods
    [void] ClearFrameBuffer () {
        for ($x = 0; $x -lt $this.width; $x++) {
            for ($y = 0; $y -lt $this.height; $y++) {
                $this.frameBuffer[$x , $y] = [BufferCell]::new($this.defaultCell.depth, $this.defaultCell.char)
                
            }
        }
    }

    
    [void] DrawFrameBuffer () {
        #Draw frame buffer as is directly to screen at current position

        #Copy to current screen buffer to update it
        $this.screenBuffer = $this.frameBuffer

        #Array with string for each row of frame buffer
        [string[]]$bufferRows = New-Object 'string[]' $this.height
        
        #Iterate each row/string
        for ($y = 0; $y -lt $this.height; $y++) {
            $bufferRows[$y] = ""
            #Fill row/string with char/cell data
            for ($x = 0; $x -lt $this.width; $x++) {
                $bufferRows[$y] += $this.frameBuffer[$x, $y].char
            }
        }

        #Write each string to screen
        for ($y = 0; $y -lt $this.height; $y++) {
            Write-Host $bufferRows[$y]
        }
    }

    [void] DrawParticle ([int]$xPos, [int]$yPos, [int]$depth , [char]$char) {
        #Out of bounds check
        if (($xPos -ge 0) -and ($xPos -lt $this.width)) {
            if (($yPos -ge 0) -and ($yPos -lt $this.height)) {
                $this.frameBuffer[$xPos, $yPos].depth = $depth
                $this.frameBuffer[$xPos, $yPos].char = $char
            }
        }
        
        
    }
    
}




class Player {
    [int]$posX = 0
    [int]$posY = 0

    Player () {

    }

}


class Input {
    

    [string] GetInputString () {
        
        #Command Prompt
        $Global:Host.UI.Write(": ")

        #The returned string
        #Built in the for loop
        [string]$fullCommand = ""
        

        while (1 -eq 1) {
            [System.Management.Automation.Host.KeyInfo]$userInput = $Global:Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

            if ($userInput.VirtualKeyCode -eq "13") {
                return $fullCommand
                
            } else {
                $fullCommand += [string]$userInput.Character
                $Global:Host.UI.Write($userInput.Character)
            }
        } 

        return "Invalid Exit in GetInputString()"
    }
}




class GameConsole {
    [string[]]$consoleHistory

    GameConsole ([int]$historyLength) {
        $this.consoleHistory = New-Object 'string[]' $historyLength
    }

    [void] Log ([string]$entry) {
        $shortenedLog = $this.consoleHistory[0..($this.consoleHistory.Length - 2)]
        $this.consoleHistory = ,$entry + $shortenedLog
    }

    [void] DrawLog ($xPos, $yPos) {
        #Move Cursor to Draw location
        $oldPos = $Global:Host.UI.RawUI.CursorPosition
        $Global:Host.UI.RawUI.CursorPosition = [System.Management.Automation.Host.Coordinates]::new($xPos,$yPos)
        
        #Draw Log
        for ($i = 0; $i -lt $this.consoleHistory.Length; $i++) {
            Write-Host $this.consoleHistory[$i]
        }

        #Move Cursor Back
        $Global:Host.UI.RawUI.CursorPosition = $oldPos
    }

}







#Functions
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
}







######################Initialise Variables

#GameInfo Vars
[int]$gameStep = 0
[bool]$stopGame = $false

#Player Vars
[Player]$player = [player]::new()

#Input Vars
[Input]$gameInput = [Input]::new()

#Viewport Vars
[int]$viewPortHeight = 10
[int]$viewPortWidth = 10
[BufferCell]$defaultBufferCell = New-Object 'BufferCell' 255, '.'
[ViewPort]$viewPort = New-Object 'ViewPort' $viewPortWidth, $viewPortHeight, $defaultBufferCell

#Console Vars
[GameConsole]$gameConsole = [GameConsole]::new(5)

#Prepare
$host.UI.RawUI.WindowTitle = 'Ardlinam'
pause('Start of Program, Press any key to continue...')

#Game Loop
while ($stopGame -eq $false) {
    
    #Prepare viewport
    $viewPort.ClearFrameBuffer()
    $viewPort.DrawParticle($player.posX, $player.posY, 10, 'O')

    #Draw viewport to screen
    Clear-Host
    $viewPort.DrawFrameBuffer()

    #Draw Console
    $gameConsole.DrawLog($host.UI.RawUI.CursorPosition.X, ($host.UI.RawUI.CursorPosition.Y + 1))

    

    #Gather Player input
    #Loop until valid input to avoid flicker
    while ($true) {
        $inputKey = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode

        if ($inputKey -eq '40') {
            #Down
            $player.posY += 1
            break
        }
        if ($inputKey -eq '39') {
            #Right
            $player.posX += 1
            break
        }
    
        if ($inputKey -eq '38') {
            #Up
            $player.posY -= 1
            break
        }
    
        if ($inputKey -eq '37') {
            #Left
            $player.posX -= 1
            break
        }
    
        if ($inputKey -eq '27') {
            #Esc
            $stopGame = $true
            break
        }
    
        if ($inputKey -eq '13') {
            #Enter
            [string]$consoleInput = $gameInput.GetInputString()
            $gameConsole.Log($consoleInput)
            
            if ($consoleInput -eq "exit") {
                $stopGame = $true
            }

            break
        }
    }
    



    $gameStep++
    #pause('End of Step, Press any key to continue...')
} 



pause('End of Program, Press any key to continue...')