#Todo



#Enable ANSI Escape codes using GetConsoleMode
#https://stackoverflow.com/questions/38045245/how-to-call-getstdhandle-getconsolemode-from-powershell
#https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
#https://docs.microsoft.com/en-us/windows/console/getconsolemode
#https://docs.microsoft.com/en-us/windows/console/setconsolemode
#
#May require using WriteConsole
#https://docs.microsoft.com/en-us/windows/console/writeconsole
#
#Allows
#Multiple colours in one string
#Underline or bold
#DEC line drawing mode
#Triggering certain button presses from write-host
#Being super fancy in general




#Create my own window buffer so i can draw the whole thing in one go
##Requires ANSI escape codes for different colours in one string
#Will Stop flickering







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
    [int]$posX
    [int]$posY

    [int]$width
    [int]$height

    

    [Coordinates]$position

    #Frame buffer that contains changes
    [FrameBufferCell[, ]]$frameBuffer
    [FrameBufferCell]$defaultCell

    #Screen Buffer contains the last drawn screen
    [FrameBufferCell[, ]]$screenBuffer

    #Constructor
    ViewPort ([int]$posX, [int]$posY, [int]$width, [int]$height, [FrameBufferCell]$defaultCell) {
        
        

        $this.posX = $posX
        $this.posY = $posY
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


    [void] DrawTerrain ([World]$gameWorld) {
        #Draw terrain from world to viewport
        for ($x = 0; $x -lt ($this.width); $x++) {
            for ($y = 0; $y -lt ($this.height); $y++) {
                $this.frameBuffer[$x, $y].char = $gameWorld.GetVoxel($x + $this.posX, $y + $this.posY).voxelData
                $this.frameBuffer[$x, $y].depth = 255
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

        <#Write each string to screen
        for ($y = 0; $y -lt $this.height; $y++) {
            Write-Host $bufferRows[$y]
        }#>

        #Large String
        [string]$bufferString = ""
        for ($y = 0; $y -lt $this.height; $y++) {
            $bufferString = $bufferString + $bufferRows[$y] + "`r`n"
        }

        Write-Host $bufferString
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


class TerrainVoxel {
    [char]$voxelData

    TerrainVoxel ($xPos, $yPos) {
        if ((Get-Random -Maximum 20) -lt 15) {
            $this.voxelData = ','
        } else {
            $this.voxelData = '.'
        }

        if ((Get-Random -Maximum 20) -lt 1) {
            $this.voxelData = [char]0x2663
        }

        #$this.voxelData = 'x'
        
    }
}


class TerrainChunk {

    [TerrainVoxel[,]]$voxelData

    TerrainChunk ($chunkSize) {
        $this.voxelData = [TerrainVoxel[,]]::new($chunkSize,$chunkSize)
        
        for ($x = 0; $x -lt $chunkSize; $x++) {
            for ($y = 0; $y -lt $chunkSize; $y++) {
                
                [TerrainVoxel]$newVoxel = [TerrainVoxel]::new($x, $y)
                $this.voxelData[$x, $y] = $newVoxel
            }
        }
    }

}


class World {
    
    [Dictionary[Coordinates,TerrainChunk]]$chunkData
    [int]$chunkSize

    World ([int]$chunkSize) {
        $this.chunkData = [Dictionary[Coordinates,TerrainChunk]]::new()
        $this.chunkSize = $chunkSize
    }

    [TerrainVoxel] GetVoxel ([int]$xPos, [int]$yPos) {
        #Get Chunk position
        $chunkX = [int]([Math]::Floor([float]$xPos / [float]$this.chunkSize))
        $chunkY = [int]([Math]::Floor([float]$yPos / [float]$this.chunkSize))
        [Coordinates]$chunkPos = [Coordinates]::new($chunkX, $chunkY)

        #Get Voxel position in chunk
        $relVoxelX = $xPos % $this.chunkSize
        $relVoxelY = $yPos % $this.chunkSize

        #Build chunk if its null
        if ($null -eq $this.chunkData[$chunkPos]) {
            [TerrainChunk]$newChunk = [TerrainChunk]::new($this.chunkSize)
            $this.chunkData.Add($chunkPos, $newChunk)
        }

        #Get Chunk and voxel
        [TerrainChunk]$chunk = $this.chunkData[$chunkPos]
        [TerrainVoxel]$voxel = $chunk.voxelData[$relVoxelX, $relVoxelY]

        #Return voxel
        return $voxel
    }

    [Coordinates] ScreenPosToWorldPos ([int]$screenX, [int]$screenY, [ViewPort]$viewPort) {
        #Works on a position on the viewport
        [Coordinates]$truePos = [Coordinates]::new($screenX + $viewPort.posX, $screenY + $viewPort.posY)

        return $truePos
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
[int]$viewPortWidth = 30
[FrameBufferCell]$defaultFrameBufferCell = New-Object 'FrameBufferCell' 255,'.'
[ViewPort]$viewPort = [ViewPort]::new(0, 0, $viewPortWidth, $viewPortHeight, $defaultFrameBufferCell)

#Console Vars
[GameConsole]$gameConsole = [GameConsole]::new(5)

#World Vars
[World]$gameWorld = [World]::new(10)

#Prepare
$host.UI.RawUI.WindowTitle = 'Ardlinam'
[Console]::CursorVisible = $false


#Write-Host $gameWorld.GetVoxel(-1, -200).voxelData
Clear-Host
#Write-Host $Global:Host.UI.RawUI.BackgroundColor
Write-Host "Start of Program..."

<#$MethodDefinitions = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr GetStdHandle(int nStdHandle);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
'@
$Kernel32 = Add-Type -MemberDefinition $MethodDefinitions -Name 'Kernel32' -Namespace 'Win32' -PassThru
$hConsoleHandle = $Kernel32::GetStdHandle(-11) # STD_OUTPUT_HANDLE 
$mode = 0
$Kernel32::GetConsoleMode($hConsoleHandle, [ref]$mode)
Write-Host "$($mode)"#>
#Write-Host "[101;93m STYLES [0m"

Write-Host "$($host.version.Major).$($host.version.Minor) : Powershell Version" #Game built in v5.1
Write-Host "$($Host.UI.SupportsVirtualTerminal) : Virtual Terminal Support" #required for `e and colours
pause('Press any key to continue...')







#Game Loop
while ($stopGame -eq $false) {
    
    #Prepare viewport
    $viewPort.ClearFrameBuffer()
    $viewPort.DrawTerrain($gameWorld)
    #pause("asdf")
    #$Global:Host.UI.RawUI. = [Coordinates]::new($position.X, $position.Y)
    $viewPort.DrawParticle($player.posX, $player.posY, 10, 'X')

    #Draw viewport to screen
    #Clear-Host
    $Global:Host.UI.RawUI.CursorPosition = [Coordinates]::new(0, 0)
    $viewPort.DrawFrameBuffer()

    #Draw Console
    [Coordinates]$drawConsolePosition = [Coordinates]::new($host.UI.RawUI.CursorPosition.X, $host.UI.RawUI.CursorPosition.Y + 1)
    $gameConsole.DrawLog($drawConsolePosition)

    

    #Gather Player input
    #Loop until valid input to avoid flicker
    while ($true) {

        $host.UI.RawUI.FlushInputBuffer() #Stop Movement after key release, Input can build up if held
        $inputKey = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode

        #==Cursor Movement
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

        #==Window Movement
        if ($inputKey -eq '65') {
            #A
            $viewPort.posX -= 1
            break
        }

        if ($inputKey -eq '68') {
            #D
            $viewPort.posX += 1
            break
        }

        if ($inputKey -eq '87') {
            #W
            $viewPort.posY -= 1
            break
        }
        
        if ($inputKey -eq '83') {
            #S
            $viewPort.posY += 1
            break
        }

        #==Commands
        if ($inputKey -eq '32') {
            #Space
            [Coordinates]$cursorPos = $gameWorld.ScreenPosToWorldPos($player.posX, $player.posY, $viewPort)
            $gameConsole.Log("Pos: $($cursorPos.X), $($cursorPos.Y)")
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
Clear-Host