using module ./Core/ANSIBuffer.psm1
using module ./Core/Pause.psm1
using module ./Core/Input.psm1
using module ./Core/LogicEnvironment.psm1


class GameConnect4 : LogicEnvironment {

    

    [string]$groundStyle = [ANSIBufferCell]::CreateStyle(0, 100, 0, 0, 0, 0, $false, $false)
    [string]$playerStyle = [ANSIBufferCell]::CreateStyle(255, 255, 255, 0, 100, 0, $false, $false)
    [string]$guiStyle = [ANSIBufferCell]::CreateStyle(255, 255, 255, 0, 100, 100, $false, $false)
    

    GameConnect4 ([string]$name, [ANSIBuffer]$gScreen, [Input]$gInput, [System.Diagnostics.Stopwatch]$gTime, [ExitCode]$prevExitCode) {
        $this.name = $name
        $this.gScreen = $gScreen
        $this.gInput = $gInput
        $this.gTime = $gTime
        $this.prevExitCode = $prevExitCode
    }



    [ExitCode] Update () {

        #Draw
        $this.gScreen.Clear()
        $this.WriteScreen()
        $this.gScreen.Draw()

        #Act on input
        $this.gInput.UpdateInput()
        return $this.ReadInput() #Returns Exit code
        
        #Update game world
    }

    [void] WriteScreen () {

        $this.gScreen.WriteString(0, 0, "Connect 4", $this.guiStyle, 240)

    }

    [ExitCode] ReadInput () {



        #Leave game world and return to menu
        if ($this.gInput.currentKey.VirtualKeyCode -eq [KeyID]::esc -and $this.gInput.currentKey.KeyDown) {
            return [Exitcode]::new("prev")
        }

        if ($this.gInput.currentKey.VirtualKeyCode -eq [KeyID]::up -and $this.gInput.currentKey.KeyDown) {
            
        }

        if ($this.gInput.currentKey.VirtualKeyCode -eq [KeyID]::enter -and $this.gInput.currentKey.KeyDown) {
            
        }

        return ""
    }
}