# Check-OneDriveSyncStatusBlock.ps1

param ($OneDriveLibPath)

Import-Module $OneDriveLibPath
$Status = Get-ODStatus

if (-not $Status) {
    return "OneDrive is not running or the user is not logged in to OneDrive."
}

$Success = @( "Shared", "UpToDate", "Up To Date" )
$InProgress = @( "SharedSync", "Shared Sync", "Syncing" )
$Failed = @( "Error", "ReadOnly", "Read Only", "OnDemandOrUnknown", "On Demand or Unknown", "Paused")

$result = foreach ($s in $Status) {
    $StatusString = $s.StatusString
    $DisplayName = $s.DisplayName
    $User = $s.UserName

    if ($StatusString -in $Success) {
        "OneDrive sync status is healthy: Display Name: $DisplayName, User: $User, Status: $StatusString"
    }
    elseif ($StatusString -in $InProgress) {
        "OneDrive sync status is currently syncing: Display Name: $DisplayName, User: $User, Status: $StatusString"
    }
    elseif ($StatusString -in $Failed) {
        "OneDrive sync status is in a known error state: Display Name: $DisplayName, User: $User, Status: $StatusString"
    }
    else {
        "Unable to get OneDrive Sync Status for Display Name: $DisplayName, User: $User"
    }
}

return $result -join "`n"
