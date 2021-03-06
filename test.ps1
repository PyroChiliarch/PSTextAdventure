class myClass {

    [int]$value

    myClass ($value) {
        $this.value = $value
    }
}



[myClass[]]$dataArray = New-Object 'myClass[]' 2

$dataArray[0] = New-Object 'myClass' 0
$dataArray[1] = New-Object 'myClass' 0

$dataArray[0].value = 12
$dataArray[1].value = 25

Write-Host $($dataArray[0].value)