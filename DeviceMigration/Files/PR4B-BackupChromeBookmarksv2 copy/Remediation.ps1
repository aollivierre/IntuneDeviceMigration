#Unique Tracking ID: 72e3a524-64f7-4f94-9af1-b1e40efa7e11, Timestamp: 2024-03-07 15:34:48
<#
.SYNOPSIS
    Backs up specific Google Chrome data files to a designated backup location within OneDrive using Robocopy.

.DESCRIPTION
    This script backs up specific files ('bookmarks' and 'Login Data') from the Google Chrome Default user profile to a specified backup directory in OneDrive. It uses Robocopy for the copying operation, which is ideal for handling large files and ensuring data integrity.

.EXAMPLE
    .\Backup-ChromeSpecificFilesWithRobocopy.ps1
    Executes the backup operation, copying the specified Chrome data files to the backup location in OneDrive.

.NOTES
    Version: 1.0
    Author: Your Name
    Requires: PowerShell 5.1 or later
    Unique Tracking ID: 239f65ce-a4fe-4b0d-82ce-8295ad160753
#>

# Files to back up
$filesToBackup = @("bookmarks", "Login Data")

# Source path to Chrome's Default profile
$chromeDefaultProfilePath = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Local\Google\Chrome\User Data\Default"

# Find the OneDrive directory with the specified filter
$oneDriveBackupPath = Get-ChildItem -Path $env:USERPROFILE -Filter "OneDrive - *" -Directory | Select-Object -First 1 -ExpandProperty FullName

# Destination path for the backup inside OneDrive
$backupDestinationPath = Join-Path -Path $oneDriveBackupPath -ChildPath "ChromeBackup"

# Check and create backup directory if it doesn't exist
if (-not (Test-Path -Path $backupDestinationPath)) {
    New-Item -ItemType Directory -Path $backupDestinationPath | Out-Null
}

foreach ($file in $filesToBackup) {
    $sourceFilePath = $chromeDefaultProfilePath # Robocopy uses directory paths
    $destinationFilePath = $backupDestinationPath # Robocopy destination directory

    # Check if the source file exists before attempting to copy
    if (Test-Path -Path (Join-Path -Path $sourceFilePath -ChildPath $file)) {
        try {
            # Robocopy parameters to copy specific files, retry options, and log details
            # $robocopyParams = @($sourceFilePath, $destinationFilePath, $file, "/COPY:DAT", "/R:0", "/W:0", "/NP", "/LOG+:robocopy.log", "/TEE")
            $robocopyParams = @($sourceFilePath, $destinationFilePath, $file, "/COPY:DAT", "/R:0", "/W:0", "/NP")
            robocopy @robocopyParams > $null
            
            # Check the exit code ($LASTEXITCODE) for success (0, 1) and specific file copied (1)
            if ($LASTEXITCODE -le 1) {
                # Write-Host "Successfully backed up '$file' to '$destinationFilePath'."
            }
            else {
                # Write-Warning "Robocopy completed with exit code $LASTEXITCODE. Some files may not have been copied."
            }
        }
        catch {
            # Write-Error "An error occurred while backing up '$file': $_"
        }
    }
    else {
        # Write-Warning "'$file' does not exist in the source directory and will not be backed up."
    }
}
