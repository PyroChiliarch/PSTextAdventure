using namespace System.Management.Automation.Host
#https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.host.pshostrawuserinterface?view=powershellsdk-7.0.0



enum KeyID {

    #Missing
    #Opposite control keys
    #Print Screen
    #Scroll Lock
    #Pause/Break
    #Caps lock

    none = 0

    backspace = 8
    tab = 9
    numCentre = 12
    enter = 13

    shift = 16
    ctrl = 17
    alt = 18

    esc = 27
    
    space = 32
    pgeUp = 33
    pgeDown = 34
    end = 35
    home = 36

    left = 37
    up = 38
    right = 39 
    down = 40

    insert = 45
    delete = 46

    zero = 48
    one = 49
    two = 50
    three = 52
    four = 52
    five = 53
    six = 54
    seven = 55
    eight = 56
    nine = 57
    
    a = 65
    b = 66
    c = 67
    d = 68
    e = 69
    f = 70
    g = 71
    h = 72
    i = 73
    j = 74
    k = 75
    l = 76
    m = 77
    n = 78
    o = 79
    p = 80
    q = 81
    r = 82
    s = 83
    t = 84
    u = 85
    v = 86
    w = 87
    x = 88
    y = 89
    z = 90

    lWin = 91
    rWin = 92
    menu = 93

    num0 = 96
    num1 = 97
    num2 = 98
    num3 = 99
    num4 = 100
    num5 = 101
    num6 = 102
    num7 = 103
    num8 = 104
    num9 = 105

    numMultiply = 106
    numAdd = 107
    numSubtract = 109
    numDecimal = 110
    numDivide = 111

    F1 = 112
    F2 = 113
    F3 = 114
    F4 = 115
    F5 = 116
    F6 = 117
    F7 = 118
    F8 = 119
    F9 = 120
    F10 = 121
    F11 = 122
    F12 = 123

    numlock = 144

    mute = 173
    volDown = 174
    volUp = 175
    next = 176
    back = 177
    stop = 178
    playPause = 179

    colon = 186
    equal = 187
    comma = 188
    dash = 189
    period = 190
    slash = 191
    tilde = 192

    lBracket = 219
    backslash = 220
    rBracket = 221
    quote = 222

}


class Input {
    [KeyInfo]$currentKey = [KeyInfo]::new(0, '-', 0, $false)

    Input () {
    }

    [void] UpdateInput () {
        if ($Global:Host.UI.RawUI.KeyAvailable -eq $false) {
            $this.currentKey = [KeyInfo]::new(0, '-', 0, $false)
        } else {
            $this.currentKey = $Global:Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown,IncludeKeyUp')
        }

        $Global:Host.UI.RawUI.FlushInputBuffer() #Stop Movement after key release, Input can build up if held

        
    }
}