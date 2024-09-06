function Rename-LogFiles {
    param (
        [string]$PSFPath = "C:\Logs\PSF"
    )

    Write-Host "Starting the renaming process for log files in directory: $PSFPath"

    $logFiles = Get-ChildItem -Path $PSFPath -Filter "*.log"
    Write-Host "Found $($logFiles.Count) log files to process."

    foreach ($logFile in $logFiles) {
        try {
            Write-Host "Processing file: $($logFile.Name)"
            
            # Extract username from the log file (mock example, replace with actual extraction method)
            $username = "WORKGROUP\SYSTEM"

            # Replace invalid characters in the username
            $safeUsername = $username -replace "[\\\/\:\*\?\"<>\|]", "-"

            $newFileName = "$($logFile.BaseName)-$safeUsername$($logFile.Extension)"
            $newFilePath = [System.IO.Path]::Combine($PSFPath, $newFileName)

            Write-Host "Attempting to rename to: $newFilePath"

            Rename-Item -Path $logFile.FullName -NewName $newFileName -Force

            Write-Host "Successfully renamed $($logFile.Name) to $newFileName" -ForegroundColor Green
        } catch {
            Write-Host "Failed to process $($logFile.Name): $_" -ForegroundColor Red
            Write-Host "Possible cause: The file name or path may contain invalid characters or the file might be in use."
        }
    }

    Write-Host "Finished processing all log files."
}
