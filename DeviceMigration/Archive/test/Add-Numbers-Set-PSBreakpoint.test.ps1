function Add-Numbers {
    param (
        [int]$a,
        [int]$b
    )
    
    Write-Host "Entering Add-Numbers function" -ForegroundColor Cyan

    $sum = $a + $b

    Write-Host "Calculated sum: $sum" -ForegroundColor Cyan
    return $sum
}

# Example usage
Add-Numbers -a 5 -b 10

# Setting a breakpoint using Set-PSBreakpoint
Set-PSBreakpoint -Script "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test\Add-Numbers-Set-PSBreakpoint.ps1" -Line 7

# To invoke and test the breakpoint:
Add-Numbers -a 20 -b 30
