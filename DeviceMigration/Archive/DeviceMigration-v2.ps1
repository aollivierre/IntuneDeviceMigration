#Archived the following but might re-visti the logic to create tasks using a universal function


#region DEALING WITH MODULES
#################################################################################################
#                                                                                               #
#                                 DEALING WITH MODULES                                          #
#                                                                                               #
#################################################################################################

iex ((irm "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1") -replace '\$Mode = "dev"', '$Mode = "dev"' -replace 'SkipPSGalleryModules\s*=\s*false', 'SkipPSGalleryModules = false')

#endregion


#region HANDLE PSF MODERN LOGGING
#################################################################################################
#                                                                                               #
#                            HANDLE PSF MODERN LOGGING                                          #
#                                                                                               #
#################################################################################################

Set-PSFConfig -Fullname 'PSFramework.Logging.FileSystem.ModernLog' -Value $true -PassThru | Register-PSFConfig -Scope SystemDefault

#endregion


$JobName = "AAD_Migration"
# Start the script with error handling
try {
    # Generate the transcript file path
    # $transcriptPath = Get-TranscriptFilePath -Jobname $jobName

    $GetTranscriptFilePathParams = @{
        TranscriptsPath = "C:\Logs\Transcript"
        JobName         = $jobName
    }
    $transcriptPath = Get-TranscriptFilePath @GetTranscriptFilePathParams
    

    # Start the transcript
    Write-EnhancedLog -Message "Starting transcript at: $transcriptPath"




    Start-Transcript -Path $transcriptPath



    # Example script logic
    Write-EnhancedLog -Message "This is an example action being logged."

}
catch {
    Write-EnhancedLog -Message "An error occurred during script execution: $_" -Level 'ERROR'
    Stop-Transcript
    Handle-Error -ErrorRecord $_
    throw $_  # Re-throw the error after logging it
} 



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

    # Example usage of Download-And-Install-ServiceUI function with splatting
    $DownloadAndInstallServiceUIparams = @{
        TargetFolder           = "$PSScriptRoot"
        DownloadUrl            = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
        MsiFileName            = "MicrosoftDeploymentToolkit_x64.msi"
        InstalledServiceUIPath = "C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\ServiceUI.exe"
    }
    Download-And-Install-ServiceUI @DownloadAndInstallServiceUIparams


    # Example usage
    $DownloadPSAppDeployToolkitParams = @{
        GithubRepository     = 'PSAppDeployToolkit/PSAppDeployToolkit'
        FilenamePatternMatch = '*.zip'
        DestinationDirectory = $PSScriptRoot
        CustomizationsPath   = 'C:\code\IntuneDeviceMigration\DeviceMigration\PSADT-Customizations'
    }
    Download-PSAppDeployToolkit @DownloadPSAppDeployToolkitParams




    # we are skipping Download-ODSyncUtil here becuase we are calling withing the scheduled script of Check-ODSyncUtilStatus.ps1 as that will download the file as the user owner not as the SYSTEM owner below as the download logic will remove files and will encounter errors if files are not owned by the user
    # you may call the following during the Execute-MigrationTasks function flow


    # $DownloadODSyncUtilParams = @{
    #     Destination    = "$PSScriptRoot\Files\ODSyncUtil\ODSyncUtil.exe"
    #     ApiUrl         = "https://api.github.com/repos/rodneyviana/ODSyncUtil/releases/latest"
    #     ZipFileName    = "ODSyncUtil-64-bit.zip"
    #     ExecutableName = "ODSyncUtil.exe"
    #     MaxRetries     = 3
    # }
    # Download-ODSyncUtil @DownloadODSyncUtilParams


    # ################################################################################################################################
    # ############### END Downloading Service UI and PSADT ###########################################################################
    # ################################################################################################################################


    # Import migration configuration
    $ConfigFileName = "MigrationConfig.psd1"
    $ConfigBaseDirectory = $PSScriptRoot
    $MigrationConfig = Import-LocalizedData -BaseDirectory $ConfigBaseDirectory -FileName $ConfigFileName
    # $StartBoundary = $MigrationConfig.StartBoundary

    $TenantID = $MigrationConfig.TenantID
    $OneDriveKFM = $MigrationConfig.UseOneDriveKFM
    $InstallOneDrive = $MigrationConfig.InstallOneDrive



    # Define parameters
    $PrepareAADMigrationParams = @{
        MigrationPath       = "C:\ProgramData\AADMigration"
        PSScriptbase        = $PSScriptRoot
        # ConfigBaseDirectory = "C:\ConfigDirectory\Scripts"
        ConfigBaseDirectory = $PSScriptRoot
        ConfigFileName      = "MigrationConfig.psd1"
        TenantID            = $TenantID
        OneDriveKFM         = $OneDriveKFM
        InstallOneDrive     = $InstallOneDrive
    }

    # Example usage with splatting
    Prepare-AADMigration @PrepareAADMigrationParams




    # Set up migration task

    # $ScriptPath = "C:\ProgramData\AADMigration\Scripts\Execute-MigrationToolkit.ps1"
    # $MigrationTaskParams = @{
    #     StartBoundary = $StartBoundary
    #     ScriptPath    = "C:\ProgramData\AADMigration\Scripts\Execute-MigrationToolkit.ps1"
    #     TaskPath      = "AAD Migration"
    #     TaskName      = "AADM Launch PSADT for Interactive Migration"
    #     Description   = "AADM Launch PSADT for Interactive Migration"
    #     UserId        = "SYSTEM"
    #     RunLevel      = "Highest"
    #     Delay         = "PT1M"
    #     ExecutePath   = "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe"
    #     Arguments     = "-executionpolicy Bypass -file `"$ScriptPath`""
    # }

      
    # Example usage with splatting
    #Phase 2 Create the Migration task

    # Unregister-ScheduledTaskWithLogging -TaskName "AADM Launch PSADT for Interactive Migration"



    # New-MigrationTask @MigrationTaskParams


    # Define the parameters using a hashtable
    # $schedulerconfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config.psd1"
    # $taskParams = @{
    #     ConfigPath  = $schedulerconfigPath
    #     FileName    = "HiddenScript.vbs"
    #     Scriptroot  = "$PSScriptroot"
    # }

    # # Call the function with the splatted parameters
    # CreateAndRegisterScheduledTask @taskParams




    #Here we will schedule our Interactive Migration script (which is our script2 or our post-reboot script to run automatically at startup under the SYSTEM account)
    # here I need to pass these in the config file (JSON or PSD1) or here in the splat but I need to have it outside of the function


    # # $schedulerconfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config.psd1"
    # $schedulerconfigPath = "C:\code\IntuneDeviceMigration\DeviceMigration\Interactive-Migration-Task-config.psd1"
    # $taskParams = @{
    #     ConfigPath = $schedulerconfigPath
    #     FileName   = "run-ps-hidden.vbs"
    #     Scriptroot = $PSScriptRoot
    # }

    # CreateAndRegisterScheduledTask @taskParams

    




    # Example usage with splatting
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

    #region HANDLE PSF LOGGING
    #################################################################################################
    #                                                                                               #
    #                                 HANDLE PSF LOGGING                                            #
    #                                                                                               #
    #################################################################################################

    
    $parentScriptName = Get-ParentScriptName
    Write-Host "Parent Script Name: $parentScriptName"

    $HandlePSFLoggingParams = @{
        SystemSourcePathWindowsPS = "C:\Windows\System32\config\systemprofile\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
        SystemSourcePathPS        = "C:\Windows\System32\config\systemprofile\AppData\Roaming\PowerShell\PSFramework\Logs\"
        UserSourcePathWindowsPS   = "$env:USERPROFILE\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
        UserSourcePathPS          = "$env:USERPROFILE\AppData\Roaming\PowerShell\PSFramework\Logs\"
        PSFPath                   = "C:\Logs\PSF"
        ParentScriptName          = $parentScriptName
        JobName                   = $JobName
    }

    Handle-PSFLogging @HandlePSFLoggingParams
    #endregion

}
finally {
    # Ensure that the transcript is stopped even if an error occurs
    if ($transcriptPath) {
        Stop-Transcript
        Write-Host "Transcript stopped." -ForegroundColor Cyan
    }
    else {
        Write-Host "Transcript was not started due to an earlier error." -ForegroundColor Red
    }
}
