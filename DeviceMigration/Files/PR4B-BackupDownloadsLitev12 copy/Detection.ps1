#Unique Tracking ID: a810e60d-3f98-49c6-a4c1-57d10316302f, Timestamp: 2024-03-07 15:35:33
# Attempt to find the OneDrive directory
$oneDriveDirectory = (Get-ChildItem "$env:USERPROFILE" -Filter "OneDrive - *" -Directory).FullName

# Check if the OneDrive directory exists
if (-not $oneDriveDirectory) {
    Write-Host "OneDrive directory does not exist. Remediation is not possible for now."
    exit 0
}

# Define the backup path within the OneDrive directory
$backupPath = Join-Path $oneDriveDirectory "DownloadsBackup"

# Check if the DownloadsBackup folder exists and contains files
if (Test-Path $backupPath) {
    $fileCount = (Get-ChildItem -Path $backupPath -Recurse -File).Count
    if ($fileCount -gt 0) {
        Write-Host "DownloadsBackup folder detected with files at $backupPath. Remediation needed."
        exit 1
    } else {
        Write-Host "DownloadsBackup folder exists at $backupPath but is empty. Remediation needed."
        exit 1
    }
} else {
    Write-Host "DownloadsBackup folder does not exist at $backupPath. Remediation needed."
    exit 1
}
