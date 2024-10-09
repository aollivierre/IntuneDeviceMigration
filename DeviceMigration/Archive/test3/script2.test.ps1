# script2.test.ps1
$lockFile = "C:\Temp\ModuleInstall.lock"
$lockTimeout = 300 # Lock timeout in seconds (5 minutes)

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

# Wait for the lock to become available
while (-not (Test-LockExpired -LockFile $lockFile -Timeout $lockTimeout)) {
    Write-Host "Script 2: Lock is active. Waiting for it to be released..."
    Start-Sleep -Seconds 5
}

# Create the lock file
New-Item -Path $lockFile -ItemType File | Out-Null
Write-Host "Script 2: Acquired the lock."

try {
    # Simulate module installation and import
    Write-Host "Script 2: Installing and importing modules..."
    # Start-Sleep -Seconds 10 # Simulate some work

    Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Install-EnhancedModuleStarterAO.ps1")

    # Define a hashtable for splatting
    $moduleStarterParams = @{
        Mode                   = 'prod'
        SkipPSGalleryModules   = $false
        SkipCheckandElevate    = $false
        SkipPowerShell7Install = $false
        SkipEnhancedModules    = $false
        SkipGitRepos           = $true
    }

    # Call the function using the splat
    Invoke-ModuleStarter @moduleStarterParams

    Write-Host "Script 2: Modules installed and imported successfully."
}
finally {
    # Release the lock
    Remove-Item $lockFile -Force
    Write-Host "Script 2: Lock released."
}