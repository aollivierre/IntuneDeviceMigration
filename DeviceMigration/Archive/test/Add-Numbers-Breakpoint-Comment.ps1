function Add-Numbers {
    param (
        [int]$a,
        [int]$b
    )

    Write-Host "Starting Add-Numbers function" -ForegroundColor Cyan

    # Breakpoint
    Write-Host "Calculating sum..." -ForegroundColor Yellow

    $sum = $a + $b
    Write-Host "Calculated sum: $sum" -ForegroundColor Cyan
    return $sum
}

# Example usage:
Add-Numbers -a 5 -b 10
