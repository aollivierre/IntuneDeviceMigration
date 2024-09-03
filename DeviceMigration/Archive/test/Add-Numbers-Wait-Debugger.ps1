function Add-Numbers {
    param (
        [int]$a,
        [int]$b
    )

    Write-Host "Starting Add-Numbers function" -ForegroundColor Cyan

    Write-Host "Waiting for debugger to attach..." -ForegroundColor Yellow
    Wait-Debugger  # The debugger will pause here

    Write-Host "Debugger attached, resuming execution..." -ForegroundColor Green

    $sum = $a + $b
    Write-Host "Calculated sum: $sum" -ForegroundColor Cyan
    return $sum
}

# Example usage:
Add-Numbers -a 5 -b 10
