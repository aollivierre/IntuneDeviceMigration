param (
    [Switch]$SimulatingIntune = $false
)

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
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/aollivierre/IntuneDeviceMigration/main/setup.ps1" -OutFile $localScriptPath

    Write-Host "Downloading the entire repository as a ZIP file..."

    # Download the ZIP file from GitHub
    $zipUrl = "https://github.com/aollivierre/IntuneDeviceMigration/archive/refs/heads/main.zip"
    $zipFile = Join-Path -Path $downloadFolder -ChildPath "IntuneDeviceMigration.zip"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

    Write-Host "Extracting the ZIP file..."

    # Extract the ZIP file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $downloadFolder)

    # Execute the DeviceMigration.ps1 script
    $extractedDir = Join-Path -Path $downloadFolder -ChildPath "IntuneDeviceMigration-main"
    $migrationScriptPath = Join-Path -Path $extractedDir -ChildPath "DeviceMigration.ps1"

    if (Test-Path $migrationScriptPath) {
        & $migrationScriptPath
    } else {
        Write-Host "DeviceMigration.ps1 not found!" -ForegroundColor Red
    }

    # Open the destination folder for visual verification
    Start-Process "explorer.exe" -ArgumentList $extractedDir

    Exit # Exit after running the script locally
} else {
    Write-Host "Running in a regular context..."
    # Here you can place the logic that should execute when the script is not running as a web script
}
