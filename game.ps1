

#Includes
using namespace System.Collections.Generic
#https://docs.microsoft.com/en-us/dotnet/api/system.collections?view=netframework-4.8
using namespace System.Management.Automation.Host
#https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.host.pshostrawuserinterface?view=powershellsdk-7.0.0

#Class============
class FrameBufferCell {
    #Properties
    [int]$depth
    [char]$char

    #Constructor
    FrameBufferCell () {
        this.$depth = 255
        this.$char = '.'
    }
    FrameBufferCell([int]$depth, [char]$char) {
        $this.depth = $depth
        $this.char = $char
    }
    FrameBufferCell([FrameBufferCell]$oldCell) {
        $this.depth = $oldCell.depth
        $this.depth = $oldCell.depth
    }
    
}


class ViewPort {
    #Contains 2 frame buffers which can be written to drawn
    
    #Properties
    [int]$width
    [int]$height

    [Coordinates]$position

    #Frame buffer that contains changes
    [FrameBufferCell[, ]]$frameBuffer
    [FrameBufferCell]$defaultCell

    #Screen Buffer contains the last drawn screen
    [FrameBufferCell[, ]]$screenBuffer

    #Constructor
    ViewPort ([int]$width, [int]$height, [FrameBufferCell]$defaultCell) {
        $this.width = $width
        $this.height = $height
        $this.defaultCell = $defaultCell

        #Create frameBuffer as 2 dimensional array
        #Fill with empty defaultCells
        $this.frameBuffer = New-Object 'FrameBufferCell[,]' $width, $height
        for ($x = 0; $x -lt $width; $x++) {
            for ($y = 0; $y -lt $height; $y++) {
                $this.frameBuffer[$x , $y] = [FrameBufferCell]::new($defaultCell.depth, $defaultCell.char)
            }
        }
    }


    #Methods
    [void] ClearFrameBuffer () {
        for ($x = 0; $x -lt $this.width; $x++) {
            for ($y = 0; $y -lt $this.height; $y++) {
                $this.frameBuffer[$x , $y] = [FrameBufferCell]::new($this.defaultCell.depth, $this.defaultCell.char)
                
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
                if ($this.frameBuffer[$xPos, $yPos].depth -gt $depth) {
                    $this.frameBuffer[$xPos, $yPos].depth = $depth
                    $this.frameBuffer[$xPos, $yPos].char = $char
                }
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
            [KeyInfo]$userInput = $Global:Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

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

    [void] DrawLog ([Coordinates]$position) {
        #Move Cursor to Draw location
        $oldPos = $Global:Host.UI.RawUI.CursorPosition
        $Global:Host.UI.RawUI.CursorPosition = [Coordinates]::new($position.X, $position.Y)
        
        #Draw Log
        for ($i = 0; $i -lt $this.consoleHistory.Length; $i++) {
            Write-Host $this.consoleHistory[$i]
        }

        #Move Cursor Back
        $Global:Host.UI.RawUI.CursorPosition = $oldPos
    }

}


class Voxel {
    [char]$voxelData

    Voxel () {
        $this.voxelData = '-'
    }
}


class Chunk {

    [Voxel[,]]$chunkData

    Chunk () {
        $this.chunkData = [Voxel[,]]::new()
    }

}


class World {
    
    [Dictionary[Coordinates,Chunk]]$chunkData

    World () {
        $this.chunkData = [Dictionary[Coordinates,Chunk]]::new()
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
[int]$viewPortHeight = 20
[int]$viewPortWidth = $host.UI.RawUI.BufferSize.Width
[FrameBufferCell]$defaultFrameBufferCell = New-Object 'FrameBufferCell' 255, '.'
[ViewPort]$viewPort = New-Object 'ViewPort' $viewPortWidth, $viewPortHeight, $defaultFrameBufferCell

#Console Vars
[GameConsole]$gameConsole = [GameConsole]::new(5)

#Prepare
$host.UI.RawUI.WindowTitle = 'Ardlinam'
[Console]::CursorVisible = $false

<#Write-Host $host.UI.RawUI.MaxPhysicalWindowSize #192.63
$host.UI.RawUI.BufferSize = [Size]::new(192,63)
$host.UI.RawUI.WindowSize = [Size]::new(192,63)
$host.UI.RawUI.CursorPosition = [Coordinates]::new(191,62)
Write-Host 'X'#>
pause('Start of Program, Press any key to continue...')



#Game Loop
while ($stopGame -eq $false) {
    
    #Prepare viewport
    $viewPort.ClearFrameBuffer()
    $viewPort.DrawParticle($player.posX, $player.posY, 10, 'O')
    #Draw on Background for testing
    $viewPort.DrawParticle(0, 0, 20, 'X')
    $viewPort.DrawParticle(5, 3, 20, 'X')
    $viewPort.DrawParticle(3, 7, 20, 'X')
    $viewPort.DrawParticle(7, 8, 20, 'X')

    $viewPort.DrawParticle(3, 2, 5, 'M')
    $viewPort.DrawParticle(9, 0, 5, 'M')
    $viewPort.DrawParticle(2, 5, 5, 'M')

    #Draw viewport to screen
    Clear-Host
    $viewPort.DrawFrameBuffer()

    #Draw Console
    [Coordinates]$drawConsolePosition = [Coordinates]::new($host.UI.RawUI.CursorPosition.X, $host.UI.RawUI.CursorPosition.Y + 1)
    $gameConsole.DrawLog($drawConsolePosition)

    

    #Gather Player input
    #Loop until valid input to avoid flicker
    while ($true) {

        $host.UI.RawUI.FlushInputBuffer() #Stop Movement after key release, Input can build up if held
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
            [Console]::CursorVisible = $true
            [string]$consoleInput = $gameInput.GetInputString().ToLower()
            
            #dont write logs if an empty command is given
            if ($consoleInput -ne "") {
                $gameConsole.Log(" - " + $consoleInput)
            }
            
            
            if ($consoleInput -eq "exit") {
                $stopGame = $true
                Write-Host ""
            }

            if ($consoleInput -eq "help") {
                $gameConsole.Log("No help available at this time")
            }

            [Console]::CursorVisible = $false
            break
        }
    }
    



    $gameStep++
    #pause('End of Step, Press any key to continue...')
} 


Clear-Host
pause('End of Program, Press any key to continue...')