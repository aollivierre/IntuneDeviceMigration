param (
    [Switch]$SimulatingIntune = $false
)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-AADMigrationLog {
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
    $logFilePath = [System.IO.Path]::Combine($env:TEMP, 'setupAADMigration.log')
    $formattedMessage | Out-File -FilePath $logFilePath -Append -Encoding utf8
}



#region CHECKING IF RUNNING AS WEB SCRIPT
#################################################################################################
#                                                                                               #
#                                 CHECKING IF RUNNING AS WEB SCRIPT                             #
#                                                                                               #
#################################################################################################

# Check if running as a web script (no $MyInvocation.MyCommand.Path)
if (-not $MyInvocation.MyCommand.Path) {
    Write-AADMigrationLog -Message "Running as web script, downloading and executing locally..." -Level "NOTICE"

    # Ensure TLS 1.2 is used for secure downloads
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Create a time-stamped folder in the temp directory
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $downloadFolder = Join-Path -Path $env:TEMP -ChildPath "IntuneDeviceMigration_$timestamp"
    New-Item -Path $downloadFolder -ItemType Directory | Out-Null

    # Download the script to the time-stamped folder
    $localScriptPath = Join-Path -Path $downloadFolder -ChildPath "setup.ps1"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/aollivierre/IntuneDeviceMigration/main/Setup.ps1" -OutFile $localScriptPath

    Write-AADMigrationLog -Message "Re-running the script locally from: $localScriptPath" -Level "NOTICE"
    
    # Re-run the script locally with elevation if needed
    if (-not (Test-Admin)) {
        Write-AADMigrationLog -Message "Relaunching downloaded script with elevated permissions..." -Level "NOTICE"
        $startProcessParams = @{
            FilePath     = "powershell.exe"
            ArgumentList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $localScriptPath)
            Verb         = "RunAs"
        }
        Start-Process @startProcessParams
        exit
    }
    else {
        & $localScriptPath
    }

    Exit # Exit after running the script locally
}
else {
    Write-AADMigrationLog -Message "Running in regular context locally..." -Level "INFO"



    # # Elevate to administrator if not already
    if (-not (Test-Admin)) {
        Write-AADMigrationLog -Message "Restarting script with elevated permissions..." -Level "NOTICE"
        $startProcessParams = @{
            FilePath     = "powershell.exe"
            ArgumentList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $PSCommandPath)
            Verb         = "RunAs"
        }
        Start-Process @startProcessParams
        exit
    }
}






# Set Execution Policy to Bypass if not already set
$currentExecutionPolicy = Get-ExecutionPolicy
if ($currentExecutionPolicy -ne 'Bypass') {
    Write-AADMigrationLog -Message "Setting Execution Policy to Bypass..." -Level "NOTICE"
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
}
else {
    Write-AADMigrationLog -Message "Execution Policy is already set to Bypass." -Level "INFO"
}


#endregion CHECKING IF RUNNING AS WEB SCRIPT

# Core logic to download the entire repository and execute DeviceMigration.ps1

# Create a time-stamped folder in the temp directory
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "IntuneDeviceMigration_$timestamp")
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Download the ZIP file from GitHub
$repoUrl = "https://github.com/aollivierre/IntuneDeviceMigration/archive/refs/heads/main.zip"
$zipFile = [System.IO.Path]::Combine($tempDir, "IntuneDeviceMigration.zip")
Invoke-WebRequest -Uri $repoUrl -OutFile $zipFile

# Extract the ZIP file
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $tempDir)

# Update the script path to include the correct subfolder
$extractedDir = [System.IO.Path]::Combine($tempDir, "IntuneDeviceMigration-main", "DeviceMigration")
$scriptPath = [System.IO.Path]::Combine($extractedDir, "DeviceMigration.ps1")

# Open the destination folder for visual verification
Start-Process "explorer.exe" -ArgumentList $extractedDir

if (Test-Path $scriptPath) {
    Write-AADMigrationLog -Message "Executing DeviceMigration.ps1 script..." -Level "NOTICE"
    & $scriptPath
}
else {
    Write-AADMigrationLog -Message "DeviceMigration.ps1 not found!" -Level "ERROR"
}
