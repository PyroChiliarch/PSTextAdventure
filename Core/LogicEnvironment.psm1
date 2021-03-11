#Designed as an area in which logic code executes
#You should use multiple, but only have one active at a time.
#Eg, Main Menu, Gameworld < Have these as seperate gameEnvironments

#Each environment requires being passed the objects it needs, such as the screen, time and input

#In General
#Screen, Input and time will be the same objects across all your logic environments


using module ./Core/ANSIBuffer.psm1
using module ./Core/Pause.psm1
using module ./Core/Input.psm1


class ExitCode {
    #For use with LogicEnvironments
    #Either use a hashtable/dictionary of logic environments
    #or use a stack of logic environments (in which case i use "prev" to pop the stack)

    #When it is decided to change logic environment
    #The current environment should exit by setting a next environment to something other than "" in the Update() method
    
    [string]$nextEnvironment

    ExitCode ([string]$nextEnvironment) {
        $this.nextEnvironment = $nextEnvironment
    }
}


class LogicEnvironment {

    [string]$name
    [ANSIBuffer]$gScreen
    [Input]$gInput
    [System.Diagnostics.Stopwatch]$gTime


    GameEnvironment ([string]$name, [ANSIBuffer]$gScreen, [Input]$gInput, [System.Diagnostics.Stopwatch]$gTime) {
        $this.name = $name
        $this.gScreen = $gScreen
        $this.gInput = $gInput
        $this.gTime = $gTime
    }

    [ExitCode] Update () {
        Pause("Error : $($this.name) : Update() Not Implemented")
        return [ExitCode]::new("prev")
    }


    
}

