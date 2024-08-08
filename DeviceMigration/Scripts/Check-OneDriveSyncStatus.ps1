function Check-OneDriveSyncStatus {
    [CmdletBinding()]
    param (
        [string]$OneDriveLibPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Check-OneDriveSyncStatus function" -Level "Notice"
        Log-Params -Params @{ OneDriveLibPath = $OneDriveLibPath }

        # Check if running elevated
        # $isElevated = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        # if ($isElevated) {
        #     Write-EnhancedLog -Message "Session is running elevated. Skipping Check-OneDriveSyncStatus function." -Level "INFO"
        #     return
        # }

        # CheckAndElevate

        # Import OneDriveLib.dll to check current OneDrive Sync Status
        Import-Module $OneDriveLibPath
    }

    Process {
        if ($isElevated) {
            return
        }

        try {
            $Status = Get-ODStatus

            if (-not $Status) {
                Write-EnhancedLog -Message "OneDrive is not running or the user is not logged in to OneDrive." -Level "WARNING"
                return
            }

            # Create objects with known statuses listed.
            $Success = @( "Shared", "UpToDate", "Up To Date" )
            $InProgress = @( "SharedSync", "Shared Sync", "Syncing" )
            $Failed = @( "Error", "ReadOnly", "Read Only", "OnDemandOrUnknown", "On Demand or Unknown", "Paused")

            # Multiple OD4B accounts may be found. Consider adding logic to identify correct OD4B. Iterate through all accounts to check status and log the result.
            ForEach ($s in $Status) {
                $StatusString = $s.StatusString
                $DisplayName = $s.DisplayName
                $User = $s.UserName

                if ($s.StatusString -in $Success) {
                    Write-EnhancedLog -Message "OneDrive sync status is healthy: Display Name: $DisplayName, User: $User, Status: $StatusString" -Level "INFO"
                }
                elseif ($s.StatusString -in $InProgress) {
                    Write-EnhancedLog -Message "OneDrive sync status is currently syncing: Display Name: $DisplayName, User: $User, Status: $StatusString" -Level "INFO"
                }
                elseif ($s.StatusString -in $Failed) {
                    Write-EnhancedLog -Message "OneDrive sync status is in a known error state: Display Name: $DisplayName, User: $User, Status: $StatusString" -Level "ERROR"
                }
                elseif (-not $s.StatusString) {
                    Write-EnhancedLog -Message "Unable to get OneDrive Sync Status for Display Name: $DisplayName, User: $User" -Level "WARNING"
                }

                if (-not $Status.StatusString) {
                    Write-EnhancedLog -Message "Unable to get OneDrive Sync Status." -Level "ERROR"
                }
            }
        }
        catch {
            Write-EnhancedLog -Message "An error occurred while checking OneDrive sync status: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Check-OneDriveSyncStatus function" -Level "Notice"
    }
}

# Example usage
$params = @{
    OneDriveLibPath = "C:\ProgramData\AADMigration\Files\OneDriveLib.dll"
}
Check-OneDriveSyncStatus @params