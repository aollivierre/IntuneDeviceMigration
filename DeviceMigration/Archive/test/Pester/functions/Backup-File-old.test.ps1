function Backup-File {
    param (
        [string]$SourceFilePath,
        [string]$BackupDirectory
    )

    # Check if the source file exists
    if (-Not (Test-Path -Path $SourceFilePath)) {
        throw "Source file does not exist."
    }

    # Ensure the backup directory exists
    if (-Not (Test-Path -Path $BackupDirectory)) {
        New-Item -Path $BackupDirectory -ItemType Directory | Out-Null
    }

    # Create a timestamped backup filename
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $backupFileName = "$($timestamp)_$(Split-Path -Leaf $SourceFilePath)"
    $backupFilePath = Join-Path -Path $BackupDirectory -ChildPath $backupFileName

    # Copy the file to the backup directory
    Copy-Item -Path $SourceFilePath -Destination $backupFilePath

    return $backupFilePath
}
