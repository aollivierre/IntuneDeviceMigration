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



$global:LOG_ASYNC = $false

# Check if async logging is enabled
if ($global:LOG_ASYNC) {
    # Initialize the global log queue and start the async logging job
    if (-not $global:LogQueue) {
        $global:LogQueue = [System.Collections.Concurrent.ConcurrentQueue[PSCustomObject]]::new()

        $global:LogJob = Start-Job -ScriptBlock {
            param ($logQueue)

            # Check if PSFramework's Write-PSFMessage is available
            $psfMessageAvailable = Get-Command -Name Write-PSFMessage -ErrorAction SilentlyContinue

            while ($true) {
                if ($logQueue.TryDequeue([ref]$logItem)) {
                    if ($psfMessageAvailable) {
                        # If PSFramework is available, use Write-PSFMessage
                        Write-PSFMessage -Level $logItem.Level -Message $logItem.Message -FunctionName $logItem.FunctionName
                    }
                    else {
                        # Fallback to Write-Host if PSFramework is not available
                        $logColor = switch ($logItem.Level.ToUpper()) {
                            'DEBUG' { 'DarkGray' }
                            'INFO' { 'Green' }
                            'NOTICE' { 'Cyan' }
                            'WARNING' { 'Yellow' }
                            'ERROR' { 'Red' }
                            'CRITICAL' { 'Magenta' }
                            default { 'White' }
                        }
                        Write-Host "[$($logItem.Level)] $($logItem.Message)" -ForegroundColor $logColor
                    }
                }
                else {
                    Start-Sleep -Milliseconds 100
                }
            }
        } -ArgumentList $global:LogQueue
    }
}


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





# Toggle based on the environment mode
switch ($global:mode) {
    'dev' {
        Write-AADMigrationLog "Running in development mode" -Level 'Warning'
        # Your development logic here
    }
    'prod' {
        Write-AADMigrationLog "Running in production mode" -Level 'INFO'
        # Your production logic here
    }
    default {
        Write-AADMigrationLog "Unknown mode. Defaulting to production." -Level 'ERROR'
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


# Wait-Debugger

Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Install-EnhancedModuleStarterAO.ps1")

# Wait-Debugger

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



# $global:LOG_ASYNC = $true

# # Check if async logging is enabled
# if ($global:LOG_ASYNC) {
#     # Initialize the global log queue and start the async logging job
#     if (-not $global:LogQueue) {
#         $global:LogQueue = [System.Collections.Concurrent.ConcurrentQueue[PSCustomObject]]::new()

#         $global:LogJob = Start-Job -ScriptBlock {
#             param ($logQueue)

#             while ($true) {
#                 if ($logQueue.TryDequeue([ref]$logItem)) {
#                     Write-PSFMessage -Level $logItem.Level -Message $logItem.Message -FunctionName $logItem.FunctionName
#                 }
#                 else {
#                     Start-Sleep -Milliseconds 100
#                 }
#             }
#         } -ArgumentList $global:LogQueue
#     }
# }



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
        Write-AADMigrationLog "Starting AAD migration artifact cleanup..."
    }

    Process {
        # Define paths to clean up
        $pathsToClean = @(
            @{ Path = "C:\logs"; Name = "Logs Path" },
            @{ Path = "C:\ProgramData\AADMigration"; Name = "AADMigration Path" },
            @{ Path = "C:\temp"; Name = "AADMigration Secrets Path" },
            @{ Path = "C:\temp-logs"; Name = "Temp Logs Path" }, # Added
            @{ Path = "C:\temp-git"; Name = "Temp Git Path" }, # Added
            @{ Path = "C:\temp-git\logs.zip"; Name = "Temp Zip File" }, # Added
            @{ Path = "C:\temp-git\syslog"; Name = "Syslog Repo Path" } # Added
        )

        # Loop through each path and perform the check and removal
        foreach ($item in $pathsToClean) {
            $path = $item.Path
            $name = $item.Name

            if (Test-Path -Path $path) {
                Write-AADMigrationLog "Removing $name ($path)..." -Level 'INFO'
                Remove-Item -Path $path -Recurse -Force

                # Remove-EnhancedItem -Path $path -MaxRetries 3 -RetryInterval 3

            }
            else {
                Write-AADMigrationLog "$name ($path) does not exist, skipping..." -Level 'WARNING'
            }
        }

        Write-AADMigrationLog "Path cleanup complete." -Level 'NOTICE'



        # Remove all scheduled tasks under the AAD Migration task path
        $scheduledTasks = Get-ScheduledTask -TaskPath '\AAD Migration\' -ErrorAction SilentlyContinue
        if ($scheduledTasks) {
            foreach ($task in $scheduledTasks) {
                Write-AADMigrationLog "Removing scheduled task: $($task.TaskName)..." -Level 'INFO'
                Unregister-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Confirm:$false
            }
        }
        else {
            Write-AADMigrationLog "No scheduled tasks found under \AAD Migration, skipping..." -Level 'WARNING'
        }

        # Remove the scheduled task folder named AAD Migration
        try {
            $taskFolder = New-Object -ComObject "Schedule.Service"
            $taskFolder.Connect()
            $rootFolder = $taskFolder.GetFolder("\")
            $aadMigrationFolder = $rootFolder.GetFolder("AAD Migration")
            $aadMigrationFolder.DeleteFolder("", 0)
            Write-AADMigrationLog "Scheduled task folder AAD Migration removed successfully." -Level 'INFO'
        }
        catch {
            Write-AADMigrationLog "Scheduled task folder AAD Migration does not exist or could not be removed." -Level 'ERROR'
        }

        # Remove the local user called MigrationInProgress
        $localUser = "MigrationInProgress"
        try {
            $user = Get-LocalUser -Name $localUser -ErrorAction Stop
            if ($user) {
                Write-AADMigrationLog "Removing local user $localUser..." -Level 'INFO'
                Remove-LocalUser -Name $localUser -Force
            }
        }
        catch {
            Write-AADMigrationLog "Local user $localUser does not exist, skipping..." -Level 'WARNING'
        }


        $RegistrySettings = @(
            @{
                RegValName = "dontdisplaylastusername"
                RegValType = "DWORD"
                RegValData = "0"
                RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            },
            @{
                RegValName = "legalnoticecaption"
                RegValType = "String"
                RegValData = ""
                RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            },
            @{
                RegValName = "legalnoticetext"
                RegValType = "String"
                RegValData = ""
                RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            },
            @{
                RegValName = "NoLockScreen"
                RegValType = "DWORD"
                RegValData = "0"
                RegKeyPath = "HKLM:\Software\Policies\Microsoft\Windows\Personalization"
            }
        )






        
        # Create a new hashtable to store settings grouped by their RegKeyPath
        $groupedSettings = @{}

        # Group the registry settings by their RegKeyPath
        foreach ($regSetting in $RegistrySettings) {
            $regKeyPath = $regSetting.RegKeyPath
     
            if (-not $groupedSettings.ContainsKey($regKeyPath)) {
                $groupedSettings[$regKeyPath] = @()
            }
     
            # Add the current setting to the appropriate group
            $groupedSettings[$regKeyPath] += $regSetting
        }
     
        # Now apply the grouped registry settings
        foreach ($regKeyPath in $groupedSettings.Keys) {
            $settingsForKey = $groupedSettings[$regKeyPath]
     
            # Call Apply-RegistrySettings once per group with the correct RegKeyPath
            Apply-RegistrySettings -RegistrySettings $settingsForKey -RegKeyPath $regKeyPath
        }






        # Wait-Debugger



    }

    End {
        Write-AADMigrationLog "AAD migration artifact cleanup completed." -Level 'INFO'
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
        Write-AADMigrationLog "Transcript stopped." -Level 'WARNING'
        # Stop logging in the finally block

    }
    else {
        Write-AADMigrationLog "Transcript was not started due to an earlier error." -Level 'ERROR'
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


    # Main execution
    try {
        Write-EnhancedLog -Message "Script execution started" -Level "NOTICE"
        Manage-UserSessions
    }
    catch {
        Handle-Error -ErrorRecord $_
    }
    finally {
        Write-EnhancedLog -Message "Script execution finished" -Level "NOTICE"
    }


    # Wait-Debugger


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


    # Ensure you are in the script's directory


    # Prompt the user for the PAT securely
    # $SecurePAT = Read-Host "Please enter your GitHub Personal Access Token (PAT)" -AsSecureString
    # & "$PSScriptRoot\Decrypt-PPKG.ps1" -SecurePAT $SecurePAT


    # First, securely prompt for the GitHub Personal Access Token (PAT)
    # $SecurePAT = Read-Host -AsSecureString "Please enter your GitHub Personal Access Token (PAT)"


    # Ensure C:\temp exists
    $secureFilePath = "C:\temp\SecurePAT.txt"
    if (-not (Test-Path "C:\temp")) {
        New-Item -Path "C:\temp" -ItemType Directory
    }

    $SecurePAT = Get-GitHubPAT

    if ($null -ne $SecurePAT) {
        # Continue with the secure PAT
        Write-EnhancedLog -Message "Using the captured PAT..."
        # Further logic here
    }
    else {
        Write-EnhancedLog -Message "No PAT was captured."
    }
    
    
    if ($SecurePAT -is [System.Security.SecureString]) {
        Write-Host "SecurePAT is a valid SecureString."
    }
    else {
        Write-Host "SecurePAT is NOT a valid SecureString."
    }
    
    
    # Wait-Debugger
    
    
    # Key Gen
    
    # Generate a valid 256-bit (32-byte) key
    $key = (1..32 | ForEach-Object { Get-Random -Maximum 256 }) -join ','
    
    # Convert the key into a byte array
    $keyBytes = $key -split ',' | ForEach-Object { [byte]$_ }
    
    # Save the key as comma-separated values to a file
    $key | Out-File "C:\temp\SecureKey.txt"
    
    
    
    #Encryption
    
    # Convert the PAT to SecureString
    # $SecurePAT = $SecurePAT | ConvertTo-SecureString -AsPlainText -Force
    
    # Encrypt using the generated 256-bit key
    $EncryptedPAT = $SecurePAT | ConvertFrom-SecureString -Key $keyBytes
    
    # Save the encrypted PAT to a file
    $EncryptedPAT | Out-File $secureFilePath



    # Wait-Debugger

    # Define the splatted parameters
    $params = @{
        SecurePAT                 = $SecurePAT
        RepoOwner                 = "aollivierre"
        RepoName                  = "Vault"
        ReleaseTag                = "0.1"
        FileName                  = "vault.GH.Asset.zip"
        DestinationPath           = "C:\temp\vault.GH.Asset.zip"
        ZipFilePath               = "C:\temp\vault.zip"
        CertBase64Path            = "C:\temp\vault\certs\cert.pfx.base64"
        CertPasswordPath          = "C:\temp\vault\certs\certpassword.txt"
        KeyBase64Path             = "C:\temp\vault\certs\secret.key.encrypted.base64"
        EncryptedFilePath         = "C:\temp\vault\vault.zip.encrypted"
        CertsDir                  = "C:\temp\vault\certs"
        DecryptedFilePath         = "C:\temp\vault.zip"
        KeePassDatabasePath       = "C:\temp\vault-decrypted\myDatabase.kdbx"
        KeyFilePath               = "C:\temp\vault-decrypted\myKeyFile.keyx"
        EntryName                 = "ICTC-EJ-PPKG"
        AttachmentName            = "ICTC_Project_2_Aug_29_2024.zip"
        ExportPath                = "C:\temp\vault-decrypted\ICTC_Project_2_Aug_29_2024-fromdb.zip"
        FinalDestinationDirectory = "C:\temp\vault-decrypted"
    }

    # Invoke the function using the splatted parameters
    Invoke-VaultDecryptionProcess @params


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
            TaskPath = "AAD Migration"
            TaskName = "PR4B-AADM Launch PSADT for Interactive Migration"
        }

        # Trigger OneDrive Sync Status Scheduled Task
        Trigger-ScheduledTask @taskParams

        Write-EnhancedLog -Message "All Post Run Once and Post Run Scheduled Tasks in Dev Mode completed" -Level "INFO"
    }
    else {


        Write-EnhancedLog -Message "Running all Post Run Once and Post Run Scheduled Tasks in prod Mode" -Level "WARNING"
     
    
        $taskParams = @{
            TaskPath = "AAD Migration"
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
    $parentScriptName = Get-ParentScriptName
    Write-AADMigrationLog "Parent Script Name: $parentScriptName"

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
        Write-AADMigrationLog "Transcript stopped." -Level 'WARNING'
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
        Write-AADMigrationLog "Transcript stopped." -Level 'WARNING'
        # Stop logging in the finally block

    }
    else {
        Write-AADMigrationLog "Transcript was not started due to an earlier error." -Level 'ERROR'
    }
    
    # Ensure the log is written before proceeding
    Wait-PSFMessage

    # Stop logging in the finally block by disabling the provider
    Set-PSFLoggingProvider -Name 'logfile' -InstanceName $instanceName -Enabled $false

}