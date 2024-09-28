param (
    [Switch]$SimulatingIntune = $false
)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Elevate to administrator if not already
if (-not (Test-Admin)) {
    Write-Host "Restarting script with elevated permissions..."
    $startProcessParams = @{
        FilePath     = "powershell.exe"
        ArgumentList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $PSCommandPath)
        Verb         = "RunAs"
    }
    Start-Process @startProcessParams
    exit
}

# Set Execution Policy to Bypass if not already set
$currentExecutionPolicy = Get-ExecutionPolicy
if ($currentExecutionPolicy -ne 'Bypass') {
    Write-Host "Setting Execution Policy to Bypass..."
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
} else {
    Write-Host "Execution Policy is already set to Bypass."
}

# Check if running as a web script (no $MyInvocation.MyCommand.Path)
if (-not $MyInvocation.MyCommand.Path) {
    Write-Host "Running as web script, downloading and executing locally..."

    # Ensure TLS 1.2 is used for secure downloads
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Create a time-stamped folder in the temp directory
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $downloadFolder = Join-Path -Path $env:TEMP -ChildPath "IntuneDeviceMigration_$timestamp"
    New-Item -Path $downloadFolder -ItemType Directory | Out-Null

    # Download the script to the time-stamped folder
    $localScriptPath = Join-Path -Path $downloadFolder -ChildPath "setup.ps1"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/aollivierre/IntuneDeviceMigration/main/Setup.ps1" -OutFile $localScriptPath

    Write-Host "Re-running the script locally from: $localScriptPath"
    
    # Re-run the script locally
    & $localScriptPath

    write-host 'Exiting web script'
    Exit # Exit after running the script locally
}
else {
    Write-Host "Running in regular context locally..."
}

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

# Execute the DeviceMigration.ps1 script
$extractedDir = [System.IO.Path]::Combine($tempDir, "IntuneDeviceMigration-main")
$scriptPath = [System.IO.Path]::Combine($extractedDir, "DeviceMigration.ps1")

# Open the destination folder for visual verification
Start-Process "explorer.exe" -ArgumentList $extractedDir

if (Test-Path $scriptPath) {
    & $scriptPath
} else {
    Write-Host "DeviceMigration.ps1 not found!" -ForegroundColor Red
}
