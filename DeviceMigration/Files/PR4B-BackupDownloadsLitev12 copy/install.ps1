#Unique Tracking ID: a810e60d-3f98-49c6-a4c1-57d10316302f, Timestamp: 2024-03-07 15:35:33
<#
.SYNOPSIS
    Automates the detection and remediation of issues related to Bitlocker Escrow Recovery Key to Entra ID/Intune.

.DESCRIPTION
    This script, named "PR4B_BitLockerRecoveryEscrow" is designed to automate the process of detecting and remediating common issues associated with Bitlocker configurations on Windows systems. It leverages scheduled tasks to periodically check for and address these issues, ensuring that the system's Bitlocker settings remain optimal. The script includes functions for testing execution context, creating hidden VBScript wrappers for PowerShell, checking for existing tasks, executing detection and remediation scripts, and registering scheduled tasks with specific parameters.

.PARAMETER PackageName
    The name of the package, used for logging and task naming.

.PARAMETER Version
    The version of the script, used in task descriptions and for version control.

.FUNCTIONS
    Test-RunningAsSystem
        Checks if the script is running with System privileges.
        
    Create-VBShiddenPS
        Creates a VBScript to execute PowerShell scripts hidden.
        
    Check-ExistingTask
        Checks for the existence of a scheduled task based on name and version.
        
    Execute-DetectionAndRemediation
        Executes detection and remediation scripts based on the outcome of the detection.
        
    MyRegisterScheduledTask
        Registers a scheduled task with the system to automate the execution of this script.

.EXAMPLE
    .\PR4B_RemoveBitlocker.ps1
    Executes the script with default parameters, initiating the detection and remediation process.

.NOTES
    Author: Abdullah Ollivierre (Credits for Florian Salzmann)
    Contact: Organization IT
    Created on: Feb 07, 2024
    Last Updated: Feb 07, 2024

    This script is intended for use by IT professionals familiar with PowerShell and BitLocker. It should be tested in a non-production environment before being deployed in a live setting.

.VERSION HISTORY
    1.0 - Initial version.
    2.0 - Added VBScript creation for hidden execution.
    3.0 - Implemented scheduled task checking and updating based on script version.
    4.0 - Enhanced detection and remediation script execution process.
    5.0 - Introduced dynamic scheduling for task execution.
    6.0 - Optimized logging and transcript management.
    7.0 - Improved error handling and reporting mechanisms.
    8.0 - Current version, with various bug fixes and performance improvements.


    Unique Tracking ID: 215c2d78-1295-439e-8ff5-74e423f8717f
    
#>



# Read configuration from the JSON file
$configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.json"
$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

# Assign values from JSON to variables
$PackageName = $config.PackageName
$PackageUniqueGUID = $config.PackageUniqueGUID
$Version = $config.Version
$PackageExecutionContext = $config.PackageExecutionContext
$RepetitionInterval = $config.RepetitionInterval
$ScriptMode = $config.ScriptMode


# Assign values from JSON to variables
$LoggingDeploymentName = $config.LoggingDeploymentName
    
function Initialize-ScriptAndLogging {
    $ErrorActionPreference = 'SilentlyContinue'
    $deploymentName = "$LoggingDeploymentName" # Replace this with your actual deployment name
    $scriptPath = "C:\code\$deploymentName"
    # $hadError = $false
    
    try {
        if (-not (Test-Path -Path $scriptPath)) {
            New-Item -ItemType Directory -Path $scriptPath -Force | Out-Null
            Write-Host "Created directory: $scriptPath"
        }
    
        $computerName = $env:COMPUTERNAME
        $Filename = "$LoggingDeploymentName"
        $logDir = Join-Path -Path $scriptPath -ChildPath "exports\Logs\$computerName"
        $logPath = Join-Path -Path $logDir -ChildPath "$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')"
            
        if (!(Test-Path $logPath)) {
            Write-Host "Did not find log file at $logPath" -ForegroundColor Yellow
            Write-Host "Creating log file at $logPath" -ForegroundColor Yellow
            $createdLogDir = New-Item -ItemType Directory -Path $logPath -Force -ErrorAction Stop
            Write-Host "Created log file at $logPath" -ForegroundColor Green
        }
            
        $logFile = Join-Path -Path $logPath -ChildPath "$Filename-Transcript.log"
        Start-Transcript -Path $logFile -ErrorAction Stop | Out-Null
    
        $CSVDir = Join-Path -Path $scriptPath -ChildPath "exports\CSV"
        $CSVFilePath = Join-Path -Path $CSVDir -ChildPath "$computerName"
            
        if (!(Test-Path $CSVFilePath)) {
            Write-Host "Did not find CSV file at $CSVFilePath" -ForegroundColor Yellow
            Write-Host "Creating CSV file at $CSVFilePath" -ForegroundColor Yellow
            $createdCSVDir = New-Item -ItemType Directory -Path $CSVFilePath -Force -ErrorAction Stop
            Write-Host "Created CSV file at $CSVFilePath" -ForegroundColor Green
        }
    
        return @{
            ScriptPath  = $scriptPath
            Filename    = $Filename
            LogPath     = $logPath
            LogFile     = $logFile
            CSVFilePath = $CSVFilePath
        }
    
    }
    catch {
        Write-Error "An error occurred while initializing script and logging: $_"
    }
}
$initializationInfo = Initialize-ScriptAndLogging
    
    
    
# Script Execution and Variable Assignment
# After the function Initialize-ScriptAndLogging is called, its return values (in the form of a hashtable) are stored in the variable $initializationInfo.
    
# Then, individual elements of this hashtable are extracted into separate variables for ease of use:
    
# $ScriptPath: The path of the script's main directory.
# $Filename: The base name used for log files.
# $logPath: The full path of the directory where logs are stored.
# $logFile: The full path of the transcript log file.
# $CSVFilePath: The path of the directory where CSV files are stored.
# This structure allows the script to have a clear organization regarding where logs and other files are stored, making it easier to manage and maintain, especially for logging purposes. It also encapsulates the setup logic in a function, making the main script cleaner and more focused on its primary tasks.
    
    
$ScriptPath = $initializationInfo['ScriptPath']
$Filename = $initializationInfo['Filename']
$logPath = $initializationInfo['LogPath']
$logFile = $initializationInfo['LogFile']
$CSVFilePath = $initializationInfo['CSVFilePath']
    
    
    
    
function AppendCSVLog {
    param (
        [string]$Message,
        [string]$CSVFilePath
           
    )
    
    $csvData = [PSCustomObject]@{
        TimeStamp    = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        ComputerName = $env:COMPUTERNAME
        Message      = $Message
    }
    
    $csvData | Export-Csv -Path $CSVFilePath -Append -NoTypeInformation -Force
}
    
    
    
function CreateEventSourceAndLog {
    param (
        [string]$LogName,
        [string]$EventSource
    )
    
    
    # Validate parameters
    if (-not $LogName) {
        Write-Warning "LogName is required."
        return
    }
    if (-not $EventSource) {
        Write-Warning "Source is required."
        return
    }
    
    # Function to create event log and source
    function CreateEventLogSource($logName, $EventSource) {
        try {
            if ($PSVersionTable.PSVersion.Major -lt 6) {
                New-EventLog -LogName $logName -Source $EventSource
            }
            else {
                [System.Diagnostics.EventLog]::CreateEventSource($EventSource, $logName)
            }
            Write-Host "Event source '$EventSource' created in log '$logName'" -ForegroundColor Green
        }
        catch {
            Write-Warning "Error creating the event log. Make sure you run PowerShell as an Administrator."
        }
    }
    
    # Check if the event log exists
    if (-not (Get-WinEvent -ListLog $LogName -ErrorAction SilentlyContinue)) {
        # CreateEventLogSource $LogName $EventSource
    }
    # Check if the event source exists
    elseif (-not ([System.Diagnostics.EventLog]::SourceExists($EventSource))) {
        # Unregister the source if it's registered with a different log
        $existingLogName = (Get-WinEvent -ListLog * | Where-Object { $_.LogName -contains $EventSource }).LogName
        if ($existingLogName -ne $LogName) {
            Remove-EventLog -Source $EventSource -ErrorAction SilentlyContinue
        }
        # CreateEventLogSource $LogName $EventSource
    }
    else {
        Write-Host "Event source '$EventSource' already exists in log '$LogName'" -ForegroundColor Yellow
    }
}
    
$LogName = (Get-Date -Format "HHmmss") + "_$LoggingDeploymentName"
$EventSource = (Get-Date -Format "HHmmss") + "_$LoggingDeploymentName"
    
# Call the Create-EventSourceAndLog function
CreateEventSourceAndLog -LogName $LogName -EventSource $EventSource
    
# Call the Write-CustomEventLog function with custom parameters and level
# Write-CustomEventLog -LogName $LogName -EventSource $EventSource -EventMessage "Outlook Signature Restore completed with warnings." -EventID 1001 -Level 'WARNING'
    
    
    
    
function Write-EventLogMessage {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
    
        [string]$LogName = "$LoggingDeploymentName",
        [string]$EventSource,
    
        [int]$EventID = 1000  # Default event ID
    )
    
    $ErrorActionPreference = 'SilentlyContinue'
    $hadError = $false
    
    try {
        if (-not $EventSource) {
            throw "EventSource is required."
        }
    
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            # PowerShell version is less than 6, use Write-EventLog
            Write-EventLog -LogName $logName -Source $EventSource -EntryType Information -EventId $EventID -Message $Message
        }
        else {
            # PowerShell version is 6 or greater, use System.Diagnostics.EventLog
            $eventLog = New-Object System.Diagnostics.EventLog($logName)
            $eventLog.Source = $EventSource
            $eventLog.WriteEntry($Message, [System.Diagnostics.EventLogEntryType]::Information, $EventID)
        }
    
        # Write-host "Event log entry created: $Message" 
    }
    catch {
        Write-host "Error creating event log entry: $_" 
        $hadError = $true
    }
    
    if (-not $hadError) {
        # Write-host "Event log message writing completed successfully."
    }
}
    
    
    
    
function Write-EnhancedLog {
    param (
        [string]$Message,
        [string]$Level = 'INFO',
        [ConsoleColor]$ForegroundColor = [ConsoleColor]::White,
        [string]$CSVFilePath = "$scriptPath\exports\CSV\$(Get-Date -Format 'yyyy-MM-dd')-Log.csv",
        [string]$CentralCSVFilePath = "$scriptPath\exports\CSV\$Filename.csv",
        [switch]$UseModule = $false,
        [string]$Caller = (Get-PSCallStack)[0].Command
    )
    
    # Add timestamp, computer name, and log level to the message
    $formattedMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $($env:COMPUTERNAME): [$Level] [$Caller] $Message"
    
    # Set foreground color based on log level
    switch ($Level) {
        'INFO' { $ForegroundColor = [ConsoleColor]::Green }
        'WARNING' { $ForegroundColor = [ConsoleColor]::Yellow }
        'ERROR' { $ForegroundColor = [ConsoleColor]::Red }
    }
    
    # Write the message with the specified colors
    $currentForegroundColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $ForegroundColor
    # Write-output $formattedMessage
    Write-host $formattedMessage
    $Host.UI.RawUI.ForegroundColor = $currentForegroundColor
    
    # Append to CSV file
    AppendCSVLog -Message $formattedMessage -CSVFilePath $CSVFilePath
    AppendCSVLog -Message $formattedMessage -CSVFilePath $CentralCSVFilePath
    
    # Write to event log (optional)
    # Write-CustomEventLog -EventMessage $formattedMessage -Level $Level

    
    # Adjust this line in your script where you call the function
    # Write-EventLogMessage -LogName $LogName -EventSource $EventSource -Message $formattedMessage -EventID 1001
    
}
    
function Export-EventLog {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LogName,
        [Parameter(Mandatory = $true)]
        [string]$ExportPath
    )
    
    try {
        wevtutil epl $LogName $ExportPath
    
        if (Test-Path $ExportPath) {
            Write-EnhancedLog -Message "Event log '$LogName' exported to '$ExportPath'" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
        }
        else {
            Write-EnhancedLog -Message "Event log '$LogName' not exported: File does not exist at '$ExportPath'" -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
        }
    }
    catch {
        Write-EnhancedLog -Message "Error exporting event log '$LogName': $($_.Exception.Message)" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
    }
}
    
# # Example usage
# $LogName = '$LoggingDeploymentNameLog'
# # $ExportPath = 'Path\to\your\exported\eventlog.evtx'
# $ExportPath = "C:\code\$LoggingDeploymentName\exports\Logs\$logname.evtx"
# Export-EventLog -LogName $LogName -ExportPath $ExportPath
    
    
    
    
    
    
#################################################################################################################################
################################################# END LOGGING ###################################################################
#################################################################################################################################
    
    
    
Write-EnhancedLog -Message "Logging works" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
    
    
#################################################################################################################################
################################################# END LOGGING ###################################################################
#################################################################################################################################



#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################



Write-EnhancedLog -Message "calling Test-RunningAsSystem" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)


function Test-RunningAsSystem {
    $systemSid = New-Object System.Security.Principal.SecurityIdentifier "S-1-5-18"
    $currentSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User

    return $currentSid -eq $systemSid
}


function Set-LocalPathBasedOnContext {
    Write-EnhancedLog -Message "Checking running context..." -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Cyan)
    if (Test-RunningAsSystem) {
        Write-EnhancedLog -Message "Running as system, setting path to Program Files" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Yellow)
        return "$ENV:Programfiles\_MEM"
    }
    else {
        Write-EnhancedLog -Message "Running as user, setting path to Local AppData" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Yellow)
        return "$ENV:LOCALAPPDATA\_MEM"
    }
}


$global:Path_local = Set-LocalPathBasedOnContext



Write-EnhancedLog -Message "calling Initialize-ScriptVariables" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)












<#
.SYNOPSIS
Initializes global script variables and defines the path for storing related files.

.DESCRIPTION
This function initializes global script variables such as PackageName, PackageUniqueGUID, Version, and ScriptMode. Additionally, it constructs the path where related files will be stored based on the provided parameters.

.PARAMETER PackageName
The name of the package being processed.

.PARAMETER PackageUniqueGUID
The unique identifier for the package being processed.

.PARAMETER Version
The version of the package being processed.

.PARAMETER ScriptMode
The mode in which the script is being executed (e.g., "Remediation", "PackageName").

.EXAMPLE
Initialize-ScriptVariables -PackageName "MyPackage" -PackageUniqueGUID "1234-5678" -Version 1 -ScriptMode "Remediation"

This example initializes the script variables with the specified values.

#>
function Initialize-ScriptVariables {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [Parameter(Mandatory = $true)]
        [string]$PackageUniqueGUID,

        [Parameter(Mandatory = $true)]
        [int]$Version,

        [Parameter(Mandatory = $true)]
        [string]$ScriptMode
    )

    # Assuming Set-LocalPathBasedOnContext and Test-RunningAsSystem are defined elsewhere
    # $global:Path_local = Set-LocalPathBasedOnContext

    # Default logic for $Path_local if not set by Set-LocalPathBasedOnContext
    if (-not $Path_local) {
        if (Test-RunningAsSystem) {
            $Path_local = "$ENV:ProgramFiles\_MEM"
        }
        else {
            $Path_local = "$ENV:LOCALAPPDATA\_MEM"
        }
    }

    $Path_PR = "$Path_local\Data\$PackageName-$PackageUniqueGUID"
    $schtaskName = "$PackageName - $PackageUniqueGUID"
    $schtaskDescription = "Version $Version"

    try {
        # Assuming Write-EnhancedLog is defined elsewhere
        Write-EnhancedLog -Message "Initializing script variables..." -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Green)

        # Returning a hashtable of all the important variables
        return @{
            PackageName        = $PackageName
            PackageUniqueGUID  = $PackageUniqueGUID
            Version            = $Version
            ScriptMode         = $ScriptMode
            Path_local         = $Path_local
            Path_PR            = $Path_PR
            schtaskName        = $schtaskName
            schtaskDescription = $schtaskDescription
        }
    }
    catch {
        Write-Error "An error occurred while initializing script variables: $_"
    }
}

# Invocation of the function and storing returned hashtable in a variable
# $initializationInfo = Initialize-ScriptVariables -PackageName "YourPackageName" -PackageUniqueGUID "YourGUID" -Version 1 -ScriptMode "YourMode"

# Call Initialize-ScriptVariables with splatting
$InitializeScriptVariablesParams = @{
    PackageName       = $PackageName
    PackageUniqueGUID = $PackageUniqueGUID
    Version           = $Version
    ScriptMode        = $ScriptMode
}

$initializationInfo = Initialize-ScriptVariables @InitializeScriptVariablesParams

$initializationInfo

$global:PackageName = $initializationInfo['PackageName']
$global:PackageUniqueGUID = $initializationInfo['PackageUniqueGUID']
$global:Version = $initializationInfo['Version']
$global:ScriptMode = $initializationInfo['ScriptMode']
$global:Path_local = $initializationInfo['Path_local']
$global:Path_PR = $initializationInfo['Path_PR']
$global:schtaskName = $initializationInfo['schtaskName']
$global:schtaskDescription = $initializationInfo['schtaskDescription']














<#
.SYNOPSIS
Ensures that all necessary script paths exist, creating them if they do not.

.DESCRIPTION
This function checks for the existence of essential script paths and creates them if they are not found. It is designed to be called after initializing script variables to ensure the environment is correctly prepared for the script's operations.

.PARAMETER Path_local
The local path where the script's data will be stored. This path varies based on the execution context (system vs. user).

.PARAMETER Path_PR
The specific path for storing package-related files, constructed based on the package name and unique GUID.

.EXAMPLE
Ensure-ScriptPathsExist -Path_local $global:Path_local -Path_PR $global:Path_PR

This example ensures that the paths stored in the global variables $Path_local and $Path_PR exist, creating them if necessary.
#>
function Ensure-ScriptPathsExist {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path_local,

        [Parameter(Mandatory = $true)]
        [string]$Path_PR
    )

    try {
        # Ensure Path_local exists
        if (-not (Test-Path -Path $Path_local)) {
            New-Item -Path $Path_local -ItemType Directory -Force | Out-Null
            Write-EnhancedLog -Message "Created directory: $Path_local" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Green)
        }

        # Ensure Path_PR exists
        if (-not (Test-Path -Path $Path_PR)) {
            New-Item -Path $Path_PR -ItemType Directory -Force | Out-Null
            Write-EnhancedLog -Message "Created directory: $Path_PR" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Green)
        }
    }
    catch {
        Write-EnhancedLog -Message "An error occurred while ensuring script paths exist: $_" -Level "ERROR" -ForegroundColor ([System.ConsoleColor]::Red)
    }
}



# Assuming $global:Path_local and $global:Path_PR are set from previous initialization
Ensure-ScriptPathsExist -Path_local $global:Path_local -Path_PR $global:Path_PR

if (-not (Test-Path -Path $global:Path_PR -PathType Container)) {
    Write-EnhancedLog -Message "Failed to create $global:Path_PR. Please check permissions and path validity." -Level "ERROR" -ForegroundColor ([System.ConsoleColor]::Red)
}
else {
    Write-EnhancedLog -Message "$global:Path_PR exists." -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Green)
}




<#
.SYNOPSIS
Copies all files in the same directory as the script to the specified destination path.

.DESCRIPTION
This function copies all files located in the same directory as the script to the specified destination path. It can be used to bundle necessary files with the script for distribution or deployment.

.PARAMETER DestinationPath
The destination path where the files will be copied.

.EXAMPLE
Copy-FilesToPath -DestinationPath "C:\Temp"

This example copies all files in the same directory as the script to the "C:\Temp" directory.

#>
function Copy-FilesToPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    try {
        Write-EnhancedLog -Message "Copying files to destination path: $DestinationPath" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Cyan)
        
        # Get all files in the script directory
        $Files = Get-ChildItem -Path $PSScriptRoot -File

        # Copy each file to the destination path
        foreach ($File in $Files) {
            Copy-Item -Path $File.FullName -Destination $DestinationPath -Force
        }

        Write-EnhancedLog -Message "Files copied successfully." -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Green)
    }
    catch {
        Write-EnhancedLog -Message "Error occurred while copying files: $_" -Level "ERROR" -ForegroundColor ([System.ConsoleColor]::Red)
        throw $_
    }
}
Copy-FilesToPath -DestinationPath $global:Path_PR












<#
.SYNOPSIS
Creates a VBScript file to run a PowerShell script hidden from the user interface.

.DESCRIPTION
This function generates a VBScript (.vbs) file designed to execute a PowerShell script without displaying the PowerShell window. It's particularly useful for running background tasks or scripts that do not require user interaction. The path to the PowerShell script is taken as an argument, and the VBScript is created in a specified directory within the global path variable.

.EXAMPLE
$Path_VBShiddenPS = Create-VBShiddenPS

This example creates the VBScript file and returns its path.
#>


function Create-VBShiddenPS {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path_local,

        [string]$DataFolder = "Data",

        [string]$FileName = "run-ps-hidden.vbs"
    )

    try {
        # Construct the full path for DataFolder and validate it manually
        $fullDataFolderPath = Join-Path -Path $Path_local -ChildPath $DataFolder
        if (-not (Test-Path -Path $fullDataFolderPath -PathType Container)) {
            throw "DataFolder does not exist or is not a directory: $fullDataFolderPath"
        }

        # Log message about creating VBScript
        Write-EnhancedLog -Message "Creating VBScript to hide PowerShell window..." -Level "INFO" -ForegroundColor Magenta

        $scriptBlock = @"
Dim shell,fso,file

Set shell=CreateObject("WScript.Shell")
Set fso=CreateObject("Scripting.FileSystemObject")

strPath=WScript.Arguments.Item(0)

If fso.FileExists(strPath) Then
    set file=fso.GetFile(strPath)
    strCMD="powershell -nologo -executionpolicy ByPass -command " & Chr(34) & "&{" & file.ShortPath & "}" & Chr(34)
    shell.Run strCMD,0
End If
"@

        # Combine paths to construct the full path for the VBScript
        $folderPath = $fullDataFolderPath
        $Path_VBShiddenPS = Join-Path -Path $folderPath -ChildPath $FileName

        # Write the script block to the VBScript file
        $scriptBlock | Out-File -FilePath (New-Item -Path $Path_VBShiddenPS -Force) -Force

        # Validate the VBScript file creation
        if (Test-Path -Path $Path_VBShiddenPS) {
            Write-EnhancedLog -Message "VBScript created successfully at $Path_VBShiddenPS" -Level "INFO" -ForegroundColor Green
        }
        else {
            throw "Failed to create VBScript at $Path_VBShiddenPS"
        }

        return $Path_VBShiddenPS
    }
    catch {
        Write-EnhancedLog -Message "An error occurred while creating VBScript: $_" -Level "ERROR" -ForegroundColor Red
        throw $_
    }
}

# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-EnhancedLog -Message "Script requires administrative privileges to write to $Path_local." -Level "ERROR" -ForegroundColor ([System.ConsoleColor]::Red)
    exit
}

# Pre-defined paths
$Path_local = "C:\Program Files\_MEM"
$DataFolder = "Data"
$DataFolderPath = Join-Path -Path $Path_local -ChildPath $DataFolder

# Ensure the Data folder exists
if (-not (Test-Path -Path $DataFolderPath -PathType Container)) {
    New-Item -ItemType Directory -Path $DataFolderPath -Force | Out-Null
    Write-EnhancedLog -Message "Data folder created at $DataFolderPath" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Green)
}
else {
    Write-EnhancedLog -Message "Data folder already exists at $DataFolderPath" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Yellow)
}

# Then call Create-VBShiddenPS
$FileName = "run-ps-hidden.vbs"
try {
    $global:Path_VBShiddenPS = Create-VBShiddenPS -Path_local $Path_local -DataFolder $DataFolder -FileName $FileName
    # Validation of the VBScript file creation
    if (Test-Path -Path $global:Path_VBShiddenPS) {
        Write-EnhancedLog -Message "Validation successful: VBScript file exists at $global:Path_VBShiddenPS" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Green)
    }
    else {
        Write-EnhancedLog -Message "Validation failed: VBScript file does not exist at $global:Path_VBShiddenPS. Check script execution and permissions." -Level "WARNING" -ForegroundColor ([System.ConsoleColor]::Red)
    }
}
catch {
    Write-EnhancedLog -Message "An error occurred: $_" -Level "ERROR" -ForegroundColor ([System.ConsoleColor]::Red)
}





<#
.SYNOPSIS
Checks for the existence of a specified scheduled task.

.DESCRIPTION
This function searches for a scheduled task by name and optionally filters it by version. It returns $true if a task matching the specified criteria exists, otherwise $false.

.PARAMETER taskName
The name of the scheduled task to search for.

.PARAMETER version
The version of the scheduled task to match. The task's description must start with "Version" followed by this parameter value.

.EXAMPLE
$exists = Check-ExistingTask -taskName "MyTask" -version "1"
This example checks if a scheduled task named "MyTask" with a description starting with "Version 1" exists.

#>
function Check-ExistingTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$taskName,

        [string]$version
    )

    try {
        Write-EnhancedLog -Message "Checking for existing scheduled task: $taskName" -Level "INFO" -ForegroundColor Magenta
        $task_existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($null -eq $task_existing) {
            Write-EnhancedLog -Message "No existing task named $taskName found." -Level "INFO" -ForegroundColor Yellow
            return $false
        }

        if ($null -ne $version) {
            $versionMatch = $task_existing.Description -like "Version $version*"
            if ($versionMatch) {
                Write-EnhancedLog -Message "Found matching task with version: $version" -Level "INFO" -ForegroundColor Green
            }
            else {
                Write-EnhancedLog -Message "No matching version found for task: $taskName" -Level "INFO" -ForegroundColor Yellow
            }
            return $versionMatch
        }

        return $true
    }
    catch {
        Write-EnhancedLog -Message "An error occurred while checking for the scheduled task: $_" -Level "ERROR" -ForegroundColor Red
        throw $_
    }
}







<#
.SYNOPSIS
Executes detection and remediation scripts located in a specified directory.

.DESCRIPTION
This function navigates to the specified directory and executes the detection script. If the detection script exits with a non-zero exit code, indicating a positive detection, the remediation script is then executed. The function uses enhanced logging for status messages and error handling to manage any issues that arise during execution.

.PARAMETER Path_PR
The path to the directory containing the detection and remediation scripts.

.EXAMPLE
Execute-DetectionAndRemediation -Path_PR "C:\Scripts\MyTask"
This example executes the detection and remediation scripts located in "C:\Scripts\MyTask".
#>
function Execute-DetectionAndRemediation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        # [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]$Path_PR
    )

    try {
        Write-EnhancedLog -Message "Executing detection and remediation scripts in $Path_PR..." -Level "INFO" -ForegroundColor Magenta
        Set-Location -Path $Path_PR

        # Execution of the detection script
        & .\detection.ps1
        if ($LASTEXITCODE -ne 0) {
            Write-EnhancedLog -Message "Detection positive, remediation starts now." -Level "INFO" -ForegroundColor Green
            & .\remediation.ps1
        }
        else {
            Write-EnhancedLog -Message "Detection negative, no further action needed." -Level "INFO" -ForegroundColor Yellow
        }
    }
    catch {
        Write-EnhancedLog -Message "An error occurred during detection and remediation execution: $_" -Level "ERROR" -ForegroundColor Red
        throw $_
    }
}







<#
.SYNOPSIS
Registers a scheduled task with the system.

.DESCRIPTION
This function creates a new scheduled task with the specified parameters, including the name, description, VBScript path, and PowerShell script path. It sets up a basic daily trigger and runs the task as the SYSTEM account with the highest privileges. Enhanced logging is used for status messages and error handling to manage potential issues.

.PARAMETER schtaskName
The name of the scheduled task to register.

.PARAMETER schtaskDescription
A description for the scheduled task.

.PARAMETER Path_vbs
The path to the VBScript file used to run the PowerShell script.

.PARAMETER Path_PSscript
The path to the PowerShell script to execute.

.EXAMPLE
MyRegisterScheduledTask -schtaskName "MyTask" -schtaskDescription "Performs automated checks" -Path_vbs "C:\Scripts\run-hidden.vbs" -Path_PSscript "C:\Scripts\myScript.ps1"

This example registers a new scheduled task named "MyTask" that executes "myScript.ps1" using "run-hidden.vbs".
#>
function MyRegisterScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$schtaskName,

        [Parameter(Mandatory = $true)]
        [string]$schtaskDescription,

        [Parameter(Mandatory = $true)]
        # [ValidateScript({Test-Path $_ -File})]
        [string]$Path_vbs,

        [Parameter(Mandatory = $true)]
        # [ValidateScript({Test-Path $_ -File})]
        [string]$Path_PSscript
    )

    try {
        Write-EnhancedLog -Message "Registering scheduled task: $schtaskName" -Level "INFO" -ForegroundColor Magenta

        $startTime = (Get-Date).AddMinutes(1).ToString("HH:mm")

        $action = New-ScheduledTaskAction -Execute "C:\Windows\System32\wscript.exe" -Argument "`"$Path_vbs`" `"$Path_PSscript`""
        $trigger = New-ScheduledTaskTrigger -Daily -At $startTime

        $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

        $task = Register-ScheduledTask -TaskName $schtaskName -Action $action -Trigger $trigger -Principal $principal -Description $schtaskDescription -Force


        # Updating the task to include repetition with a 5-minute interval
        $task = Get-ScheduledTask -TaskName $schtaskName
        $task.Triggers[0].Repetition.Interval = $RepetitionInterval
        $task | Set-ScheduledTask

        # Check the execution context specified in the config
        if ($PackageExecutionContext -eq "User") {
            # This code block will only execute if ExecutionContext is set to "User"

            # Connect to the Task Scheduler service
            $ShedService = New-Object -comobject 'Schedule.Service'
            $ShedService.Connect()

            # Get the folder where the task is stored (root folder in this case)
            $taskFolder = $ShedService.GetFolder("\")
    
            # Get the existing task by name
            $Task = $taskFolder.GetTask("$schtaskName")

            # Update the task with a new definition
            $taskFolder.RegisterTaskDefinition("$schtaskName", $Task.Definition, 6, 'Users', $null, 4)  # 6 is TASK_CREATE_OR_UPDATE
        }
        else {
            Write-Host "Execution context is not set to 'User', skipping this block."
        }



        Write-EnhancedLog -Message "Scheduled task $schtaskName registered successfully." -Level "INFO" -ForegroundColor Green
    }
    catch {
        Write-EnhancedLog -Message "An error occurred while registering the scheduled task: $_" -Level "ERROR" -ForegroundColor Red
        throw $_
    }
}







<#
.SYNOPSIS
Sets up a new task environment for scheduled task execution.

.DESCRIPTION
This function prepares the environment for a new scheduled task. It creates a specified directory, determines the PowerShell script path based on the script mode, generates a VBScript to run the PowerShell script hidden, and finally registers the scheduled task with the provided parameters. It utilizes enhanced logging for feedback and error handling to manage potential issues.

.PARAMETER Path_PR
The path where the task's scripts and support files will be stored.

.PARAMETER schtaskName
The name of the scheduled task to be created.

.PARAMETER schtaskDescription
A description for the scheduled task.

.PARAMETER ScriptMode
Determines the script type to be executed ("Remediation" or "PackageName").

.EXAMPLE
SetupNewTaskEnvironment -Path_PR "C:\Tasks\MyTask" -schtaskName "MyScheduledTask" -schtaskDescription "This task does something important" -ScriptMode "Remediation"

This example sets up the environment for a scheduled task named "MyScheduledTask" with a specific description, intended for remediation purposes.
#>
function SetupNewTaskEnvironment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        # [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]$Path_PR,

        [Parameter(Mandatory = $true)]
        [string]$schtaskName,

        [Parameter(Mandatory = $true)]
        [string]$schtaskDescription,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Remediation", "PackageName")]
        [string]$ScriptMode
    )

    try {
        Write-EnhancedLog -Message "Setting up new task environment at $Path_PR." -Level "INFO" -ForegroundColor Cyan

        # New-Item -Path $Path_PR -ItemType Directory -Force | Out-Null
        # Write-EnhancedLog -Message "Created new directory at $Path_PR" -Level "INFO" -ForegroundColor Green

        $Path_PSscript = switch ($ScriptMode) {
            "Remediation" { Join-Path $Path_PR "remediation.ps1" }
            "PackageName" { Join-Path $Path_PR "$PackageName.ps1" }
            Default { throw "Invalid ScriptMode: $ScriptMode. Expected 'Remediation' or 'PackageName'." }
        }

        # $Path_vbs = Create-VBShiddenPS -Path_local $Path_PR
        $Path_vbs = $global:Path_VBShiddenPS

        $scheduledTaskParams = @{
            schtaskName        = $schtaskName
            schtaskDescription = $schtaskDescription
            Path_vbs           = $Path_vbs
            Path_PSscript      = $Path_PSscript
        }

        MyRegisterScheduledTask @scheduledTaskParams

        Write-EnhancedLog -Message "Scheduled task $schtaskName with description '$schtaskDescription' registered successfully." -Level "INFO" -ForegroundColor Green
    }
    catch {
        Write-EnhancedLog -Message "An error occurred during setup of new task environment: $_" -Level "ERROR" -ForegroundColor Red
        throw $_
    }
}



<#
.SYNOPSIS
Checks for an existing scheduled task and executes tasks based on conditions.

.DESCRIPTION
This function checks if a scheduled task with the specified name and version exists. If it does, it proceeds to execute detection and remediation scripts. If not, it sets up a new task environment and registers the task. It uses enhanced logging for status messages and error handling to manage potential issues.

.PARAMETER schtaskName
The name of the scheduled task to check and potentially execute.

.PARAMETER Version
The version of the task to check for. This is used to verify if the correct task version is already scheduled.

.PARAMETER Path_PR
The path to the directory containing the detection and remediation scripts, used if the task needs to be executed.

.EXAMPLE
CheckAndExecuteTask -schtaskName "MyScheduledTask" -Version 1 -Path_PR "C:\Tasks\MyTask"

This example checks for an existing scheduled task named "MyScheduledTask" of version 1. If it exists, it executes the associated tasks; otherwise, it sets up a new environment and registers the task.
#>
function CheckAndExecuteTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$schtaskName,

        [Parameter(Mandatory = $true)]
        [int]$Version,

        [Parameter(Mandatory = $true)]
        [string]$Path_PR,

        [Parameter(Mandatory = $true)]
        [string]$ScriptMode # Adding ScriptMode as a parameter
    )

    try {
        Write-EnhancedLog -Message "Checking for existing task: $schtaskName" -Level "INFO" -ForegroundColor Cyan

        $taskExists = Check-ExistingTask -taskName $schtaskName -version $Version
        if ($taskExists) {
            Write-EnhancedLog -Message "Existing task found. Executing detection and remediation scripts." -Level "INFO" -ForegroundColor Green
            Execute-DetectionAndRemediation -Path_PR $Path_PR
        }
        else {
            Write-EnhancedLog -Message "No existing task found. Setting up new task environment." -Level "INFO" -ForegroundColor Yellow
            SetupNewTaskEnvironment -Path_PR $Path_PR -schtaskName $schtaskName -schtaskDescription $schtaskDescription -ScriptMode $ScriptMode
        }
    }
    catch {
        Write-EnhancedLog -Message "An error occurred while checking and executing the task: $_" -Level "ERROR" -ForegroundColor Red
        throw $_
    }
}

# Ensure global variables are initialized correctly beforehand

# Define the parameters in a hashtable using global variables, including ScriptMode
$params = @{
    schtaskName = $global:schtaskName
    Version     = $global:Version
    Path_PR     = $global:Path_PR
    ScriptMode  = $global:ScriptMode # Assuming you have this variable defined globally
}

# Call the function using splatting with dynamically set global variables
CheckAndExecuteTask @params
