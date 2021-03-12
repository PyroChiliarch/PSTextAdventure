using module ./Core/ANSIBuffer.psm1
using module ./Core/Pause.psm1
using module ./Core/Input.psm1
using module ./Core/LogicEnvironment.psm1


class GameMenu : LogicEnvironment {

    [int]$menuSelection
    $menuItems = @('Quick Start', 'Advanced Start', 'Load Game', 'Options', 'Exit')
    $menuActions = @('newGame', '', '', '', 'prev')

    [string]$textStyle = [ANSIBufferCell]::CreateStyle(0, 255, 0, 0, 0, 0, $false, $false)
    [string]$selectedTextStyle = [ANSIBufferCell]::CreateStyle(0, 255, 0, 0, 0, 0, $true, $false)


    GameMenu ([string]$name, [ANSIBuffer]$gScreen, [Input]$gInput, [System.Diagnostics.Stopwatch]$gTime, [ExitCode]$prevExitCode) {
        $this.name = $name
        $this.gScreen = $gScreen
        $this.gInput = $gInput
        $this.gTime = $gTime
        $this.prevExitCode = $prevExitCode
    }



    [ExitCode] Update () {

        $this.gScreen.Clear()
        $this.WriteScreen()
        $this.gScreen.Draw()

        $this.gInput.UpdateInput()

        return $this.ReadInput()
    }

    [void] WriteScreen () {

        #Draw all menu items
        for ($n = 0; $n -lt $this.menuItems.count; $n++) {

            #Select style based on selection
            [string]$currentStyle = ""
            if ($this.menuSelection -eq $n) {
                $currentStyle = $this.selectedTextStyle
            } else {
                $currentStyle = $this.textStyle
            }

            #Draw the menu item
            $this.gScreen.WriteString(0, $n, $this.menuItems[$n], $currentStyle, 50)
        }

        

    }

    [string] ReadInput () {




        if ($this.gInput.currentKey.VirtualKeyCode -eq [KeyID]::down -and $this.gInput.currentKey.KeyDown) {
            if ($this.menuSelection -lt ($this.menuItems.count - 1)) {
                $this.menuSelection++
            }
        }

        if ($this.gInput.currentKey.VirtualKeyCode -eq [KeyID]::up -and $this.gInput.currentKey.KeyDown) {
            if ($this.menuSelection -gt 0) {
                $this.menuSelection--
            }
        }

        if ($this.gInput.currentKey.VirtualKeyCode -eq [KeyID]::enter -and $this.gInput.currentKey.KeyDown) {
            return $this.menuActions[$this.menuSelection]
        }

        return ""
    }
}