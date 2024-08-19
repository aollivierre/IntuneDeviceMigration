# iex ((irm "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1") -replace '\$Mode = "dev"', '$Mode = "dev"')

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