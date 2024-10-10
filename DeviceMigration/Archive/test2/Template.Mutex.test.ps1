function Write-AADMigrationLog {
    param (
        [string]$Message,
        [string]$Level = "INFO",
        [switch]$Async = $false  # Control whether logging should be async or not
    )

    # Check if the Async switch is not set, then use the global variable if defined
    if (-not $Async) {
        $Async = $global:LOG_ASYNC
    }

    # Get the PowerShell call stack to determine the actual calling function
    $callStack = Get-PSCallStack
    $callerFunction = if ($callStack.Count -ge 2) { $callStack[1].Command } else { '<Unknown>' }

    # Prepare the formatted message with the actual calling function information
    $formattedMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] [$callerFunction] $Message"

    if ($Async) {
        # Enqueue the log message for async processing
        $logItem = [PSCustomObject]@{
            Level        = $Level
            Message      = $formattedMessage
            FunctionName = $callerFunction
        }
        $global:LogQueue.Enqueue($logItem)
    }
    else {
        # Display the log message based on the log level using Write-Host
        switch ($Level.ToUpper()) {
            "DEBUG" { Write-Host $formattedMessage -ForegroundColor DarkGray }
            "INFO" { Write-Host $formattedMessage -ForegroundColor Green }
            "NOTICE" { Write-Host $formattedMessage -ForegroundColor Cyan }
            "WARNING" { Write-Host $formattedMessage -ForegroundColor Yellow }
            "ERROR" { Write-Host $formattedMessage -ForegroundColor Red }
            "CRITICAL" { Write-Host $formattedMessage -ForegroundColor Magenta }
            default { Write-Host $formattedMessage -ForegroundColor White }
        }

        # Append to log file synchronously
        $logFilePath = [System.IO.Path]::Combine($env:TEMP, 'setupAADMigration.log')
        $formattedMessage | Out-File -FilePath $logFilePath -Append -Encoding utf8
    }
}

$global:mode = 'dev'

#region FIRING UP MODULE STARTER
#################################################################################################
#                                                                                               #
#                                 FIRING UP MODULE STARTER                                      #
#                                                                                               #
#################################################################################################

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
    Write-AADMigrationLog -Message "Attempt $attempt to acquire the lock..."

    # Try to acquire the mutex with a timeout
    $acquiredLock = $mutex.WaitOne([TimeSpan]::FromSeconds($initialWaitTime))

    if (-not $acquiredLock) {
        # If lock wasn't acquired, wait for the back-off period before retrying
        Write-AADMigrationLog "Failed to acquire the lock. Retrying in $initialWaitTime seconds..." -Level 'WARNING'
        Start-Sleep -Seconds $initialWaitTime

        # Increase the wait time using the back-off factor
        $initialWaitTime *= $backOffFactor
    }
}

try {
    if ($acquiredLock) {
        Write-AADMigrationLog -Message "Acquired the lock. Proceeding with module installation and import."

        # Start timing the critical section
        $executionTime = [System.Diagnostics.Stopwatch]::StartNew()

        # Critical section starts here

        # Conditional check for dev and prod mode
        if ($global:mode -eq "dev") {
            # In dev mode, import the module from the local path
            Write-AADMigrationLog -Message "Running in dev mode. Importing module from local path."
            Import-Module 'C:\code\ModulesV2\EnhancedModuleStarterAO\EnhancedModuleStarterAO.psm1'
        }
        elseif ($global:mode -eq "prod") {
            # In prod mode, execute the script from the URL
            Write-AADMigrationLog -Message "Running in prod mode. Executing the script from the remote URL."
            # Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Install-EnhancedModuleStarterAO.ps1")


            # Check if running in PowerShell 5
            if ($PSVersionTable.PSVersion.Major -ne 5) {
                Write-AADMigrationLog -Message "Not running in PowerShell 5. Relaunching the command with PowerShell 5."

                # Reset Module Paths when switching from PS7 to PS5 process
                Reset-ModulePaths

                # Get the path to PowerShell 5 executable
                $ps5Path = "$Env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

                # Relaunch the Invoke-Expression command with PowerShell 5
                & $ps5Path -Command "Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/aollivierre/module-starter/main/Install-EnhancedModuleStarterAO.ps1')"
            }
            else {
                # If running in PowerShell 5, execute the command directly
                Write-AADMigrationLog -Message "Running in PowerShell 5. Executing the command."
                Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Install-EnhancedModuleStarterAO.ps1")
            }


        }
        else {
            Write-AADMigrationLog -Message "Invalid mode specified. Please set the mode to either 'dev' or 'prod'." -Level 'WARNING'
            exit 1
        }

        # Optional: Wait for debugger if needed
        # Wait-Debugger


        # Define a hashtable for splatting
        $moduleStarterParams = @{
            Mode                   = $global:mode
            SkipPSGalleryModules   = $false
            SkipCheckandElevate    = $false
            SkipPowerShell7Install = $false
            SkipEnhancedModules    = $false
            SkipGitRepos           = $true
        }

        # Check if running in PowerShell 5
        if ($PSVersionTable.PSVersion.Major -ne 5) {
            Write-AADMigrationLog -Message  "Not running in PowerShell 5. Relaunching the function call with PowerShell 5."

            # Get the path to PowerShell 5 executable
            $ps5Path = "$Env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"


            Reset-ModulePaths

            # Relaunch the Invoke-ModuleStarter function call with PowerShell 5
            & $ps5Path -Command {
                # Recreate the hashtable within the script block for PowerShell 5
                $moduleStarterParams = @{
                    Mode                   = 'prod'
                    SkipPSGalleryModules   = $false
                    SkipCheckandElevate    = $false
                    SkipPowerShell7Install = $false
                    SkipEnhancedModules    = $false
                    SkipGitRepos           = $true
                }
                Invoke-ModuleStarter @moduleStarterParams
            }
        }
        else {
            # If running in PowerShell 5, execute the function directly
            Write-AADMigrationLog -Message "Running in PowerShell 5. Executing Invoke-ModuleStarter."
            Invoke-ModuleStarter @moduleStarterParams
        }

        
        # Critical section ends here
        $executionTime.Stop()

        # Measure the time taken and log it
        $timeTaken = $executionTime.Elapsed.TotalSeconds
        Write-AADMigrationLog -Message "Critical section execution time: $timeTaken seconds"

        # Optionally, log this to a file for further analysis
        Add-Content -Path "C:\Temp\CriticalSectionTimes.log" -Value "Execution time: $timeTaken seconds - $(Get-Date)"

        Write-AADMigrationLog -Message "Module installation and import completed."
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
        Write-AADMigrationLog -Message "Released the lock."
    }

    # Dispose of the mutex object
    $mutex.Dispose()
}
#endregion FIRING UP MODULE STARTER