#Unique Tracking ID: e2ff1880-638d-4e28-a197-cca64a109f7a, Timestamp: 2024-03-07 15:36:15
function Copy-ItemsWithRobocopy {
    param (
        [string]$SourcePath,
        [string]$DestinationPath
    )

    # Ensure the destination directory exists
    if (-not (Test-Path -Path $DestinationPath)) {
        New-Item -ItemType Directory -Force -Path $DestinationPath | Out-Null
    }

    # Use Robocopy for copying. /E is for copying subdirectories including empty ones. /R:0 and /W:0 are for no retries and no wait between retries.
    # Ensure to add a trailing backslash to the source path to copy its contents
    $robocopyArguments = @("${SourcePath}\", $DestinationPath, "/E", "/R:0", "/W:0")

    try {
        $result = robocopy @robocopyArguments
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
        Write-Error "An error occurred during the copying process: $_"
    }
}

# Define the source path for Outlook signatures
$signaturePath = Join-Path -Path $env:USERPROFILE -ChildPath "AppData\Roaming\Microsoft\Signatures"

# Check for OneDrive directory existence
$oneDriveFolder = (Get-ChildItem -Path $env:USERPROFILE -Filter "OneDrive - *" -Directory).FullName

if (-not $oneDriveFolder) {
    throw "OneDrive directory not found. Please ensure OneDrive is set up correctly."
}

# Define the destination path within the OneDrive directory
$backupPath = Join-Path -Path $oneDriveFolder -ChildPath "OutlookSignatures"

# Use splatting for function parameters
$robocopyParameters = @{
    SourcePath = $signaturePath
    DestinationPath = $backupPath
}

# Execute the function with splatting
Copy-ItemsWithRobocopy @robocopyParameters
