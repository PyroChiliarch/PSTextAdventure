$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
While ($true) {
    Write-Host ($stopwatch.Elapsed.TotalMilliseconds)
}