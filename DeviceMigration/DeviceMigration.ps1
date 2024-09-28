# param (
#     [string]$Mode = "dev"
# )

# Set environment variable globally for all users

$global:mode = 'prod'

[System.Environment]::SetEnvironmentVariable('EnvironmentMode', $global:mode, 'Machine')
[System.Environment]::SetEnvironmentVariable('EnvironmentMode', $global:mode, 'process')

# Alternatively, use this PowerShell method (same effect)
# Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name 'EnvironmentMode' -Value 'dev'


# Retrieve the environment mode (default to 'prod' if not set)
$global:mode = $env:EnvironmentMode

# Toggle based on the environment mode
switch ($global:mode) {
    'dev' {
        Write-Host "Running in development mode" -ForegroundColor Yellow
        # Your development logic here
    }
    'prod' {
        Write-Host "Running in production mode" -ForegroundColor Green
        # Your production logic here
    }
    default {
        Write-Host "Unknown mode. Defaulting to production." -ForegroundColor Red
        # Default to production
    }
}

# Wait-Debugger

#region FIRING UP MODULE STARTER
#################################################################################################
#                                                                                               #
#                                 FIRING UP MODULE STARTER                                      #
#                                                                                               #
#################################################################################################

Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Install-EnhancedModuleStarterAO.ps1")

# Import-Module 'C:\code\ModulesV2\EnhancedModuleStarterAO\EnhancedModuleStarterAO.psm1'

# Define a hashtable for splatting
$moduleStarterParams = @{
    Mode                   = $global:mode
    SkipPSGalleryModules   = $false
    SkipCheckandElevate    = $false
    SkipPowerShell7Install = $false
    SkipEnhancedModules    = $false
    SkipGitRepos           = $true
}

# Call the function using the splat
Invoke-ModuleStarter @moduleStarterParams

#endregion FIRING UP MODULE STARTER


#region Cleaning up Logs
#################################################################################################
#                                                                                               #
#                            Cleaning up Logs                                                   #
#                                                                                               #
#################################################################################################
# if ($Mode -eq "Dev") {
#     Write-EnhancedLog -Message "Removing Logs in Dev Mode " -Level "WARNING"
#     Remove-LogsFolder -LogFolderPath "C:\Logs"
#     Write-EnhancedLog -Message "Migration in progress form displayed" -Level "INFO"
# }
# else {
#     Write-EnhancedLog -Message "Skipping Removing Logs in Prod mode" -Level "WARNING"
# }
#endregion Cleaning up Logs


#region Cleaning up AADMigration Artifacts
#################################################################################################
#                                                                                               #
#                            Cleaning up AADMigration Artifacts                                 #
#                                                                                               #
#################################################################################################
function Remove-AADMigrationArtifacts {
    <#
    .SYNOPSIS
    Cleans up AAD migration artifacts, including directories, scheduled tasks, and a local user.

    .DESCRIPTION
    The `Remove-AADMigrationArtifacts` function removes the following AAD migration-related artifacts:
    - The `C:\logs` directory
    - The `C:\ProgramData\AADMigration` directory
    - All scheduled tasks under the `AAD Migration` task path
    - The `AAD Migration` scheduled task folder
    - A local user account named `MigrationInProgress`

    .EXAMPLE
    Remove-AADMigrationArtifacts

    Cleans up all AAD migration artifacts.

    .NOTES
    This function should be run with administrative privileges.
    #>

    [CmdletBinding()]
    param ()

    Begin {
        Write-Host "Starting AAD migration artifact cleanup..."
    }

    Process {
        # Remove the C:\logs directory if it exists
        $logsPath = "C:\logs"
        if (Test-Path -Path $logsPath) {
            Write-Host "Removing $logsPath..."
            Remove-Item -Path $logsPath -Recurse -Force
        } else {
            Write-Host "$logsPath does not exist, skipping..."
        }

        # Remove the C:\ProgramData\AADMigration directory if it exists
        $aadMigrationPath = "C:\ProgramData\AADMigration"
        if (Test-Path -Path $aadMigrationPath) {
            Write-Host "Removing $aadMigrationPath..."
            Remove-Item -Path $aadMigrationPath -Recurse -Force
        } else {
            Write-Host "$aadMigrationPath does not exist, skipping..."
        }

        # Remove all scheduled tasks under the AAD Migration task path
        $scheduledTasks = Get-ScheduledTask -TaskPath '\AAD Migration\' -ErrorAction SilentlyContinue
        if ($scheduledTasks) {
            foreach ($task in $scheduledTasks) {
                Write-Host "Removing scheduled task: $($task.TaskName)..."
                Unregister-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Confirm:$false
            }
        } else {
            Write-Host "No scheduled tasks found under \AAD Migration, skipping..."
        }

        # Remove the scheduled task folder named AAD Migration
        try {
            $taskFolder = New-Object -ComObject "Schedule.Service"
            $taskFolder.Connect()
            $rootFolder = $taskFolder.GetFolder("\")
            $aadMigrationFolder = $rootFolder.GetFolder("AAD Migration")
            $aadMigrationFolder.DeleteFolder("", 0)
            Write-Host "Scheduled task folder AAD Migration removed successfully."
        } catch {
            Write-Host "Scheduled task folder AAD Migration does not exist or could not be removed."
        }

        # Remove the local user called MigrationInProgress
        $localUser = "MigrationInProgress"
        try {
            $user = Get-LocalUser -Name $localUser -ErrorAction Stop
            if ($user) {
                Write-Host "Removing local user $localUser..."
                Remove-LocalUser -Name $localUser -Force
            }
        } catch {
            Write-Host "Local user $localUser does not exist, skipping..."
        }
    }

    End {
        Write-Host "AAD migration artifact cleanup completed."
    }
}

Remove-AADMigrationArtifacts
#end region Cleaning up AADMigration Artifacts 

#region HANDLE PSF MODERN LOGGING
#################################################################################################
#                                                                                               #
#                            HANDLE PSF MODERN LOGGING                                          #
#                                                                                               #
#################################################################################################
Set-PSFConfig -Fullname 'PSFramework.Logging.FileSystem.ModernLog' -Value $true -PassThru | Register-PSFConfig -Scope SystemDefault

# Define the base logs path and job name
$JobName = "AAD_Migration"
$parentScriptName = Get-ParentScriptName
Write-EnhancedLog -Message "Parent Script Name: $parentScriptName"

# Call the Get-PSFCSVLogFilePath function to generate the dynamic log file path
$GetPSFCSVLogFilePathParam = @{
    LogsPath         = 'C:\Logs\PSF'
    JobName          = $jobName
    parentScriptName = $parentScriptName
}

$csvLogFilePath = Get-PSFCSVLogFilePath @GetPSFCSVLogFilePathParam
Write-EnhancedLog -Message "Generated Log File Path: $csvLogFilePath"

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



# # Set up the EventLog logging provider with the calling function as the source
# $paramSetPSFLoggingProvider = @{
#     Name         = 'EventLog'
#     # InstanceName = 'DynamicEventLog'
#     InstanceName = $instanceName
#     Enabled      = $true
#     LogName      = $parentScriptName
#     Source       = $callingFunction
# }
# Set-PSFLoggingProvider @paramSetPSFLoggingProvider

# Write-EnhancedLog -Message "This is a test from $parentScriptName via PSF to Event Logs" -Level 'INFO'

# $DBG

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
    Write-EnhancedLog -Message "Starting transcript at: $transcriptPath" -Level 'INFO'
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

# $DBG

try {

    #region CALLING AS SYSTEM
    #################################################################################################
    #                                                                                               #
    #                                 CALLING AS SYSTEM                                             #
    #                Simulate Intune deployment as SYSTEM (Uncomment for debugging)                 #
    #                                                                                               #
    #################################################################################################

    $ensureRunningAsSystemParams = @{
        PsExec64Path = Join-Path -Path $PSScriptRoot -ChildPath "private\PsExec64.exe"
        ScriptPath   = $MyInvocation.MyCommand.Path
        TargetFolder = Join-Path -Path $PSScriptRoot -ChildPath "private"
    }

    Ensure-RunningAsSystem @ensureRunningAsSystemParams
    #endregion


    #region Script Logic
    #################################################################################################
    #                                                                                               #
    #                                    Script Logic                                               #
    #                                                                                               #
    #################################################################################################

    #region END Downloading Service UI and PSADT
    #################################################################################################
    #                                                                                               #
    #                       END Downloading Service UI and PSADT                                    #
    #                                                                                               #
    #################################################################################################
    $DownloadAndInstallServiceUIparams = @{
        TargetFolder           = "$PSScriptRoot"
        DownloadUrl            = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
        MsiFileName            = "MicrosoftDeploymentToolkit_x64.msi"
        InstalledServiceUIPath = "C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\ServiceUI.exe"
    }
    Download-And-Install-ServiceUI @DownloadAndInstallServiceUIparams

    $DownloadPSAppDeployToolkitParams = @{
        GithubRepository     = 'PSAppDeployToolkit/PSAppDeployToolkit'
        FilenamePatternMatch = '*.zip'
        DestinationDirectory = $PSScriptRoot
        CustomizationsPath   = "$PSScriptroot\PSADT-Customizations"
    }
    Download-PSAppDeployToolkit @DownloadPSAppDeployToolkitParams
    #endregion

    # Import migration configuration
    $ConfigFileName = "MigrationConfig.psd1"
    $ConfigBaseDirectory = $PSScriptRoot
    $MigrationConfig = Import-LocalizedData -BaseDirectory $ConfigBaseDirectory -FileName $ConfigFileName

    $TenantID = $MigrationConfig.TenantID
    $OneDriveKFM = $MigrationConfig.UseOneDriveKFM
    $InstallOneDrive = $MigrationConfig.InstallOneDrive

    # Define parameters
    $PrepareAADMigrationParams = @{
        MigrationPath       = "C:\ProgramData\AADMigration"
        PSScriptbase        = $PSScriptRoot
        ConfigBaseDirectory = $PSScriptRoot
        ConfigFileName      = "MigrationConfig.psd1"
        TenantID            = $TenantID
        OneDriveKFM         = $OneDriveKFM
        InstallOneDrive     = $InstallOneDrive
    }
    Prepare-AADMigration @PrepareAADMigrationParams


    $CreateInteractiveMigrationTaskParams = @{
        TaskPath               = "AAD Migration"
        TaskName               = "PR4B-AADM Launch PSADT for Interactive Migration"
        ServiceUIPath          = "C:\ProgramData\AADMigration\ServiceUI.exe"
        ToolkitExecutablePath  = "C:\ProgramData\AADMigration\PSAppDeployToolkit\Toolkit\Deploy-Application.exe"
        ProcessName            = "explorer.exe"
        DeploymentType         = "Install"
        DeployMode             = "Interactive"
        TaskTriggerType        = "AtLogOn"
        TaskRepetitionDuration = "P1D"  # 1 day
        TaskRepetitionInterval = "PT15M"  # 15 minutes
        TaskPrincipalUserId    = "NT AUTHORITY\SYSTEM"
        TaskRunLevel           = "Highest"
        TaskDescription        = "AADM Launch PSADT for Interactive Migration Version 1.0"
        Delay                  = "PT2H"  # 2 hours delay before starting
    }

    Create-InteractiveMigrationTask @CreateInteractiveMigrationTaskParams



    # Show migration in progress form
    if ($Mode -eq "dev") {
        Write-EnhancedLog -Message "Running all Post Run Once and Post Run Scheduled Tasks in Dev Mode" -Level "WARNING"
     
    
        $taskParams = @{
            TaskPath = "\AAD Migration"
            TaskName = "PR4B-AADM Launch PSADT for Interactive Migration"
        }

        # Trigger OneDrive Sync Status Scheduled Task
        Trigger-ScheduledTask @taskParams


        # Post Run 1
        #The following is mainly responsible about enrolling the device in the tenant's Entra ID via a PPKG
        # $PostRunOncePhase1EntraJoinParams = @{
        #     MigrationConfigPath = "C:\ProgramData\AADMigration\MigrationConfig.psd1"
        #     ImagePath           = "C:\ProgramData\AADMigration\Files\MigrationInProgress.bmp"
        #     RunOnceScriptPath   = "C:\ProgramData\AADMigration\Scripts\PostRunOnce2.ps1"
        #     RunOnceKey          = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        #     PowershellPath      = "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe"
        #     ExecutionPolicy     = "Unrestricted"
        #     RunOnceName         = "NextRun"
        #     Mode                = "Dev"
        # }
        # PostRunOnce-Phase1EntraJoin @PostRunOncePhase1EntraJoinParams



        # Post Run 2
        #blocks user input, displays a migration in progress form, creates a scheduled task for post-migration cleanup, escrows the BitLocker recovery key, sets various registry values for legal noctices, and optionally restarts the computer.
        # $PostRunOncePhase2EscrowBitlockerParams = @{
        #     ImagePath        = "C:\ProgramData\AADMigration\Files\MigrationInProgress.bmp"
        #     TaskPath         = "AAD Migration"
        #     TaskName         = "Run Post migration cleanup"
        #     # BitlockerDrives       = @("C:", "D:")
        #     BitlockerDrives  = @("C:")
        #     RegistrySettings = @{
        #         "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"     = @{
        #             "AutoAdminLogon" = @{
        #                 "Type" = "DWORD"
        #                 "Data" = "0"
        #             }
        #         }
        #         "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" = @{
        #             "dontdisplaylastusername" = @{
        #                 "Type" = "DWORD"
        #                 "Data" = "1"
        #             }
        #             "legalnoticecaption"      = @{
        #                 "Type" = "String"
        #                 "Data" = "Migration Completed"
        #             }
        #             "legalnoticetext"         = @{
        #                 "Type" = "String"
        #                 "Data" = "This PC has been migrated to Azure Active Directory. Please log in to Windows using your email address and password."
        #             }
        #         }
        #     }
        #     Mode             = "Dev"
        # }
        # PostRunOnce-Phase2EscrowBitlocker @PostRunOncePhase2EscrowBitlockerParams



        # $taskParams = @{
        #     TaskPath = "\AAD Migration"
        #     TaskName = "Run Post migration cleanup"
        # }

        # Trigger OneDrive Sync Status Scheduled Task
        # Trigger-ScheduledTask @taskParams


        # Post Run 3
        # Scheduled task (not Once) for cleaning up temp user accounts and disabling all local accounts
        # $ExecuteMigrationCleanupTasksParams = @{
        #     TempUser             = "MigrationInProgress"
        #     RegistrySettings     = @{
        #         "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" = @{
        #             "dontdisplaylastusername" = @{
        #                 "Type" = "DWORD"
        #                 "Data" = "0"
        #             }
        #             "legalnoticecaption"      = @{
        #                 "Type" = "String"
        #                 "Data" = ""
        #             }
        #             "legalnoticetext"         = @{
        #                 "Type" = "String"
        #                 "Data" = ""
        #             }
        #         }
        #         "HKLM:\Software\Policies\Microsoft\Windows\Personalization"       = @{
        #             "NoLockScreen" = @{
        #                 "Type" = "DWORD"
        #                 "Data" = "0"
        #             }
        #         }
        #     }
        #     MigrationDirectories = @(
        #         "C:\ProgramData\AADMigration\Files",
        #         # "C:\ProgramData\AADMigration\Scripts",
        #         "C:\ProgramData\AADMigration\Toolkit"
        #     )
        #     Mode                 = "Dev"
        # }
        # Execute-MigrationCleanupTasks @ExecuteMigrationCleanupTasksParams


        Write-EnhancedLog -Message "All Post Run Once and Post Run Scheduled Tasks in Dev Mode completed" -Level "INFO"
    }
    else {


        Write-EnhancedLog -Message "Running all Post Run Once and Post Run Scheduled Tasks in prod Mode" -Level "WARNING"
     
    
        $taskParams = @{
            TaskPath = "\AAD Migration"
            TaskName = "PR4B-AADM Launch PSADT for Interactive Migration"
        }

        # Trigger OneDrive Sync Status Scheduled Task
        Trigger-ScheduledTask @taskParams

        # Write-EnhancedLog -Message "Skipping Running all Post Run Once and Post Run Scheduled Tasks in prod Mode" -Level "WARNING"
    }








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
    #     SkipSYSTEMLogCopy         = $false
    #     SkipSYSTEMLogRemoval      = $false
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