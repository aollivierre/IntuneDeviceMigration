#region FIRING UP MODULE STARTER
#################################################################################################
#                                                                                               #
#                                 FIRING UP MODULE STARTER                                      #
#                                                                                               #
#################################################################################################

# Fetch the script content
$scriptContent = Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1"

# Define replacements in a hashtable
$replacements = @{
    '\$Mode = "dev"'                     = '$Mode = "dev"'
    '\$SkipPSGalleryModules = \$false'   = '$SkipPSGalleryModules = $false'
    '\$SkipCheckandElevate = \$false'    = '$SkipCheckandElevate = $false'
    '\$SkipAdminCheck = \$false'         = '$SkipAdminCheck = $false'
    '\$SkipPowerShell7Install = \$false' = '$SkipPowerShell7Install = $false'
    '\$SkipModuleDownload = \$false'     = '$SkipModuleDownload = $false'
}

# Apply the replacements
foreach ($pattern in $replacements.Keys) {
    $scriptContent = $scriptContent -replace $pattern, $replacements[$pattern]
}

# Execute the script
Invoke-Expression $scriptContent

#endregion FIRING UP MODULE STARTER

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
$paramGetPSFCSVLogFilePath = @{
    LogsPath         = 'C:\Logs\PSF'
    JobName          = $jobName
    parentScriptName = $parentScriptName
}

$csvLogFilePath = Get-PSFCSVLogFilePath @paramGetPSFCSVLogFilePath
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
    Stop-Transcript

    # Stop PSF Logging

    # Ensure the log is written before proceeding
    Wait-PSFMessage

    # Stop logging in the finally block by disabling the provider
    Set-PSFLoggingProvider -Name 'logfile' -InstanceName $instanceName -Enabled $false

    Handle-Error -ErrorRecord $_
    throw $_  # Re-throw the error after logging it
} 
#endregion

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
        CustomizationsPath   = 'C:\code\IntuneDeviceMigration\DeviceMigration\PSADT-Customizations'
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
    #endregion
    
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
    Stop-Transcript

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