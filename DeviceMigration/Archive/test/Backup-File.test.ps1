# Fetch the script content
$scriptContent = Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1"

# Define replacements in a hashtable
$replacements = @{
    '\$Mode = "dev"'                     = '$Mode = "dev"'
    '\$SkipPSGalleryModules = \$false'   = '$SkipPSGalleryModules = $true'
    '\$SkipCheckandElevate = \$false'    = '$SkipCheckandElevate = $true'
    '\$SkipAdminCheck = \$false'         = '$SkipAdminCheck = $true'
    '\$SkipPowerShell7Install = \$false' = '$SkipPowerShell7Install = $true'
    '\$SkipModuleDownload = \$false'     = '$SkipModuleDownload = $true'
    '\$SkipGitrepos = \$false'           = '$SkipGitrepos = $true'
}

# Apply the replacements
foreach ($pattern in $replacements.Keys) {
    $scriptContent = $scriptContent -replace $pattern, $replacements[$pattern]
}

# Execute the script
Invoke-Expression $scriptContent



# Example usage of the Backup-File function in a script

# Define the path to the source file you want to back up
$sourceFilePath = "C:\Temp\TestFile.txt"

# Define the directory where the backup will be stored
$backupDirectory = "C:\Temp\Backups"

# Call the Backup-File function
try {
    Write-Host "Starting backup process for $sourceFilePath" -ForegroundColor Cyan

    # Invoke the Backup-File function and capture the result
    $backupFilePath = Backup-File -SourceFilePath $sourceFilePath -BackupDirectory $backupDirectory

    Write-Host "Backup completed successfully. Backup file created at: $backupFilePath" -ForegroundColor Green

} catch {
    Write-Host "An error occurred during the backup process: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Backup process finished." -ForegroundColor Cyan
