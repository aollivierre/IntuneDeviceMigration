$lockFile = "C:\Temp\ModuleInstall.lock"
$lockTimeout = 300 # Lock timeout in seconds (5 minutes)

function Get-LockCreationTime {
    param (
        [string]$LockFile
    )
    if (Test-Path $LockFile) {
        return (Get-Item $LockFile).CreationTime
    }
    return $null
}

# Function to test if lock has expired
function Test-LockExpired {
    param (
        [string]$LockFile,
        [int]$Timeout
    )
    if (Test-Path $LockFile) {
        $lockAge = (Get-Date) - (Get-LockCreationTime $LockFile)
        if ($lockAge.TotalSeconds -gt $Timeout) {
            Remove-Item $LockFile -Force
            return $true
        }
        return $false
    }
    return $true
}

while (-not (Test-LockExpired -LockFile $lockFile -Timeout $lockTimeout)) {
    Write-Host "Lock is active. Waiting for it to be released..."
    Start-Sleep -Seconds 5
}

New-Item -Path $lockFile -ItemType File | Out-Null

try {
    # Install or import modules here
    Start-Sleep -Seconds 10 # Simulate work
}
finally {
    Remove-Item $lockFile -Force
    Write-Host "Lock released."
}
