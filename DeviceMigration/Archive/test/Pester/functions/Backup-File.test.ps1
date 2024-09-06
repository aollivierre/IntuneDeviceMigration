function Sanitize-Timestamp {

    <#
    .SYNOPSIS
        Sanitizes a timestamp to ensure it is suitable for use in a file name.

    .DESCRIPTION
        The Sanitize-Timestamp function takes a timestamp string and replaces characters that are not allowed in file names with appropriate alternatives.

    .PARAMETER Timestamp
        The original timestamp string that needs to be sanitized.

    .OUTPUTS
        System.String
        The sanitized timestamp string.

    .EXAMPLE
        $sanitizedTimestamp = Sanitize-Timestamp -Timestamp "09/03/2024 12:00:00"
        This will return a sanitized timestamp like "20240903120000".

    .NOTES
        Version: 1.0
        Author: [Your Name]
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The original timestamp string that needs to be sanitized.")]
        [string]$Timestamp
    )

    Begin {
        Write-EnhancedLog -Message "Initializing Sanitize-Timestamp function." -Level "NOTICE"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            Write-EnhancedLog -Message "Original timestamp: $Timestamp" -Level "INFO"

            # Sanitize the timestamp by removing or replacing invalid characters
            $sanitizedTimestamp = $Timestamp -replace '[:/ ]', ''
            Write-EnhancedLog -Message "Sanitized timestamp: $sanitizedTimestamp" -Level "INFO"

            Write-EnhancedLog -Message "Sanitize-Timestamp function completed successfully." -Level "NOTICE"
            return $sanitizedTimestamp
        }
        catch {
            Write-EnhancedLog -Message "Error occurred in Sanitize-Timestamp function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
        finally {
            Write-EnhancedLog -Message "Exiting Sanitize-Timestamp function." -Level "NOTICE"
        }

        # Optional: Add a wait point for debugging purposes
        # Wait-Debugger
    }

    End {
        Write-EnhancedLog -Message "Sanitize-Timestamp function has fully completed." -Level "NOTICE"
    }
}



function Backup-File {

    <#
    .SYNOPSIS
        Creates a timestamped backup of a specified file in a designated directory.

    .DESCRIPTION
        The Backup-File function checks if the specified source file exists, ensures the backup directory exists,
        creates a timestamped copy of the file in the backup directory, and returns the path to the backup file.

    .PARAMETER SourceFilePath
        The full path to the source file that needs to be backed up.

    .PARAMETER BackupDirectory
        The directory where the backup file will be stored.

    .OUTPUTS
        System.String
        The full path of the created backup file.

    .EXAMPLE
        Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
        This will create a timestamped backup of TestFile.txt in the C:\Temp\Backups directory.

    .NOTES
        Version: 1.0
        Author: [Your Name]
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The full path to the source file that needs to be backed up.")]
        [string]$SourceFilePath,

        [Parameter(Mandatory = $true, HelpMessage = "The directory where the backup file will be stored.")]
        [string]$BackupDirectory
    )

    Begin {
        Write-EnhancedLog -Message "Initializing Backup-File function." -Level "NOTICE"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            # Check if the source file exists
            if (-Not (Test-Path -Path $SourceFilePath)) {
                Write-EnhancedLog -Message "Source file does not exist: $SourceFilePath" -Level "ERROR"
                throw "Source file does not exist."
            }

            Write-EnhancedLog -Message "Source file exists: $SourceFilePath" -Level "INFO"

            # Ensure the backup directory exists
            if (-Not (Test-Path -Path $BackupDirectory)) {
                Write-EnhancedLog -Message "Backup directory does not exist. Creating: $BackupDirectory" -Level "INFO"
                New-Item -Path $BackupDirectory -ItemType Directory | Out-Null
            }

            Write-EnhancedLog -Message "Backup directory is ready: $BackupDirectory" -Level "INFO"

            # Create a timestamped backup filename
            $timestamp = Get-Date -Format "yyyyMMddHHmmss"
            Write-EnhancedLog -Message "Generated timestamp: $timestamp" -Level "INFO"

            # Sanitize the timestamp
            $sanitizedTimestamp = Sanitize-Timestamp -Timestamp $timestamp
            Write-EnhancedLog -Message "Sanitized timestamp: $sanitizedTimestamp" -Level "INFO"

            $backupFileName = "$($sanitizedTimestamp)_$(Split-Path -Leaf $SourceFilePath)"
            Write-EnhancedLog -Message "Backup file name: $backupFileName" -Level "INFO"

            $backupFilePath = Join-Path -Path $BackupDirectory -ChildPath $backupFileName
            Write-EnhancedLog -Message "Full backup file path: $backupFilePath" -Level "INFO"

            # Copy the file to the backup directory
            Copy-Item -Path $SourceFilePath -Destination $backupFilePath
            Write-EnhancedLog -Message "File copied to $backupFilePath" -Level "INFO"

            Write-EnhancedLog -Message "Backup-File function completed successfully." -Level "NOTICE"
            return $backupFilePath

        }
        catch {
            Write-EnhancedLog -Message "Error occurred in Backup-File function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
        finally {
            Write-EnhancedLog -Message "Exiting Backup-File function." -Level "NOTICE"
        }

        # Optional: Add a wait point for debugging purposes
        # Wait-Debugger
    }

    End {
        Write-EnhancedLog -Message "Backup-File function has fully completed." -Level "NOTICE"
    }
}





# Example usage of the Backup-File function in a script

# Define the path to the source file you want to back up
# $sourceFilePath = "C:\Temp\TestFile.txt"

# Define the directory where the backup will be stored
# $backupDirectory = "C:\Temp\Backups"

# Call the Backup-File function
# try {
# Write-Host "Starting backup process for $sourceFilePath" -ForegroundColor Cyan

# Invoke the Backup-File function and capture the result
# $backupFilePath = Backup-File -SourceFilePath $sourceFilePath -BackupDirectory $backupDirectory

# Write-Host "Backup completed successfully. Backup file created at: $backupFilePath" -ForegroundColor Green

# } catch {
#     Write-Host "An error occurred during the backup process: $($_.Exception.Message)" -ForegroundColor Red
# }

# Write-Host "Backup process finished." -ForegroundColor Cyan
