#Objects

class BufferCell
{
    #Properties
    [int]$depth
    [char]$char

    #Constructor
    BufferCell () {
        this.$depth = 0
        this.$char = '...'
    }
    BufferCell([int]$depth, [char]$char) {
        $this.depth = $depth
        $this.char = $char
    }


}








class ViewPort
{
    #Contains 2 frame buffers which can be written to drawn
    
    #Properties
    [int]$width
    [int]$height

    [BufferCell[,]]$frameBuffer
    [BufferCell]$defaultValue

    #Constructor
    ViewPort ([int]$width, [int]$height, [BufferCell]$defaultValue)
    {
        $this.width = $width
        $this.height = $height
        $this.defaultValue = $defaultValue

        #Create frameBuffer as 2 dimensional array
        #Fill with empty defaultCells
        $this.frameBuffer = New-Object 'BufferCell[,]' $width,$height
        for ($x = 0; $x -lt $width; $x++) {
            for ($y = 0; $y -lt $height; $y++) {
                $this.frameBuffer[$x ,$y] = $defaultValue #$x requires space in front of it
            }
        }


    }


    #Methods
    [void]ClearFrameBuffer ([viewPort]$self) {
        for ($x = 0; $x -lt $self.width; $x++) {
            for ($y = 0; $y -lt $self.height; $y++) {
                $self.frameBuffer[$x ,$y] = $self.defaultValue
            }
        }
    }

    
    [void]DrawFrameBuffer () {
        #Draw frame buffer as is directly to screen at current position

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
[BufferCell]$defaultBufferCell = New-Object 'BufferCell' 0,'.'
[ViewPort]$viewPort = New-Object 'ViewPort' $viewPortWidth,$viewPortHeight,$defaultBufferCell



#Prepare
Clear-Host
$host.UI.RawUI.WindowTitle = 'Ardlinam'


#Draw World



#testing========================================

pause('End of Program, Press any key to continue...')
#Write-Output $viewPort.frameBuffer[0,2].char

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