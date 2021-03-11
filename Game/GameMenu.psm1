using module ./Core/ANSIBuffer.psm1
using module ./Core/Pause.psm1
using module ./Core/Input.psm1
using module ./Core/LogicEnvironment.psm1


class GameMenu : LogicEnvironment {



    GameMenu ([string]$name, [ANSIBuffer]$gScreen, [Input]$gInput, [System.Diagnostics.Stopwatch]$gTime) {
        $this.name = $name
        $this.gScreen = $gScreen
        $this.gInput = $gInput
        $this.gTime = $gTime
    }
}