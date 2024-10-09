$lockFile = "C:\Temp\ModuleInstall.lock"
$lockTimeout = 300 # Lock expiration time in seconds (5 minutes)
$startTime = Get-Date

# Function to check if the lock file exists and is expired
function Test-LockExpired {
    param (
        [string]$LockFile,
        [int]$Timeout
    )
    if (Test-Path $LockFile) {
        $lockAge = (Get-Date) - (Get-Item $LockFile).CreationTime
        if ($lockAge.TotalSeconds -gt $Timeout) {
            # Lock has expired
            Remove-Item $LockFile -Force
            return $true
        }
        return $false
    }
    return $true # No lock file exists
}

# Wait until the lock is available or expired
while (-not (Test-LockExpired -LockFile $lockFile -Timeout $lockTimeout)) {
    Write-Host "Another script is currently running. Waiting..."
    Start-Sleep -Seconds 5
}

# Create the lock file
New-Item -Path $lockFile -ItemType File | Out-Null

try {
    # Perform module installation or import
    # Example: Install-Module -Name "SomeModule"

    # Simulate some work
    Start-Sleep -Seconds 10
}
finally {
    # Remove the lock file
    Remove-Item $lockFile -Force
    Write-Host "Module installation complete. Lock released."
}
