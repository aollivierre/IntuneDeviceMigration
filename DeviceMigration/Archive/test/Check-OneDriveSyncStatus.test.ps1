function Check-OneDriveSyncStatus {
    <#
    .SYNOPSIS
    Checks the OneDrive sync status and stores it in a JSON file.

    .DESCRIPTION
    The Check-OneDriveSyncStatus function imports the OneDrive module from the specified path, retrieves the OneDrive sync status, and saves it to a JSON file in the designated log directory.

    .PARAMETER OneDriveLibPath
    The path to the OneDriveLib.dll file to be imported.

    .PARAMETER ScriptBasePath
    The base path where the script is located; used to determine the log directory.

    .PARAMETER LogFolderName
    The name of the folder where the log files will be stored.

    .PARAMETER StatusFileName
    The name of the file where the OneDrive sync status will be saved.

    .EXAMPLE
    $params = @{
        OneDriveLibPath = "C:\YourPath\OneDriveLib.dll"
        ScriptBasePath  = "C:\YourPath\YourScript.ps1"
        LogFolderName   = "logs"
        StatusFileName  = "OneDriveSyncStatus.json"
    }
    Check-OneDriveSyncStatus @params
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OneDriveLibPath,

        [Parameter(Mandatory = $true)]
        [string]$ScriptBasePath,

        [Parameter(Mandatory = $false)]
        [string]$LogFolderName = "logs",

        [Parameter(Mandatory = $false)]
        [string]$StatusFileName = "OneDriveSyncStatus.json"
    )

    Begin {
        Write-EnhancedLog -Message "Starting Check-OneDriveSyncStatus function" -Level "Notice"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters

        # Define the log file path
        $logFolder = Join-Path -Path (Get-Item -Path $ScriptBasePath).Parent.FullName -ChildPath $LogFolderName
        $statusFile = Join-Path -Path $logFolder -ChildPath $StatusFileName

        # Ensure the log directory exists
        if (-not (Test-Path -Path $logFolder)) {
            Write-EnhancedLog -Message "Creating log folder at $logFolder" -Level "INFO"
            New-Item -Path $logFolder -ItemType Directory | Out-Null
        }

        # # Example usage
        $params = @{
            Destination = "C:\ProgramData\AADMigration\Files\OneDriveLib.dll"
            ApiUrl      = "https://api.github.com/repos/rodneyviana/ODSyncService/releases/latest"
            FileName    = "OneDriveLib.dll"
            MaxRetries  = 3
        }
        Download-OneDriveLib @params

    }

    Process {
        try {
            # Import the OneDrive module
            if (-not (Test-Path $OneDriveLibPath)) {
                $errorMessage = "The specified OneDriveLib.dll path does not exist: $OneDriveLibPath"
                Write-EnhancedLog -Message $errorMessage -Level "Critical"
                throw $errorMessage
            }
            Write-EnhancedLog -Message "Importing OneDriveLib module from $OneDriveLibPath" -Level "INFO"
            Import-Module $OneDriveLibPath

            # Get OneDrive Status and store it in a JSON file
            Write-EnhancedLog -Message "Retrieving OneDrive sync status" -Level "INFO"
            $Status = Get-ODStatus

            if ($Status) {
                Write-EnhancedLog -Message "Saving OneDrive sync status to $statusFile" -Level "INFO"
                $Status | ConvertTo-Json | Out-File -FilePath $statusFile -Force -Encoding utf8
            }
            else {
                Write-EnhancedLog -Message "Failed to retrieve OneDrive sync status." -Level "ERROR"
            }
        }
        catch {
            Write-EnhancedLog -Message "An error occurred in Check-OneDriveSyncStatus function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Check-OneDriveSyncStatus function" -Level "Notice"
    }
}

# Example usage
$params = @{
    OneDriveLibPath = "C:\ProgramData\AADMigration\Files\OneDriveLib.dll"
    ScriptBasePath  = "C:\YourPath\YourScript.ps1"
    LogFolderName   = "logs"
    StatusFileName  = "OneDriveSyncStatus.json"
}
Check-OneDriveSyncStatus @params