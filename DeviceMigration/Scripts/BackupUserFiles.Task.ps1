$global:mode = $env:EnvironmentMode

#region FIRING UP MODULE STARTER
#################################################################################################
#                                                                                               #
#                                 FIRING UP MODULE STARTER                                      #
#                                                                                               #
#################################################################################################

# Define a hashtable for splatting
# $moduleStarterParams = @{
#     Mode                   = $global:mode
#     SkipPSGalleryModules   = $true
#     SkipCheckandElevate    = $true
#     SkipPowerShell7Install = $true
#     SkipEnhancedModules    = $true
#     SkipGitRepos           = $true
# }

# Call the function using the splat
# Invoke-ModuleStarter @moduleStarterParams

#endregion FIRING UP MODULE STARTER

#region HANDLE PSF MODERN LOGGING
#################################################################################################
#                                                                                               #
#                            HANDLE PSF MODERN LOGGING                                          #
#                                                                                               #
#################################################################################################
# Set-PSFConfig -Fullname 'PSFramework.Logging.FileSystem.ModernLog' -Value $true -PassThru | Register-PSFConfig -Scope SystemDefault

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

    
    # Example usage for Chrome bookmarks
    $BackupChromeBookmarksToOneDriveParams = @{
        SourcePath         = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default"
        BackupFolderName   = "ChromeBackup"
        Exclude            = ".git"
        RetryCount         = 2
        WaitTime           = 5
        RequiredSpaceGB    = 10
        OneDriveBackupPath = "$env:OneDrive\Backups"
        Scriptbasepath     = "$PSScriptroot"
    }
    Backup-UserFilesToOneDrive @BackupChromeBookmarksToOneDriveParams

    # Example usage for Outlook signatures
    $BackupOutlookSignaturesToOneDrive = @{
        SourcePath         = "$env:USERPROFILE\AppData\Roaming\Microsoft\Signatures"
        BackupFolderName   = "OutlookSignatures"
        Exclude            = ".git"
        RetryCount         = 2
        WaitTime           = 5
        RequiredSpaceGB    = 10
        OneDriveBackupPath = "$env:OneDrive\Backups"
        Scriptbasepath     = "$PSScriptroot"
    }
    Backup-UserFilesToOneDrive @BackupOutlookSignaturesToOneDrive

    # Example usage for Downloads folder
    $BackupDownloadsToOneDriveParams = @{
        SourcePath         = "$env:USERPROFILE\Downloads"
        BackupFolderName   = "DownloadsBackup"
        Exclude            = ".git"
        RetryCount         = 2
        WaitTime           = 5
        RequiredSpaceGB    = 10
        OneDriveBackupPath = "$env:OneDrive\Backups"
        Scriptbasepath     = "$PSScriptroot"
    }
    Backup-UserFilesToOneDrive @BackupDownloadsToOneDriveParams
    #endregion Script Logic
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
    # 

    
    # Ensure the log is written before proceeding
    Wait-PSFMessage

    # Stop logging in the finally block by disabling the provider
    Set-PSFLoggingProvider -Name 'logfile' -InstanceName $instanceName -Enabled $false

}