function Rename-LogFilesWithUsername {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LogDirectory = "C:\Logs\PSF"
    )

    try {
        Write-Host "Starting the renaming process for log files in directory: $LogDirectory" -ForegroundColor Cyan

        # Get all log files in the directory
        $logFiles = Get-ChildItem -Path $LogDirectory -Filter "*.log"

        Write-Host "Found $($logFiles.Count) log files to process." -ForegroundColor Cyan

        foreach ($logFile in $logFiles) {
            try {
                Write-Host "Processing file: $($logFile.Name)" -ForegroundColor Yellow
                
                # Import the log file as a CSV
                $logEntries = Import-Csv -Path $logFile.FullName
                
                # Retrieve the first non-empty username in the log file
                $username = ($logEntries | Where-Object { $_.Username -and $_.Username -ne '' }).Username | Select-Object -First 1
                $username = if ($username) { $username } else { "UnknownUser" }
                Write-Host "Username found in file: $username" -ForegroundColor Yellow

                # Sanitize the username and log file name
                $sanitizedUsername = [System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object { $username -replace [regex]::Escape($_), '' }
                $sanitizedBaseName = $logFile.BaseName

                # Generate the new file name with the username appended
                $newFileName = "$sanitizedBaseName-$sanitizedUsername$($logFile.Extension)"
                $newFilePath = [System.IO.Path]::Combine($LogDirectory, $newFileName)

                Write-Host "Attempting to rename to: $newFilePath" -ForegroundColor Yellow
                
                # Attempt to rename the log file
                Rename-Item -Path $logFile.FullName -NewName $newFilePath -Force
                Write-Host "Successfully renamed $($logFile.Name) to $newFileName" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to process $($logFile.Name): $_" -ForegroundColor Red
                Write-Host "Possible cause: The file name or path may contain invalid characters or the file might be in use." -ForegroundColor Red
                Write-Host "Log file path attempted: $newFilePath" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "An error occurred while processing log files: $_" -ForegroundColor Red
        throw $_
    }

    Write-Host "Finished processing all log files." -ForegroundColor Cyan
}




Rename-LogFilesWithUsername -LogDirectory "C:\Logs\PSF"