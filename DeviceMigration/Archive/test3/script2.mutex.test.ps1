# Define the mutex name (should be the same across all scripts needing synchronization)
$mutexName = "Global\MyCustomMutexForModuleInstallation"

# Create or open the mutex
$mutex = [System.Threading.Mutex]::new($false, $mutexName)

# Acquire the mutex with a timeout (e.g., 3 minutes)
$acquiredLock = $mutex.WaitOne([TimeSpan]::FromMinutes(3))

try {
    if ($acquiredLock) {
        Write-Host "Acquired the lock. Proceeding with module installation and import."

        # Critical section: Perform module installation and import here
        # Example: Install-Module or Save-Module logic
        # Write-Host "Installing and importing modules..."
        # Simulate some work with Start-Sleep
        # Start-Sleep -Seconds 10


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
        Write-Warning "Failed to acquire the lock within the timeout. Exiting the script."
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
