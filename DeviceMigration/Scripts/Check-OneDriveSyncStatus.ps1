function Check-OneDriveSyncStatus {
    [CmdletBinding()]
    param (
        [string]$OneDriveLibPath
    )

    Begin {
        Write-Host "Starting Check-OneDriveSyncStatus function"
        # Log-Params -Params @{ OneDriveLibPath = $OneDriveLibPath }

        # Check if running elevated
        $isElevated = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if ($isElevated) {
            Write-Host "Session is running elevated. Skipping Check-OneDriveSyncStatus function."
            return
        }

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
                Write-Host "OneDrive is not running or the user is not logged in to OneDrive."
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
                    Write-Host "OneDrive sync status is healthy: Display Name: $DisplayName, User: $User, Status: $StatusString"
                }
                elseif ($s.StatusString -in $InProgress) {
                    Write-Host "OneDrive sync status is currently syncing: Display Name: $DisplayName, User: $User, Status: $StatusString"
                }
                elseif ($s.StatusString -in $Failed) {
                    Write-Host "OneDrive sync status is in a known error state: Display Name: $DisplayName, User: $User, Status: $StatusString"
                }
                elseif (-not $s.StatusString) {
                    Write-Host "Unable to get OneDrive Sync Status for Display Name: $DisplayName, User: $User"
                }

                if (-not $Status.StatusString) {
                    Write-Host "Unable to get OneDrive Sync Status."
                }
            }
        }
        catch {
            Write-Host "An error occurred while checking OneDrive sync status: $($_.Exception.Message)"
            # Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-Host "Exiting Check-OneDriveSyncStatus function"
    }
}

# Example usage
Check-OneDriveSyncStatus -OneDriveLibPath "C:\ProgramData\AADMigration\Files\OneDriveLib.dll"
