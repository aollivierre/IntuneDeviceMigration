function Check-OneDriveSyncStatus {
    [CmdletBinding()]
    param (
        [string]$OneDriveLibPath,
        [string]$Scriptbasepath
    )

    # Define the log file path
    $logFolder = Join-Path -Path (Get-Item -Path $Scriptbasepath).Parent.FullName -ChildPath "logs"
    $statusFile = Join-Path -Path $logFolder -ChildPath "OneDriveSyncStatus.json"

    # Ensure the log directory exists
    if (-not (Test-Path -Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory | Out-Null
    }

    # Import the OneDrive module
    if (-not (Test-Path $OneDriveLibPath)) {
        throw "The specified OneDriveLib.dll path does not exist: $OneDriveLibPath"
    }
    Import-Module $OneDriveLibPath

    # Get OneDrive Status and store it in a JSON file
    $Status = Get-ODStatus

    if ($Status) {
        $Status | ConvertTo-Json | Out-File -FilePath $statusFile -Force -Encoding utf8
        Write-EnhancedLog -Message "OneDrive sync status has been saved to $statusFile" -Level "INFO"
    }
    else {
        Write-EnhancedLog -Message "Failed to retrieve OneDrive sync status." -Level "ERROR"
    }
}

# Example usage
$params = @{
    OneDriveLibPath = "C:\ProgramData\AADMigration\Files\OneDriveLib.dll"
    Scriptbasepath  = "$PSScriptroot"
}
Check-OneDriveSyncStatus @params