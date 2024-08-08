#Unique Tracking ID: 72e3a524-64f7-4f94-9af1-b1e40efa7e11, Timestamp: 2024-03-07 15:34:48
# Attempt to find the OneDrive directory
$oneDriveDirectory = (Get-ChildItem "$env:USERPROFILE" -Filter "OneDrive - *" -Directory).FullName

# Check if the OneDrive directory exists
if (-not $oneDriveDirectory) {
    Write-Host "OneDrive directory does not exist. Remediation is not possible for now."
    exit 0
}

# Define the backup path within the OneDrive directory
$backupPath = Join-Path $oneDriveDirectory "ChromeBackup"

# Check if the ChromeBackup folder exists and contains files
if (Test-Path $backupPath) {
    $fileCount = (Get-ChildItem -Path $backupPath -Recurse -File).Count
    if ($fileCount -gt 0) {
        Write-Host "ChromeBackup folder detected with files at $backupPath. Remediation needed."
        exit 1
    } else {
        Write-Host "ChromeBackup folder exists at $backupPath but is empty. Remediation needed."
        exit 1
    }
} else {
    Write-Host "ChromeBackup folder does not exist at $backupPath. Remediation needed."
    exit 1
}
