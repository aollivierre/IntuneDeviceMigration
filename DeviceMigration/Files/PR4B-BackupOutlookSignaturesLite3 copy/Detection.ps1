#Unique Tracking ID: e2ff1880-638d-4e28-a197-cca64a109f7a, Timestamp: 2024-03-07 15:36:15
# Attempt to find the OneDrive directory
$oneDriveDirectory = (Get-ChildItem "$env:USERPROFILE" -Filter "OneDrive - *" -Directory).FullName

# Check if the OneDrive directory exists
if (-not $oneDriveDirectory) {
    Write-Host "OneDrive directory does not exist. Remediation is not possible for now."
    exit 0
}

# Define the backup path within the OneDrive directory
$backupPath = Join-Path $oneDriveDirectory "OutlookSignatures"

# Check if the OutlookSignatures folder exists and contains files
if (Test-Path $backupPath) {
    $fileCount = (Get-ChildItem -Path $backupPath -Recurse -File).Count
    if ($fileCount -gt 0) {
        Write-Host "OutlookSignatures folder detected with files at $backupPath. Remediation needed."
        exit 1
    }
    else {
        Write-Host "OutlookSignatures folder exists at $backupPath but is empty. Remediation needed."
        exit 1
    }
}
else {
    Write-Host "OutlookSignatures folder does not exist at $backupPath. Remediation needed."
    exit 1
}
