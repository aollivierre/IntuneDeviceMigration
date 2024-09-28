function Remove-AADMigrationArtifacts {
    <#
    .SYNOPSIS
    Cleans up AAD migration artifacts, including directories, scheduled tasks, and a local user.

    .DESCRIPTION
    The `Remove-AADMigrationArtifacts` function removes the following AAD migration-related artifacts:
    - The `C:\logs` directory
    - The `C:\ProgramData\AADMigration` directory
    - All scheduled tasks under the `AAD Migration` task path
    - The `AAD Migration` scheduled task folder
    - A local user account named `MigrationInProgress`

    .EXAMPLE
    Remove-AADMigrationArtifacts

    Cleans up all AAD migration artifacts.

    .NOTES
    This function should be run with administrative privileges.
    #>

    [CmdletBinding()]
    param ()

    Begin {
        Write-Host "Starting AAD migration artifact cleanup..."
    }

    Process {
        # Remove the C:\logs directory if it exists
        $logsPath = "C:\logs"
        if (Test-Path -Path $logsPath) {
            Write-Host "Removing $logsPath..."
            Remove-Item -Path $logsPath -Recurse -Force
        } else {
            Write-Host "$logsPath does not exist, skipping..."
        }

        # Remove the C:\ProgramData\AADMigration directory if it exists
        $aadMigrationPath = "C:\ProgramData\AADMigration"
        if (Test-Path -Path $aadMigrationPath) {
            Write-Host "Removing $aadMigrationPath..."
            Remove-Item -Path $aadMigrationPath -Recurse -Force
        } else {
            Write-Host "$aadMigrationPath does not exist, skipping..."
        }

        # Remove all scheduled tasks under the AAD Migration task path
        $scheduledTasks = Get-ScheduledTask -TaskPath '\AAD Migration\' -ErrorAction SilentlyContinue
        if ($scheduledTasks) {
            foreach ($task in $scheduledTasks) {
                Write-Host "Removing scheduled task: $($task.TaskName)..."
                Unregister-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Confirm:$false
            }
        } else {
            Write-Host "No scheduled tasks found under \AAD Migration, skipping..."
        }

        # Remove the scheduled task folder named AAD Migration
        try {
            $taskFolder = New-Object -ComObject "Schedule.Service"
            $taskFolder.Connect()
            $rootFolder = $taskFolder.GetFolder("\")
            $aadMigrationFolder = $rootFolder.GetFolder("AAD Migration")
            $aadMigrationFolder.DeleteFolder("", 0)
            Write-Host "Scheduled task folder AAD Migration removed successfully."
        } catch {
            Write-Host "Scheduled task folder AAD Migration does not exist or could not be removed."
        }

        # Remove the local user called MigrationInProgress
        $localUser = "MigrationInProgress"
        try {
            $user = Get-LocalUser -Name $localUser -ErrorAction Stop
            if ($user) {
                Write-Host "Removing local user $localUser..."
                Remove-LocalUser -Name $localUser -Force
            }
        } catch {
            Write-Host "Local user $localUser does not exist, skipping..."
        }
    }

    End {
        Write-Host "AAD migration artifact cleanup completed."
    }
}

Remove-AADMigrationArtifacts