#Objects

class BufferCell
{
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

class Sprite
{
    [char[,]]$image
    [int]$width
    [int]$height
    [int]$xOrigin
    [int]$yOrigin


    Sprite ([int]$width, [int]$height, [int]$xOrigin, [int]$yOrigin, [char[,]]$image) {
        $this.width = $width
        $this.height = $height
        $this.xOrigin = $xOrigin
        $this.yOrigin = $yOrigin
        $this.image = New-Object 'char[,]' $this.width,$this.height
    }
}




class ViewPort
{
    #Contains 2 frame buffers which can be written to drawn
    
    #Properties
    [int]$width
    [int]$height

    #Frame buffer that contains changes
    [BufferCell[,]]$frameBuffer
    [BufferCell]$defaultCell

    #Screen Buffer contains the last drawn screen
    [BufferCell[,]]$screenBuffer

    #Constructor
    ViewPort ([int]$width, [int]$height, [BufferCell]$defaultCell)
    {
        $this.width = $width
        $this.height = $height
        $this.defaultCell = $defaultCell

        #Create frameBuffer as 2 dimensional array
        #Fill with empty defaultCells
        $this.frameBuffer = New-Object 'BufferCell[,]' $width,$height
        for ($x = 0; $x -lt $width; $x++) {
            for ($y = 0; $y -lt $height; $y++) {
                $this.frameBuffer[$x ,$y] = [BufferCell]::new($defaultCell.depth, $defaultCell.char)
            }
        }
    }


    #Methods
    [void] ClearFrameBuffer ([viewPort]$self) {
        for ($x = 0; $x -lt $self.width; $x++) {
            for ($y = 0; $y -lt $self.height; $y++) {
                $this.frameBuffer[$x ,$y] = [BufferCell]::new($this.defaultCell.depth, $this.defaultCell.char)
                
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
                $bufferRows[$y] += $this.frameBuffer[$x,$y].char
            }
        }

        #Write each string to screen
        for ($y = 0; $y -lt $this.height; $y++) {
            Write-Host $bufferRows[$y]
        }
    }

    [void] DrawParticle ([int]$xPos, [int]$yPos, [int]$depth ,[char]$char) {
        
        $this.frameBuffer[$xPos,$yPos].depth = $depth
        $this.frameBuffer[$xPos,$yPos].char = $char
        Write-Host "Drawing Particle $($xPos), $($yPos), $($char)"
        
    }
    
}
















#Functions
Function pause ($message)
{
    # Check if running Powershell ISE
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    }
    else
    {
        Write-Host "$message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}







######################Initialise Variables


#Viewport
$viewPortHeight = 10
$viewPortWidth = 10
[BufferCell]$defaultBufferCell = New-Object 'BufferCell' 255,'.'
[ViewPort]$viewPort = New-Object 'ViewPort' $viewPortWidth,$viewPortHeight,$defaultBufferCell



#Prepare
Clear-Host
$host.UI.RawUI.WindowTitle = 'Ardlinam'


#Draw World



#testing========================================

pause('Start of Program, Press any key to continue...')
#Write-Output $viewPort.frameBuffer[0,2].char
<#$image = New-Object 'char[,]' 2,2

$image[0,0] = 'a'
$image[1,0] = 'b'
$image[0,1] = 'c'
$image[1,1] = 'd'

$sprite = New-Object 'Sprite' 2,2,0,0,$image#>

Write-Host $viewPort.frameBuffer[0,0].char
$viewPort.DrawParticle(1,1,10,'a')
Write-Host $viewPort.frameBuffer[0,0].char

$viewPort.DrawFrameBuffer()
#Write-Output ("" + $port.frameBuffer[0,1].char)



<#$Input = Read-Host -Prompt 'Please enter your name.'
$PlayerName = $Input

#Instructions
Clear-Host
Write-Output "Welcome to Ardlinam $PlayerName `n"
Write-Output 'Please read the below instructions'
Write-Output 'type "help" to list available commands'
Write-Output "commands are not case sensitive `n"
pause('Press any key to begin your adventure!')




#>
pause('End of Program, Press any key to continue...')