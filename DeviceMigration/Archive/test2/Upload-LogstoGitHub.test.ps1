param (
    [SecureString]$SecurePAT
)

$global:mode = $env:EnvironmentMode
# $global:mode = 'dev'

function Write-LogsUploadGitHub {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )

    # Get the PowerShell call stack to determine the actual calling function
    $callStack = Get-PSCallStack
    $callerFunction = if ($callStack.Count -ge 2) { $callStack[1].Command } else { '<Unknown>' }

    # Prepare the formatted message with the actual calling function information
    $formattedMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] [$callerFunction] $Message"

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

    # Append to log file
    $logFilePath = [System.IO.Path]::Combine($env:TEMP, 'logsupload.log')
    $formattedMessage | Out-File -FilePath $logFilePath -Append -Encoding utf8
}

# Toggle based on the environment mode
switch ($global:mode) {
    'dev' {
        Write-LogsUploadGitHub "Running in development mode" -Level 'Warning'
        # Your development logic here
    }
    'prod' {
        Write-LogsUploadGitHub "Running in production mode" -Level 'INFO'
        # Your production logic here
    }
    default {
        Write-LogsUploadGitHub "Unknown mode. Defaulting to production." -Level 'ERROR'
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

# Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Install-EnhancedModuleStarterAO.ps1")

# Wait-Debugger

# Import-Module 'C:\code\ModulesV2\EnhancedModuleStarterAO\EnhancedModuleStarterAO.psm1'

# Define a hashtable for splatting
# $moduleStarterParams = @{
#     Mode                   = $global:mode
#     SkipPSGalleryModules   = $false
#     SkipCheckandElevate    = $false
#     SkipPowerShell7Install = $false
#     SkipEnhancedModules    = $false
#     SkipGitRepos           = $true
# }

# Call the function using the splat
# Invoke-ModuleStarter @moduleStarterParams

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



#region HANDLE PSF MODERN LOGGING
#################################################################################################
#                                                                                               #
#                            HANDLE PSF MODERN LOGGING                                          #
#                                                                                               #
#################################################################################################
Set-PSFConfig -Fullname 'PSFramework.Logging.FileSystem.ModernLog' -Value $true -PassThru | Register-PSFConfig -Scope SystemDefault

# Define the base logs path and job name
$JobName = "Logs_GitHubUpload"
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
        Write-LogsUploadGitHub "Transcript stopped." -Level 'WARNING'
        # Stop logging in the finally block

    }
    else {
        Write-LogsUploadGitHub "Transcript was not started due to an earlier error." -Level 'ERROR'
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

    # #region Script Logic
    # #################################################################################################
    # #                                                                                               #
    # #                                    Script Logic                                               #
    # #                                                                                               #
    # #################################################################################################



    # $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePAT)
    # $pat = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)



    # $params = @{
    #     MinVersion   = [version]"2.46.0"
    #     RegistryPath = "HKLM:\SOFTWARE\GitForWindows"
    #     ExePath      = "C:\Program Files\Git\bin\git.exe"
    # }
    # Ensure-GitIsInstalled @params

    # # Wait-Debugger

    # # Define paths and variables
    # $logsFolderPath = "C:\logs"
    # $tempCopyPath = "C:\temp-logs"
    # $tempGitPath = "C:\temp-git"
    # $tempZipFile = Join-Path -Path $tempGitPath -ChildPath "logs.zip"
    # $repoPath = "C:\temp-git\syslog"
    # $gitExePath = "C:\Program Files\Git\bin\git.exe" # Adjust if needed
    # $gitUsername = "aollivierre" # Your GitHub username
    # $personalAccessToken = $pat # Your GitHub PAT
    # $repoUrlsanitized = "https://github.com/$gitUsername/syslog.git"
    # $repoUrl = "https://{0}:{1}@github.com/{2}/syslog.git" -f $gitUsername, $personalAccessToken, $gitUsername
    # $commitMessage = "Add logs.zip"
    # $branchName = "main" # Change if you're using a different branch name




    # # Assuming Test-RunningAsSystem is defined and available for use

  





    # # Remove tempGitPath if it exists
    # if (Test-Path -Path $tempGitPath) {
    #     Write-LogsUploadGitHub -Message "Removing $tempGitPath..."
    #     Remove-Item -Path $tempGitPath -Recurse -Force
    # }
    # else {
    #     Write-LogsUploadGitHub -Message "$tempGitPath does not exist, skipping removal."
    # }


    # # Ensure the temp directory exists
    # if (-Not (Test-Path -Path $tempGitPath)) {
    #     New-Item -Path $tempGitPath -ItemType Directory | Out-Null
    # }


    # # Remove-Item -Path $tempGitPath -Recurse -Force

    # # Zip the logs folder to the temp location
    # Write-LogsUploadGitHub -Message "Zipping the logs folder..."


    # # Remove tempCopyPath if it exists
    # if (Test-Path -Path $tempCopyPath) {
    #     Write-LogsUploadGitHub -Message "Removing $tempCopyPath..."
    #     Remove-Item -Path $tempCopyPath -Recurse -Force
    # }
    # else {
    #     Write-LogsUploadGitHub -Message "$tempCopyPath does not exist, skipping removal."
    # }


    # # Ensure the destination directory exists
    # if (-not (Test-Path -Path $tempCopyPath)) {
    #     New-Item -Path $tempCopyPath -ItemType Directory
    # }

    # # Use the Copy-FilesWithRobocopy function to copy files
    # Copy-FilesWithRobocopy -Source $logsFolderPath -Destination $tempCopyPath -FilePattern '*' -Exclude ".git"

    # # Wait-Debugger

    # # Compress the copied files
    # # Compress-Archive -Path $tempCopyPath -DestinationPath $tempZipFile -Force

    # $params = @{
    #     SourceDirectory = $tempCopyPath
    #     ZipFilePath     = $tempZipFile
    # }
    # Zip-Directory @params


    # # Wait-Debugger

    # # Cleanup the temporary copy

    # # Remove tempCopyPath if it exists
    # if (Test-Path -Path $tempCopyPath) {
    #     Write-LogsUploadGitHub -Message "Removing $tempCopyPath..."
    #     Remove-Item -Path $tempCopyPath -Recurse -Force
    # }
    # else {
    #     Write-LogsUploadGitHub -Message "$tempCopyPath does not exist, skipping removal."
    # }



    # # Check if the zip file was created
    # if (-Not (Test-Path -Path $tempZipFile)) {
    #     Write-LogsUploadGitHub -Message "Failed to zip the logs folder." -ForegroundColor Red
    #     exit 1
    # }

    # Set-Location -Path $tempGitPath

    # # Clone the repo if it doesn't exist
    # if (-Not (Test-Path -Path $repoPath)) {
    #     Write-LogsUploadGitHub -Message "Cloning repository from $repoUrlsanitized..."
    #     & "$gitExePath" clone $repoUrl

    #     # Initialize a new git repository
    #     # & "$gitExePath" init

    #     # Add the remote repository
    #     # & "$gitExePath" remote add origin $repoUrl

    # }

    # # Wait-Debugger



 
  





    # #Region Creating the Destination Folder inside the Repo Folder
    # # Get the computer name
    # $computerName = $env:COMPUTERNAME
    # # $destFolder = Join-Path -Path $repoPath -ChildPath "$computerName-$currentDate"
    # # Define the folder for the computer name
    # $computerNameFolder = Join-Path -Path $repoPath -ChildPath "$computerName"

    # # Define the folder for the date inside the computer name folder
    # $currentDate = Get-Date -Format "yyyy-MM-dd"
    # $dateFolder = Join-Path -Path $computerNameFolder -ChildPath "$currentDate"

    # # Get the current time and format it like 7-08-AM or 7-08-PM
    # $currentTime = Get-Date -Format "h-mm-tt" # Example: 7-08-AM
    # $timeFolder = Join-Path -Path $dateFolder -ChildPath "$currentTime"

    # # Define the job name folder inside the timestamp folder
    # $jobname = 'AADMigration'
    # $jobFolder = Join-Path -Path $timeFolder -ChildPath "$jobname"

    # # Ensure the computer name folder exists
    # if (-Not (Test-Path -Path $computerNameFolder)) {
    #     New-Item -Path $computerNameFolder -ItemType Directory | Out-Null
    # }

    # # Ensure the date folder exists
    # if (-Not (Test-Path -Path $dateFolder)) {
    #     New-Item -Path $dateFolder -ItemType Directory | Out-Null
    # }

    # # Ensure the time folder exists inside the date folder
    # if (-Not (Test-Path -Path $timeFolder)) {
    #     New-Item -Path $timeFolder -ItemType Directory | Out-Null
    # }

    # # Ensure the job name folder exists inside the time folder
    # if (-Not (Test-Path -Path $jobFolder)) {
    #     New-Item -Path $jobFolder -ItemType Directory | Out-Null
    # }

    # # Now, $jobFolder is the destination folder
    # $destFolder = $jobFolder

    # # Wait-Debugger

    # #endregion Creating the Destination Folder inside the Repo Folder




    # # Create the folder named after the computer name, date, time and joba name
    # # if (-Not (Test-Path -Path $destFolder)) {
    # #     New-Item -Path $destFolder -ItemType Directory | Out-Null
    # # }

    # # Copy the zipped log file to the repository folder
    # Copy-Item -Path $tempZipFile -Destination $destFolder -Force

    # # Change to the repo directory
    # # Set-Location -Path $repoPath


    # Set-Location -Path $repoPath

    # # Check if running as SYSTEM account
    # $isSystem = Test-RunningAsSystem

    # if ($isSystem) {
    #     # Running as SYSTEM: Set local Git user identity for system commits
    #     & "$gitExePath" config user.email "system@example.com"
    #     & "$gitExePath" config user.name "System User"
    #     Write-EnhancedLog -Message "Configured Git identity for SYSTEM account." -Level "INFO"
    # }
    # else {
    #     # Not running as SYSTEM: Set local Git user identity for the current logged in user
    #     $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    #     $currentUserEmail = "$($currentUser.Replace('\', '_'))@example.com"  # Example: Format the email based on user name
  
    #     & "$gitExePath" config user.email $currentUserEmail
    #     & "$gitExePath" config user.name $currentUser
    #     Write-EnhancedLog -Message "Configured Git identity for user: $currentUser." -Level "INFO"
    # }
  
    # Write-EnhancedLog -Message "Git user identity configuration complete." -Level "NOTICE"




    # # Add, commit, and push the zipped log file
    # & "$gitExePath" add *
    # & "$gitExePath" commit -m "$commitMessage from $computerName on $currentDate"
    # & "$gitExePath" push origin $branchName

    # Write-LogsUploadGitHub -Message "Zipped log file copied to $destFolder and pushed to the repository." -ForegroundColor Green


    # # Change to a location outside the $tempGitPath directory before deleting it
    # Set-Location -Path "C:\" # Change to any path that is not inside $tempGitPath

    # # Clean up the temp directory
    # Write-LogsUploadGitHub -Message "Cleaning up the temp $tempGitPath directory..."
    # Remove-Item -Path $tempGitPath -Recurse -Force

    # Write-LogsUploadGitHub -Message "Process completed and temp $tempGitPath directory cleaned up." -ForegroundColor Green



    # $params = @{
    #     SecurePAT      = $securePat
    #     GitExePath     = "C:\Program Files\Git\bin\git.exe"
    #     LogsFolderPath = "C:\logs"
    #     TempCopyPath   = "C:\temp-logs"
    #     TempGitPath    = "C:\temp-git"
    #     GitUsername    = "aollivierre"
    #     BranchName     = "main"
    #     CommitMessage  = "Add logs.zip"
    #     RepoName       = "syslog"
    #     JobName        = "AADMigration"
    # }
    
    # Upload-LogsToGitHub @params



    
    # Ensure $tempPath exists
    $secureFilePath = "$tempPath\$global:JobName-secrets\SecurePAT.txt"
    if (-not (Test-Path "$tempPath\$global:JobName-secrets")) {
        New-Item -Path "$tempPath\$global:JobName-secrets" -ItemType Directory
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
        Write-EnhancedLog -Message "SecurePAT is a valid SecureString."
    }
    else {
        Write-EnhancedLog -Message "SecurePAT is NOT a valid SecureString."
    }




    # Example usage
    try {
        # $tempPath = Get-ReliableTempPath -LogLevel "INFO"
        $tempPath = 'c:\temp'
        Write-LogsUploadGitHub -Message "Temp Path Set To: $tempPath"
    }
    catch {
        Write-LogsUploadGitHub -Message "Failed to get a valid temp path: $_"
    }

    $global:JobName = "AAD_Migration"



    $params = @{
        SecurePAT      = $securePat
        GitExePath     = "C:\Program Files\Git\bin\git.exe"
        LogsFolderPath = "C:\logs"
        TempCopyPath   = "$tempPath\$global:JobName-logs"
        TempGitPath    = "$tempPath\$global:JobName-git"
        GitUsername    = "aollivierre"
        BranchName     = "main"
        CommitMessage  = "Add logs.zip"
        RepoName       = "syslog"
        JobName        = $global:JobName
    }
    
    Upload-LogsToGitHub @params




    #endregion Script Logic
}
catch {
    Write-EnhancedLog -Message "An error occurred during script execution: $_" -Level 'ERROR'
    if ($transcriptPath) {
        Stop-Transcript
        Write-LogsUploadGitHub "Transcript stopped." -Level 'WARNING'
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
        Write-LogsUploadGitHub "Transcript stopped." -Level 'WARNING'
        # Stop logging in the finally block

    }
    else {
        Write-LogsUploadGitHub "Transcript was not started due to an earlier error." -Level 'ERROR'
    }
    
    # Ensure the log is written before proceeding
    Wait-PSFMessage

    # Stop logging in the finally block by disabling the provider
    Set-PSFLoggingProvider -Name 'logfile' -InstanceName $instanceName -Enabled $false

}