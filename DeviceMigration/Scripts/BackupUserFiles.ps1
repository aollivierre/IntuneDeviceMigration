# iex ((irm "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1") -replace '\$Mode = "dev"', '$Mode = "dev"')

$jobName = "AAD Migration"
# Start the script with error handling
try {
    # Generate the transcript file path
    # $transcriptPath = Get-TranscriptFilePath -Jobname $jobName

    $GetTranscriptFilePathParams = @{
        TranscriptsPath = "C:\Logs\Transcript"
        JobName         = $jobName
    }
    $transcriptPath = Get-TranscriptFilePath @GetTranscriptFilePathParams
    

    # Start the transcript
    Write-Host "Starting transcript at: $transcriptPath" -ForegroundColor Cyan
    Start-Transcript -Path $transcriptPath

    # Example script logic
    Write-Host "This is an example action being logged."

}
catch {
    Write-Host "An error occurred during script execution: $_" -ForegroundColor Red
} 

# Example usage for Chrome bookmarks
$BackupChromeBookmarksToOneDriveParams = @{
    SourcePath         = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default"
    BackupFolderName   = "ChromeBackup"
    Exclude            = ".git"
    RetryCount         = 2
    WaitTime           = 5
    RequiredSpaceGB    = 10
    OneDriveBackupPath = "$env:OneDrive\Backups"
    Scriptbasepath     = "$PSScriptroot"
}
Backup-UserFilesToOneDrive @BackupChromeBookmarksToOneDriveParams

# Example usage for Outlook signatures
$BackupOutlookSignaturesToOneDrive = @{
    SourcePath         = "$env:USERPROFILE\AppData\Roaming\Microsoft\Signatures"
    BackupFolderName   = "OutlookSignatures"
    Exclude            = ".git"
    RetryCount         = 2
    WaitTime           = 5
    RequiredSpaceGB    = 10
    OneDriveBackupPath = "$env:OneDrive\Backups"
    Scriptbasepath     = "$PSScriptroot"
}
Backup-UserFilesToOneDrive @BackupOutlookSignaturesToOneDrive

# Example usage for Downloads folder
$BackupDownloadsToOneDriveParams = @{
    SourcePath         = "$env:USERPROFILE\Downloads"
    BackupFolderName   = "DownloadsBackup"
    Exclude            = ".git"
    RetryCount         = 2
    WaitTime           = 5
    RequiredSpaceGB    = 10
    OneDriveBackupPath = "$env:OneDrive\Backups"
    Scriptbasepath     = "$PSScriptroot"
}
Backup-UserFilesToOneDrive @BackupDownloadsToOneDriveParams

Stop-Transcript