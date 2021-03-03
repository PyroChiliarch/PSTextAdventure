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

Function drawMap ($px, $py)
{
    $mapWidth = 10
    $mapHeight = 10
    for ()
}

#Initialise Variables
$PlayerName = 'none'
$PlayerMoney = 0
$PlayerX = 0
$PlayerY = 0

#Prepare
Clear-Host
$host.UI.RawUI.WindowTitle = 'Ardlinam'

Clear-Host
Write-Output 'Welcome to Ardlinam'
$Input = Read-Host -Prompt 'Please enter your name.'
$PlayerName = $Input

Clear-Host
Write-Output "Welcome to Ardlinam $PlayerName `n"
Write-Output 'Please read the below instructions'
Write-Output 'type "help" to list available commands'
Write-Output "commands are not case sensitive `n"
pause('Press any key to begin your adventure!')









pause('End of Program, Press any key to continue...')