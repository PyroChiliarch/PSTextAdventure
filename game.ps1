#Objects
class bufferCell
{
    #Properties
    [int]$depth
    [char]$char

    #Constructor
    bufferCell () {
        this.$depth = 0
        this.$char = '...'
    }
    bufferCell([int]$depth, [char]$char) {
        $this.depth = $depth
        $this.char = $char
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


Function drawViewPort ()
{
    $bufferHeight = 5
    $bufferWidth = 10

    #Create Initialis frameBuffer as 2 dimensional array
    #Fills with empty bufferCells
    $frameBuffer = New-Object 'bufferCell[,]' $bufferWidth,$bufferHeight
    for ($x = 0; $x -lt $bufferWidth; $x++) {
        for ($y = 0; $y -lt $bufferHeight; $y++) {
            $frameBuffer[$x,$y] = New-Object 'bufferCell' 0,'.'
        }
    }

    
    Write-Output $frameBuffer[0,2].char
}








#Initialise Variables
$PlayerName = 'none'
$PlayerMoney = 0
$PlayerX = 0
$PlayerY = 0


$mapHeight = 100
$mapWidth = 100
$mapFloor = '.'

$viewPortHeight = 10
$viewPortWidth = 10

#Prepare
Clear-Host
$host.UI.RawUI.WindowTitle = 'Ardlinam'

#Get Player Name
Clear-Host
Write-Output 'Welcome to Ardlinam'

drawViewPort

$Input = Read-Host -Prompt 'Please enter your name.'
$PlayerName = $Input

#Instructions
Clear-Host
Write-Output "Welcome to Ardlinam $PlayerName `n"
Write-Output 'Please read the below instructions'
Write-Output 'type "help" to list available commands'
Write-Output "commands are not case sensitive `n"
pause('Press any key to begin your adventure!')









pause('End of Program, Press any key to continue...')