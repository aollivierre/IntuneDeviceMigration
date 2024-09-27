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

# Remove all scheduled tasks under the AADMigration task path
$scheduledTasks = Get-ScheduledTask -TaskPath '\AAD Migration\'
if ($scheduledTasks) {
    foreach ($task in $scheduledTasks) {
        Write-Host "Removing scheduled task: $($task.TaskName)..."
        Unregister-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Confirm:$false
    }
} else {
    Write-Host "No scheduled tasks found under $taskPath, skipping..."
}

# Remove the scheduled task folder named AADMigration
try {
    $taskFolder = New-Object -ComObject "Schedule.Service"
    $taskFolder.Connect()
    $rootFolder = $taskFolder.GetFolder("\")
    $aadMigrationFolder = $rootFolder.GetFolder("AAD Migration")
    $aadMigrationFolder.DeleteFolder("", 0)
    Write-Host "Scheduled task folder AADMigration removed successfully."
} catch {
    Write-Host "Scheduled task folder AADMigration does not exist or could not be removed."
}
