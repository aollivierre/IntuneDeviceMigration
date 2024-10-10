$mode = $env:EnvironmentMode

# #region FIRING UP MODULE STARTER
# #################################################################################################
# #                                                                                               #
# #                                 FIRING UP MODULE STARTER                                      #
# #                                                                                               #
# #################################################################################################

# # Define the mutex name (should be the same across all scripts needing synchronization)
# $mutexName = "Global\MyCustomMutexForModuleInstallation"

# # Create or open the mutex
# $mutex = [System.Threading.Mutex]::new($false, $mutexName)

# # Set initial back-off parameters
# $initialWaitTime = 5       # Initial wait time in seconds
# $maxAttempts = 10           # Maximum number of attempts
# $backOffFactor = 2         # Factor to increase the wait time for each attempt

# $attempt = 0
# $acquiredLock = $false

# # Try acquiring the mutex with dynamic back-off
# while (-not $acquiredLock -and $attempt -lt $maxAttempts) {
#     $attempt++
#     Write-AADMigrationLog -Message "Attempt $attempt to acquire the lock..."

#     # Try to acquire the mutex with a timeout
#     $acquiredLock = $mutex.WaitOne([TimeSpan]::FromSeconds($initialWaitTime))

#     if (-not $acquiredLock) {
#         # If lock wasn't acquired, wait for the back-off period before retrying
#         Write-AADMigrationLog "Failed to acquire the lock. Retrying in $initialWaitTime seconds..." -Level 'WARNING'
#         Start-Sleep -Seconds $initialWaitTime

#         # Increase the wait time using the back-off factor
#         $initialWaitTime *= $backOffFactor
#     }
# }

# try {
#     if ($acquiredLock) {
#         Write-AADMigrationLog -Message "Acquired the lock. Proceeding with module installation and import."

#         # Start timing the critical section
#         $executionTime = [System.Diagnostics.Stopwatch]::StartNew()

#         # Critical section starts here

#         # Conditional check for dev and prod mode
#         if ($global:mode -eq "dev") {
#             # In dev mode, import the module from the local path
#             Write-AADMigrationLog -Message "Running in dev mode. Importing module from local path."
#             Import-Module 'C:\code\ModulesV2\EnhancedModuleStarterAO\EnhancedModuleStarterAO.psm1'
#         }
#         elseif ($global:mode -eq "prod") {
#             # In prod mode, execute the script from the URL
#             Write-AADMigrationLog -Message "Running in prod mode. Executing the script from the remote URL."
#             # Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Install-EnhancedModuleStarterAO.ps1")


#             # Check if running in PowerShell 5
#             if ($PSVersionTable.PSVersion.Major -ne 5) {
#                 Write-AADMigrationLog -Message "Not running in PowerShell 5. Relaunching the command with PowerShell 5."

#                 # Reset Module Paths when switching from PS7 to PS5 process
#                 Reset-ModulePaths

#                 # Get the path to PowerShell 5 executable
#                 $ps5Path = "$Env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

#                 # Relaunch the Invoke-Expression command with PowerShell 5
#                 & $ps5Path -Command "Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/aollivierre/module-starter/main/Install-EnhancedModuleStarterAO.ps1')"
#             }
#             else {
#                 # If running in PowerShell 5, execute the command directly
#                 Write-AADMigrationLog -Message "Running in PowerShell 5. Executing the command."
#                 Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Install-EnhancedModuleStarterAO.ps1")
#             }


#         }
#         else {
#             Write-AADMigrationLog -Message "Invalid mode specified. Please set the mode to either 'dev' or 'prod'." -Level 'WARNING'
#             exit 1
#         }

#         # Optional: Wait for debugger if needed
#         # Wait-Debugger


#         # Define a hashtable for splatting
#         $moduleStarterParams = @{
#             Mode                   = $global:mode
#             SkipPSGalleryModules   = $false
#             SkipCheckandElevate    = $false
#             SkipPowerShell7Install = $false
#             SkipEnhancedModules    = $false
#             SkipGitRepos           = $true
#         }

#         # Check if running in PowerShell 5
#         if ($PSVersionTable.PSVersion.Major -ne 5) {
#             Write-AADMigrationLog -Message  "Not running in PowerShell 5. Relaunching the function call with PowerShell 5."

#             # Get the path to PowerShell 5 executable
#             $ps5Path = "$Env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"


#             Reset-ModulePaths

#             # Relaunch the Invoke-ModuleStarter function call with PowerShell 5
#             & $ps5Path -Command {
#                 # Recreate the hashtable within the script block for PowerShell 5
#                 $moduleStarterParams = @{
#                     Mode                   = 'prod'
#                     SkipPSGalleryModules   = $false
#                     SkipCheckandElevate    = $false
#                     SkipPowerShell7Install = $false
#                     SkipEnhancedModules    = $false
#                     SkipGitRepos           = $true
#                 }
#                 Invoke-ModuleStarter @moduleStarterParams
#             }
#         }
#         else {
#             # If running in PowerShell 5, execute the function directly
#             Write-AADMigrationLog -Message "Running in PowerShell 5. Executing Invoke-ModuleStarter."
#             Invoke-ModuleStarter @moduleStarterParams
#         }

        
#         # Critical section ends here
#         $executionTime.Stop()

#         # Measure the time taken and log it
#         $timeTaken = $executionTime.Elapsed.TotalSeconds
#         Write-AADMigrationLog -Message "Critical section execution time: $timeTaken seconds"

#         # Optionally, log this to a file for further analysis
#         Add-Content -Path "C:\Temp\CriticalSectionTimes.log" -Value "Execution time: $timeTaken seconds - $(Get-Date)"

#         Write-AADMigrationLog -Message "Module installation and import completed."
#     }
#     else {
#         Write-Warning "Failed to acquire the lock after $maxAttempts attempts. Exiting the script."
#         exit 1
#     }
# }
# catch {
#     Write-Error "An error occurred: $_"
# }
# finally {
#     # Release the mutex if it was acquired
#     if ($acquiredLock) {
#         $mutex.ReleaseMutex()
#         Write-AADMigrationLog -Message "Released the lock."
#     }

#     # Dispose of the mutex object
#     $mutex.Dispose()
# }

# #endregion FIRING UP MODULE STARTER

#region HANDLE PSF MODERN LOGGING
#################################################################################################
#                                                                                               #
#                            HANDLE PSF MODERN LOGGING                                          #
#                                                                                               #
#################################################################################################
# Check if the current user is an administrator
$isAdmin = CheckAndElevate -ElevateIfNotAdmin $false

# Set the configuration and register it with the appropriate scope based on admin privileges
if ($isAdmin) {
    # If the user is admin, register in the SystemDefault scope
    Set-PSFConfig -Fullname 'PSFramework.Logging.FileSystem.ModernLog' -Value $true -PassThru | Register-PSFConfig -Scope SystemDefault
}
else {
    # If the user is not admin, register in the User scope
    Set-PSFConfig -Fullname 'PSFramework.Logging.FileSystem.ModernLog' -Value $true -PassThru | Register-PSFConfig -Scope UserDefault
}


# Define the base logs path and job name
$JobName = "AAD_Migration"
$parentScriptName = Get-ParentScriptName
Write-Host "Parent Script Name: $parentScriptName"

# Call the Get-PSFCSVLogFilePath function to generate the dynamic log file path
$paramGetPSFCSVLogFilePath = @{
    LogsPath         = 'C:\Logs\PSF'
    JobName          = $jobName
    parentScriptName = $parentScriptName
}

$csvLogFilePath = Get-PSFCSVLogFilePath @paramGetPSFCSVLogFilePath

$instanceName = "$parentScriptName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# Configure the PSFramework logging provider to use CSV format
$paramSetPSFLoggingProvider = @{
    Name            = 'logfile'
    InstanceName    = $instanceName  # Use a unique instance name
    FilePath        = $csvLogFilePath  # Use the dynamically generated file path
    Enabled         = $true
    FileType        = 'CSV'
    EnableException = $true
}
Set-PSFLoggingProvider @paramSetPSFLoggingProvider

#endregion HANDLE PSF MODERN LOGGING


#region HANDLE Transript LOGGING
#################################################################################################
#                                                                                               #
#                            HANDLE Transript LOGGING                                           #
#                                                                                               #
#################################################################################################
# Start the script with error handling
try {
    # Generate the transcript file path
    $GetTranscriptFilePathParams = @{
        TranscriptsPath  = "C:\Logs\Transcript"
        JobName          = $jobName
        parentScriptName = $parentScriptName
    }
    $transcriptPath = Get-TranscriptFilePath @GetTranscriptFilePathParams
    
    # Start the transcript
    Write-EnhancedLog -Message "Starting transcript at: $transcriptPath"
    Start-Transcript -Path $transcriptPath
}
catch {
    Write-EnhancedLog -Message "An error occurred during script execution: $_" -Level 'ERROR'
    if ($transcriptPath) {
        Stop-Transcript
        Write-Host "Transcript stopped." -ForegroundColor Cyan
        # Stop logging in the finally block

    }
    else {
        Write-Host "Transcript was not started due to an earlier error." -ForegroundColor Red
    }

    # Stop PSF Logging

    # Ensure the log is written before proceeding
    Wait-PSFMessage

    # Stop logging in the finally block by disabling the provider
    Set-PSFLoggingProvider -Name 'logfile' -InstanceName $instanceName -Enabled $false

    Handle-Error -ErrorRecord $_
    throw $_  # Re-throw the error after logging it
}
#endregion HANDLE Transript LOGGING

try {
    #region Script Logic
    #################################################################################################
    #                                                                                               #
    #                                    Script Logic                                               #
    #                                                                                               #
    #################################################################################################

    # ################################################################################################################################
    # ############### CALLING AS SYSTEM to simulate Intune deployment as SYSTEM (Uncomment for debugging) ############################
    # ################################################################################################################################

    # Example usage
    $ensureRunningAsSystemParams = @{
        PsExec64Path = Join-Path -Path $PSScriptRoot -ChildPath "private\PsExec64.exe"
        ScriptPath   = $MyInvocation.MyCommand.Path
        TargetFolder = Join-Path -Path $PSScriptRoot -ChildPath "private"
    }

    Ensure-RunningAsSystem @ensureRunningAsSystemParams


    $ValidatePSADTFilesParams = @{
        ScriptRoot = $PSScriptRoot
    }
    Validate-PSADTFiles @ValidatePSADTFilesParams

    # Wait-Debugger
    

    # $pwshPath = Get-PowerShellPath

    $ps5Path = "$Env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

    # Define the path to the deploy-application.ps1 script
    $scriptPath = "$PSScriptRoot\deploy-application.ps1"

    # Ensure the script path is wrapped in quotes if it contains spaces
    $scriptPath = "`"$scriptPath`""

    # Define the arguments for the script in an array
    $arguments = @(
        '-NoExit'
        '-ExecutionPolicy'
        'Bypass'
        '-File'
        $scriptPath  # Path is already enclosed in quotes
        '-DeploymentType'
        'Install'
        '-DeployMode'
        'Interactive'
    )

    # Start the process with the arguments passed as an array
    Start-Process -FilePath $ps5Path -ArgumentList $arguments -Wait

    
    #endregion Script Logic
    
    #region HANDLE PSF LOGGING
    #################################################################################################
    #                                                                                               #
    #                                 HANDLE PSF LOGGING                                            #
    #                                                                                               #
    #################################################################################################
    # $parentScriptName = Get-ParentScriptName
    # Write-Host "Parent Script Name: $parentScriptName"

    # $HandlePSFLoggingParams = @{
    #     SystemSourcePathWindowsPS = "C:\Windows\System32\config\systemprofile\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
    #     SystemSourcePathPS        = "C:\Windows\System32\config\systemprofile\AppData\Roaming\PowerShell\PSFramework\Logs\"
    #     UserSourcePathWindowsPS   = "$env:USERPROFILE\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
    #     UserSourcePathPS          = "$env:USERPROFILE\AppData\Roaming\PowerShell\PSFramework\Logs\"
    #     PSFPath                   = "C:\Logs\PSF"
    #     ParentScriptName          = $parentScriptName
    #     JobName                   = $JobName
    #     SkipSYSTEMLogCopy         = $true
    #     SkipSYSTEMLogRemoval      = $true
    # }

    # Handle-PSFLogging @HandlePSFLoggingParams
    #endregion
}
catch {
    Write-EnhancedLog -Message "An error occurred during script execution: $_" -Level 'ERROR'
    if ($transcriptPath) {
        Stop-Transcript
        Write-Host "Transcript stopped." -ForegroundColor Cyan
        # Stop logging in the finally block

    }
    else {
        Write-Host "Transcript was not started due to an earlier error." -ForegroundColor Red
    }

    # Stop PSF Logging

    # Ensure the log is written before proceeding
    Wait-PSFMessage

    # Stop logging in the finally block by disabling the provider
    Set-PSFLoggingProvider -Name 'logfile' -InstanceName $instanceName -Enabled $false

    Handle-Error -ErrorRecord $_
    throw $_  # Re-throw the error after logging it
} 
finally {
    # Ensure that the transcript is stopped even if an error occurs
    if ($transcriptPath) {
        Stop-Transcript
        Write-Host "Transcript stopped." -ForegroundColor Cyan
        # Stop logging in the finally block

    }
    else {
        Write-Host "Transcript was not started due to an earlier error." -ForegroundColor Red
    }
    
    # Ensure the log is written before proceeding
    Wait-PSFMessage

    # Stop logging in the finally block by disabling the provider
    Set-PSFLoggingProvider -Name 'logfile' -InstanceName $instanceName -Enabled $false
}