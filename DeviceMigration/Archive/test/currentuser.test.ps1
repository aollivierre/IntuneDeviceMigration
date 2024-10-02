# # Filter the JSON data to match the currently logged-in user
# $CurrentUser = "$env:COMPUTERNAME\$env:USERNAME"
# Write-EnhancedLog -Message "Current user detected: $CurrentUser" -Level "INFO"



# $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
# Write-Host "Current User: $currentUser"


  
# $sessionID = (Get-Process -IncludeUserName | Where-Object { $_.UserName -like "*\$CurrentUser\>*" }).SessionID
# schtasks /run /tn "AADM Get OneDrive Sync Util Status" /I $sessionID

# schtasks /run /tn "\TaskPath\TaskName"


$taskParams = @{
  TaskPath = "AAD Migration"
  TaskName = "AADM Get OneDrive Sync Util Status"
}

# Construct the full task name with path
$fullTaskName = "\$($taskParams.TaskPath)\$($taskParams.TaskName)"

# Use schtasks.exe to run the task
$command = "schtasks /run /tn `"$fullTaskName`""

Write-Host "Triggering the task using schtasks.exe: $fullTaskName"

# Execute the command
Invoke-Expression $command
















# $taskParams = @{
#   TaskPath = "AAD Migration"
#   TaskName = "AADM Get OneDrive Sync Util Status"
# }

# # Construct the full task name with path
# $fullTaskName = "\$($taskParams.TaskPath)\$($taskParams.TaskName)"

# # Use schtasks.exe to run the task as Admin-Abdullah
# # $command = "schtasks /run /tn `"$fullTaskName`" /U `Admin-Abdullah` /P `password`"

# Write-Host "Triggering the task using schtasks.exe as Admin-Abdullah: $fullTaskName"

# # Execute the command
# Invoke-Expression $command










# # Get session ID for Admin-Abdullah
# $adminSessionId = (Get-Process -IncludeUserName | Where-Object { $_.UserName -like "*Admin-Abdullah*" }).SessionID

# # Use schtasks.exe to run the task in the Admin-Abdullah session
# $command = "schtasks /run /tn `"$fullTaskName`" /I $adminSessionId"

# Write-Host "Triggering the task using schtasks.exe in Admin-Abdullah's session: $fullTaskName"

# # Execute the command
# Invoke-Expression $command







# $taskParams = @{
#   TaskPath = "AAD Migration"
#   TaskName = "AADM Get OneDrive Sync Util Status"
# }

# # Construct the full task name with path
# $fullTaskName = "\$($taskParams.TaskPath)\$($taskParams.TaskName)"

# # Correctly escape the quotes inside the string for schtasks.exe
# $command = "schtasks /run /tn `"$fullTaskName`" /U Admin-Abdullah /P password"

# Write-Host "Triggering the task using schtasks.exe as Admin-Abdullah: $fullTaskName"

# # Execute the command
# Invoke-Expression $command







# $taskParams = @{
#   TaskPath = "AAD Migration"
#   TaskName = "AADM Get OneDrive Sync Util Status"
# }

# # Construct the full task name with path
# $fullTaskName = "\$($taskParams.TaskPath)\$($taskParams.TaskName)"

# # Use schtasks.exe without specifying /U and /P for local tasks
# $command = "schtasks /run /tn `"$fullTaskName`""

# Write-Host "Triggering the task using schtasks.exe: $fullTaskName"

# # Execute the command
# Invoke-Expression $command











# $taskParams = @{
#   TaskPath = "AAD Migration"
#   TaskName = "AADM Get OneDrive Sync Util Status"
# }

# # Construct the full task name with path
# $fullTaskName = "\$($taskParams.TaskPath)\$($taskParams.TaskName)"

# # Run schtasks via PsExec to force execution as Admin-Abdullah
# $command = "C:\code\CB\Tools\PSTools\PsExec.exe -i -u Admin-Abdullah schtasks /run /tn `"$fullTaskName`""

# Write-Host "Triggering the task using PsExec as Admin-Abdullah: $fullTaskName"

# # Execute the command
# Invoke-Expression $command