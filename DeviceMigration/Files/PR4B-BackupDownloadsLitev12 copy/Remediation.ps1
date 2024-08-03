#Unique Tracking ID: a810e60d-3f98-49c6-a4c1-57d10316302f, Timestamp: 2024-03-07 15:35:33
function Copy-ItemsWithRobocopy {
    param (
        [string]$SourcePath,
        [string]$DestinationPath
    )

    # Ensure the destination directory 'DownloadsBackup' exists
    $finalDestinationPath = Join-Path -Path $DestinationPath -ChildPath "DownloadsBackup"
    if (-not (Test-Path -Path $finalDestinationPath)) {
        New-Item -ItemType Directory -Force -Path $finalDestinationPath | Out-Null
    }

    # Use Robocopy for copying. /E is for copying subdirectories including empty ones. /R:0 and /W:0 are for no retries and no wait between retries.
    # Ensure to add a trailing backslash to the source path to copy its contents
    $robocopyArgs = @("${SourcePath}\", $finalDestinationPath, "/E", "/R:0", "/W:0")

    try {
        $result = robocopy @robocopyArgs
        switch ($LASTEXITCODE) {
            0 { Write-Host "No files were copied. No files were mismatched. No failures were encountered." }
            1 { Write-Host "All files were copied successfully." }
            2 { Write-Host "There are some additional files in the destination directory that are not present in the source directory. No files were copied." }
            3 { Write-Host "Some files were copied. Additional files were present. No failure was encountered." }
            4 { Write-Host "Some files were mismatched. No files were copied." }
            5 { Write-Host "Some files were copied. Some files were mismatched. No failure was encountered." }
            6 { Write-Host "Additional files and mismatched files exist. No files were copied." }
            7 { Write-Host "Files were copied, a file mismatch was present, and additional files were present." }
            8 { Write-Host "Several files did not copy." }
            default { Write-Error "Robocopy failed with exit code $LASTEXITCODE" }
        }
    } catch {
        Write-Error "An error occurred: $_"
    }
}

# Define full-name variables and check for OneDrive directory existence
$oneDriveDirectory = (Get-ChildItem -Path "$env:USERPROFILE" -Filter "OneDrive - *" -Directory).FullName

# Exit with an error if the OneDrive directory does not exist
if (-not $oneDriveDirectory) {
    Throw "OneDrive directory not found. Please ensure OneDrive is set up correctly."
}

$downloadsPath = "$env:USERPROFILE\Downloads"
$backupPath = Join-Path -Path $oneDriveDirectory -ChildPath "DownloadsBackup"

# Use splatting for function parameters
$params = @{
    SourcePath = $downloadsPath + "\"
    DestinationPath = $backupPath
}

# Execute the function with splatting
Copy-ItemsWithRobocopy @params
