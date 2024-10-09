# Define the mutex name (should be the same across all scripts needing synchronization)
$mutexName = "Global\MyCustomMutexForModuleInstallation"

# Create or open the mutex
$mutex = [System.Threading.Mutex]::new($false, $mutexName)

# Set initial back-off parameters
$initialWaitTime = 5       # Initial wait time in seconds
$maxAttempts = 10           # Maximum number of attempts
$backOffFactor = 2         # Factor to increase the wait time for each attempt

$attempt = 0
$acquiredLock = $false

# Try acquiring the mutex with dynamic back-off
while (-not $acquiredLock -and $attempt -lt $maxAttempts) {
    $attempt++
    Write-Host "Attempt $attempt to acquire the lock..."

    # Try to acquire the mutex with a timeout
    $acquiredLock = $mutex.WaitOne([TimeSpan]::FromSeconds($initialWaitTime))

    if (-not $acquiredLock) {
        # If lock wasn't acquired, wait for the back-off period before retrying
        Write-Warning "Failed to acquire the lock. Retrying in $initialWaitTime seconds..."
        Start-Sleep -Seconds $initialWaitTime

        # Increase the wait time using the back-off factor
        $initialWaitTime *= $backOffFactor
    }
}

try {
    if ($acquiredLock) {
        Write-Host "Acquired the lock. Proceeding with module installation and import."

        # Start timing the critical section
        $executionTime = [System.Diagnostics.Stopwatch]::StartNew()

        # Critical section starts here
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

        # Critical section ends here
        $executionTime.Stop()

        # Measure the time taken and log it
        $timeTaken = $executionTime.Elapsed.TotalSeconds
        Write-Host "Critical section execution time: $timeTaken seconds"

        # Optionally, log this to a file for further analysis
        Add-Content -Path "C:\Temp\CriticalSectionTimes.log" -Value "Execution time: $timeTaken seconds - $(Get-Date)"

        Write-Host "Module installation and import completed."
    }
    else {
        Write-Warning "Failed to acquire the lock after $maxAttempts attempts. Exiting the script."
        exit 1
    }
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    # Release the mutex if it was acquired
    if ($acquiredLock) {
        $mutex.ReleaseMutex()
        Write-Host "Released the lock."
    }

    # Dispose of the mutex object
    $mutex.Dispose()
}
