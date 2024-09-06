function Rename-LogFile {
    param (
        [string]$LogFilePath = "C:\Logs\PSF\DESKTOP-9KHVRUI_11024_message_0.log"
    )

    Write-Host "Starting the renaming process for log file: $LogFilePath"

    try {
        # Load the log file
        $logEntries = Import-Csv -Path $LogFilePath

        # Assume extracting the first entry's username as a demonstration
        $username = "WORKGROUP\SYSTEM"  # Replace this with actual extraction logic
        Write-Host "Username found in file: $username"

        # Sanitize the username by removing or replacing invalid characters
        $safeUsername = $username -replace '[\\/:*?"<>|]', '_'
        Write-Host "Sanitized username: $safeUsername"

        # Generate the new file name by appending the sanitized username
        $originalFileName = [System.IO.Path]::GetFileNameWithoutExtension($LogFilePath)
        $fileExtension = [System.IO.Path]::GetExtension($LogFilePath)
        $newFileName = "$originalFileName-$safeUsername$fileExtension"
        $newFilePath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($LogFilePath), $newFileName)
        Write-Host "Attempting to rename to: $newFilePath"

        # Perform the rename operation
        Rename-Item -Path $LogFilePath -NewName $newFileName -Force
        Write-Host "Successfully renamed $($LogFilePath) to $newFileName" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to process $($LogFilePath): $_" -ForegroundColor Red
        Write-Host "Possible cause: The file name or path may contain invalid characters or the file might be in use."
    }
}

# Run the function on a single file
Rename-LogFile -LogFilePath "C:\Logs\PSF\DESKTOP-9KHVRUI_11024_message_0.log"
