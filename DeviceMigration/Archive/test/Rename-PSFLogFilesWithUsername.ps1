function Rename-PSFLogFilesWithUsername {
    param (
        [string]$LogDirectoryPath = "C:\Logs\PSF"
    )

    Begin {
        Write-EnhancedLog -Message "Starting Rename-PSFLogFilesWithUsername function..." -Level "NOTICE"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        Write-EnhancedLog -Message "Starting the renaming process for log files in directory: $LogDirectoryPath" -Level "INFO"

        # Get all log files in the specified directory
        $logFiles = Get-ChildItem -Path $LogDirectoryPath -Filter "*.log"

        if ($logFiles.Count -eq 0) {
            Write-EnhancedLog -Message "No log files found in the directory." -Level "WARNING"
            return
        }

        Write-EnhancedLog -Message "Found $($logFiles.Count) log files to process." -Level "INFO"

        foreach ($logFile in $logFiles) {
            try {
                Write-EnhancedLog -Message "Processing file: $($logFile.FullName)" -Level "INFO"

                # Load the log file (assuming it can be imported as CSV for simplicity)
                $logEntries = Import-Csv -Path $logFile.FullName

                # Assume the first entry's username field for demonstration
                $username = $logEntries | Select-Object -First 1 | ForEach-Object { $_.Username }
                if (-not $username) {
                    Write-EnhancedLog -Message "No username found in $($logFile.Name). Skipping file." -Level "WARNING"
                    continue
                }

                Write-EnhancedLog -Message "Username found in file: $username" -Level "INFO"

                # If the username is in the format 'ComputerName\Username', remove the ComputerName part
                if ($username -match '^[^\\]+\\(.+)$') {
                    $username = $matches[1]
                }

                Write-EnhancedLog -Message "Processed username: $username" -Level "INFO"

                # Sanitize the username by removing or replacing invalid characters
                $safeUsername = $username -replace '[\\/:*?"<>|]', '_'
                Write-EnhancedLog -Message "Sanitized username: $safeUsername" -Level "INFO"

                # Get the script name to append to the file name
                # $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.ScriptName)
                # if (-not $scriptName) {
                #     $scriptName = "UnknownScript"
                # }
                # Write-EnhancedLog -Message "Script name: $scriptName" -Level "INFO"


                # Get the parent script name from the call stack
                $callStack = Get-PSCallStack
                if ($callStack.Count -gt 1) {
                    $parentScriptName = [System.IO.Path]::GetFileNameWithoutExtension($callStack[1].ScriptName)
                }
                else {
                    $parentScriptName = "UnknownScript"
                }
                Write-EnhancedLog -Message "Parent script name: $parentScriptName" -Level "INFO"

                $DBG

                # Generate the new file name by appending the sanitized username and script name
                $originalFileName = [System.IO.Path]::GetFileNameWithoutExtension($logFile.FullName)
                $fileExtension = [System.IO.Path]::GetExtension($logFile.FullName)
                $newFileName = "$originalFileName-$safeUsername-$parentScriptName$fileExtension"
                $newFilePath = [System.IO.Path]::Combine($logFile.DirectoryName, $newFileName)
                Write-EnhancedLog -Message "Attempting to rename to: $newFilePath" -Level "INFO"

                # Perform the rename operation
                Rename-Item -Path $logFile.FullName -NewName $newFileName -Force
                Write-EnhancedLog -Message "Successfully renamed $($logFile.FullName) to $newFileName" -Level "INFO"
            }
            catch {
                Write-EnhancedLog -Message "Failed to process $($logFile.FullName): $_" -Level "ERROR"
                Write-EnhancedLog -Message "Possible cause: The file name or path may contain invalid characters or the file might be in use." -Level "ERROR"
            }
        }

        Write-EnhancedLog -Message "Finished processing all log files." -Level "INFO"
    }

    End {
        Write-EnhancedLog -Message "Exiting Rename-PSFLogFilesWithUsername function" -Level "NOTICE"
    }
}


Rename-PSFLogFilesWithUsername -LogDirectoryPath "C:\logs\PSF\2024-08-24\DeviceMigration"