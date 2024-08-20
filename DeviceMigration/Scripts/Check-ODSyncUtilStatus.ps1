function Check-ODSyncUtilStatus {
    <#
    .SYNOPSIS
    Checks the OneDrive sync status using ODSyncUtil and stores it in a JSON file.

    .DESCRIPTION
    The Check-ODSyncUtilStatus function calls the `Get-ODStatus.ps1` script located in the specified path, retrieves the OneDrive sync status, and saves it to a JSON file in the designated log directory.

    .PARAMETER ScriptPath
    The path to the directory containing the `Get-ODStatus.ps1` script.

    .PARAMETER LogFolderName
    The name of the folder where the log files will be stored.

    .PARAMETER StatusFileName
    The name of the file where the OneDrive sync status will be saved.

    .EXAMPLE
    $params = @{
        ScriptPath     = "C:\code\IntuneDeviceMigration\DeviceMigration\Files\ODSyncUtil"
        LogFolderName  = "logs"
        StatusFileName = "ODSyncUtilStatus.json"
    }
    Check-ODSyncUtilStatus @params
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,

        [Parameter(Mandatory = $false)]
        [string]$LogFolderName = "logs",

        [Parameter(Mandatory = $false)]
        [string]$StatusFileName = "ODSyncUtilStatus.json"
    )

    Begin {
        Write-EnhancedLog -Message "Starting Check-ODSyncUtilStatus function" -Level "Notice"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters

        # Check if running with admin privileges
        $isAdmin = CheckAndElevate -ElevateIfNotAdmin $false

        if ($isAdmin) {
            Write-EnhancedLog -Message "Script is running with administrative privileges. Exiting because this operation should be run in user context." -Level "ERROR"
            throw "This script must be run in a non-administrative user context."
        }

        $DownloadODSyncUtilParams = @{
            Destination    = (Join-Path -Path $env:USERPROFILE -ChildPath "AADMigration\Files\ODSyncUtil\ODSyncUtil.exe")
            ApiUrl         = "https://api.github.com/repos/rodneyviana/ODSyncUtil/releases/latest"
            ZipFileName    = "ODSyncUtil-64-bit.zip"
            ExecutableName = "ODSyncUtil.exe"
            MaxRetries     = 3
        }
        Download-ODSyncUtil @DownloadODSyncUtilParams
        


        # Define the log file path
        # Get the parent of the parent directory of ScriptPath
        $parentOfParentPath = (Get-Item -Path $ScriptPath).Parent.Parent.FullName

        # Define the log file path in the parent of the parent directory
        $logFolder = Join-Path -Path $parentOfParentPath -ChildPath $LogFolderName

        $statusFile = Join-Path -Path $logFolder -ChildPath $StatusFileName

        # Ensure the log directory exists
        if (-not (Test-Path -Path $logFolder)) {
            Write-EnhancedLog -Message "Creating log folder at $logFolder" -Level "INFO"
            New-Item -Path $logFolder -ItemType Directory | Out-Null
        }
    }

    
    Process {
        try {
            # Define the full path to Get-ODStatus.ps1
            $getODStatusScript = Join-Path -Path $ScriptPath -ChildPath "Get-ODStatus.ps1"
    
            if (-not (Test-Path $getODStatusScript)) {
                $errorMessage = "The specified script path does not contain Get-ODStatus.ps1: $getODStatusScript"
                Write-EnhancedLog -Message $errorMessage -Level "Critical"
                throw $errorMessage
            }
    
            # Temporarily change location to ScriptPath
            Write-EnhancedLog -Message "Changing to script directory: $ScriptPath" -Level "INFO"
            Push-Location -Path $ScriptPath
    
            # Run the Get-ODStatus.ps1 script and capture the output as a PowerShell object
            Write-EnhancedLog -Message "Executing $getODStatusScript with non-elevated privileges" -Level "INFO"
            $status = . $getODStatusScript
    
            # Convert the output directly to JSON and save it
            if ($status) {
                Write-EnhancedLog -Message "Saving OneDrive sync status to $statusFile" -Level "INFO"
                $status | ConvertTo-Json -Depth 3 | Out-File -FilePath $statusFile -Force -Encoding utf8
            }
            else {
                Write-EnhancedLog -Message "Failed to retrieve OneDrive sync status." -Level "ERROR"
            }
        }
        catch {
            Write-EnhancedLog -Message "An error occurred in Check-ODSyncUtilStatus function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw $_
        }
        finally {
            # Return to the original location
            Pop-Location
            Write-EnhancedLog -Message "Returned to the original directory" -Level "INFO"
        }
    }
    

    End {
        Write-EnhancedLog -Message "Exiting Check-ODSyncUtilStatus function" -Level "Notice"
    }
}

# Example usage
$CheckODSyncUtilStatusParams = @{
    ScriptPath     = "C:\ProgramData\AADMigration\Files\ODSyncUtil"
    LogFolderName  = "logs"
    StatusFileName = "ODSyncUtilStatus.json"
}
Check-ODSyncUtilStatus @CheckODSyncUtilStatusParams