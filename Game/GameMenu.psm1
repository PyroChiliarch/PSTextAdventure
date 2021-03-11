using module ./Core/ANSIBuffer.psm1
using module ./Core/Pause.psm1
using module ./Core/Input.psm1
using module ./Core/LogicEnvironment.psm1


class GameMenu : LogicEnvironment {

    [int]$menuSelection
    [string]$textStyle = [ANSIBufferCell]::CreateStyle(255, 0, 0, 0, 0, 0, $false, $false)
    [string]$selectedTextStyle = [ANSIBufferCell]::CreateStyle(255, 0, 0, 0, 0, 0, $true, $false)


    GameMenu ([string]$name, [ANSIBuffer]$gScreen, [Input]$gInput, [System.Diagnostics.Stopwatch]$gTime) {
        $this.name = $name
        $this.gScreen = $gScreen
        $this.gInput = $gInput
        $this.gTime = $gTime
    }


    [ExitCode] Update () {

        $this.gScreen.Clear()
        $this.WriteScreen()
        $this.gScreen.Draw()

        $this.gInput.UpdateInput()
        
        return $this.ReadInput()
    }

    [void] WriteScreen () {


        $this.gScreen.WriteString(0, 0, "1:Start Game", $this.textStyle, 50)
        $this.gScreen.WriteString(0, 1, "2:Exit", $this.textStyle, 50)

    }

    [string] ReadInput () {
        if ($this.gInput.currentKey.VirtualKeyCode -eq [KeyID]::one) {
            return "standardGame"
        }

        if ($this.gInput.currentKey.VirtualKeyCode -eq [KeyID]::two) {
            return "prev"
        }
        return ""
    }
}