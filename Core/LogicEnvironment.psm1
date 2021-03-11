#Designed as an area in which logic code executes
#You should use multiple, but only have one active at a time.
#Eg, Main Menu, Gameworld < Have these as seperate gameEnvironments

#Each environment requires being passed the objects it needs, such as the screen, time and input


using module ./Core/ANSIBuffer.psm1
using module ./Core/Pause.psm1
using module ./Core/Input.psm1



class LogicEnvironment {

    [string]$name
    [ANSIBuffer]$gScreen
    [Input]$gInput
    [System.Diagnostics.Stopwatch]$gTime


    GameEnvironment ([string]$name, [ANSIBuffer]$gScreen, [Input]$gInput, [System.Diagnostics.Stopwatch]$gTime) {

    }

    [bool] Update () {
        #Return true to exit
        Pause("Error : $($this.name) : Update() Not Implemented")
        return $true
    }


    
}

