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
    # Example usage

    #blocks user input, displays a migration in progress form, creates a scheduled task for post-migration cleanup, escrows the BitLocker recovery key, sets various registry values for legal noctices, and optionally restarts the computer.

    $RegistrySettings = @(
        @{
            RegValName = "AutoAdminLogon"
            RegValType = "DWORD"
            RegValData = "0"
            RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        },
        @{
            RegValName = "dontdisplaylastusername"
            RegValType = "DWORD"
            RegValData = "1"
            RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        },
        @{
            RegValName = "legalnoticecaption"
            RegValType = "String"
            RegValData = "Migration Completed"
            RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        },
        @{
            RegValName = "legalnoticetext"
            RegValType = "String"
            RegValData = "This PC has been migrated to Azure Active Directory. Please log in to Windows using your email address and password."
            RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        }
    )
    
    
    $PostRunOncePhase2EscrowBitlockerParams = @{
        ImagePath        = "C:\ProgramData\AADMigration\Files\MigrationInProgress.bmp"
        TaskPath         = "AAD Migration"
        TaskName         = "Run Post migration cleanup"
        BitlockerDrives  = @("C:")
        RegistrySettings = $RegistrySettings  # Correctly assign the array here
        Mode             = $mode
    }
    
    PostRunOnce-Phase2EscrowBitlocker @PostRunOncePhase2EscrowBitlockerParams
    #endregion Script Logic
    
    #region HANDLE PSF LOGGING
    #################################################################################################
    #                                                                                               #
    #                                 HANDLE PSF LOGGING                                            #
    #                                                                                               #
    #################################################################################################
    $parentScriptName = Get-ParentScriptName
    Write-EnhancedLog -Message "Parent Script Name: $parentScriptName"

    $HandlePSFLoggingParams = @{
        SystemSourcePathWindowsPS = "C:\Windows\System32\config\systemprofile\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
        SystemSourcePathPS        = "C:\Windows\System32\config\systemprofile\AppData\Roaming\PowerShell\PSFramework\Logs\"
        # UserSourcePathWindowsPS   = "$env:USERPROFILE\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
        # UserSourcePathPS          = "$env:USERPROFILE\AppData\Roaming\PowerShell\PSFramework\Logs\"
        PSFPath                   = "C:\Logs\PSF"
        ParentScriptName          = $parentScriptName
        JobName                   = $JobName
        SkipSYSTEMLogCopy         = $false
        SkipSYSTEMLogRemoval      = $false
    }

    Handle-PSFLogging @HandlePSFLoggingParams



    # $SecurePAT = Read-Host "Please enter your GitHub Personal Access Token (PAT)" -AsSecureString
    # & "$PSScriptRoot\Upload-LogstoGitHub.ps1" -SecurePAT $SecurePAT


    # Define the path to the encrypted PAT file
    $secureFilePath = "C:\temp\SecurePAT.txt"

    # Ensure the file exists before attempting to read it
    if (-not (Test-Path $secureFilePath)) {
        Write-EnhancedLog -Message "The encrypted PAT file does not exist!" -Level 'ERROR'
        exit 1
    }


 
    # Decryption

    # Read the key from the file
    $keyString = Get-Content "C:\temp\SecureKey.txt" -Raw

    # Split the key string into an array of byte values
    $key = $keyString -split ',' | ForEach-Object { [byte]$_ }

    # Read the encrypted PAT from the file
    $EncryptedPAT = Get-Content "C:\temp\SecurePAT.txt" -Raw

    # Decrypt the SecurePAT using the key
    $SecurePAT = $EncryptedPAT | ConvertTo-SecureString -Key $key

    # Convert SecurePAT to plain text
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePAT)
    $PersonalAccessToken = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)

    # Check if it's successfully converted
    if ($PersonalAccessToken) {
        Write-Host "Successfully converted to plain text."
    }
    else {
        Write-Host "Failed to convert the SecureString."
    }

    $params = @{
        SecurePAT      = $securePat
        GitExePath     = "C:\Program Files\Git\bin\git.exe"
        LogsFolderPath = "C:\logs"
        TempCopyPath   = "C:\temp-logs"
        TempGitPath    = "C:\temp-git"
        GitUsername    = "aollivierre"
        BranchName     = "main"
        CommitMessage  = "Add logs.zip"
        RepoName       = "syslog"
        JobName        = "AADMigration"
    }
    
    Upload-LogsToGitHub @params

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
    # 

    
    # Ensure the log is written before proceeding
    Wait-PSFMessage

    # Stop logging in the finally block by disabling the provider
    Set-PSFLoggingProvider -Name 'logfile' -InstanceName $instanceName -Enabled $false

}
