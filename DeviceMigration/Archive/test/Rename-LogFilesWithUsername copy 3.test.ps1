function Rename-LogFilesWithUsername {
    param (
        [string]$LogDirectoryPath = "C:\Logs\PSF"
    )

    Write-Host "Starting the renaming process for log files in directory: $LogDirectoryPath"

    # Get all log files in the specified directory
    $logFiles = Get-ChildItem -Path $LogDirectoryPath -Filter "*.log"

    if ($logFiles.Count -eq 0) {
        Write-Host "No log files found in the directory." -ForegroundColor Yellow
        return
    }

    Write-Host "Found $($logFiles.Count) log files to process."

    foreach ($logFile in $logFiles) {
        try {
            Write-Host "Processing file: $($logFile.FullName)"

            # Load the log file (assuming it can be imported as CSV for simplicity)
            $logEntries = Import-Csv -Path $logFile.FullName

            # Assume the first entry's username field for demonstration
            $username = $logEntries | Select-Object -First 1 | ForEach-Object { $_.Username }
            if (-not $username) {
                Write-Host "No username found in $($logFile.Name). Skipping file." -ForegroundColor Yellow
                continue
            }
            
            Write-Host "Username found in file: $username"

            # Sanitize the username by removing or replacing invalid characters
            $safeUsername = $username -replace '[\\/:*?"<>|]', '_'
            Write-Host "Sanitized username: $safeUsername"

            # Generate the new file name by appending the sanitized username
            $originalFileName = [System.IO.Path]::GetFileNameWithoutExtension($logFile.FullName)
            $fileExtension = [System.IO.Path]::GetExtension($logFile.FullName)
            $newFileName = "$originalFileName-$safeUsername$fileExtension"
            $newFilePath = [System.IO.Path]::Combine($logFile.DirectoryName, $newFileName)
            Write-Host "Attempting to rename to: $newFilePath"

            # Perform the rename operation
            Rename-Item -Path $logFile.FullName -NewName $newFileName -Force
            Write-Host "Successfully renamed $($logFile.FullName) to $newFileName" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to process $($logFile.FullName): $_" -ForegroundColor Red
            Write-Host "Possible cause: The file name or path may contain invalid characters or the file might be in use."
        }
    }

    Write-Host "Finished processing all log files."
}

# Run the function on the specified directory
Rename-LogFilesWithUsername -LogDirectoryPath "C:\Logs\PSF"
