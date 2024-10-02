Import-Module 'C:\code\ModulesV2\EnhancedModuleStarterAO\EnhancedModuleStarterAO.psm1'

# Define a hashtable for splatting
$moduleStarterParams = @{
    Mode                   = 'dev'
    SkipPSGalleryModules   = $true
    SkipCheckandElevate    = $true
    SkipPowerShell7Install = $true
    SkipEnhancedModules    = $true
    SkipGitRepos           = $true
}

# Call the function using the splat
Invoke-ModuleStarter @moduleStarterParams



# # # Example usage
# # Define parameters using a hashtable
# $taskParams = @{
#     TaskPath = "AAD Migration"
#     TaskName = "AADM Get OneDrive Sync Util Status"
# }

# # Call the function with splatting
# Trigger-ScheduledTask @taskParams

# $TaskPath = "AAD Migration"
# $TaskName = "AADM Get OneDrive Sync Util Status"

# $isTaskValid = Validate-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName
# if (-not $isTaskValid) {
#     Write-EnhancedLog -Message "Validation failed. The scheduled task '$TaskName' does not exist or is invalid." -Level "ERROR"
#     return
# }



# $sessionID = (Get-Process -IncludeUserName | Where-Object { $_.UserName -like "*\<Username\>*" }).SessionID
# schtasks /run /tn "AADM Get OneDrive Sync Util Status" /I $sessionID









$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Write-Host "Current User: $currentUser"


# $CreateOneDriveSyncUtilStatusTask = @{
#     TaskPath               = "AAD Migration"
#     TaskName               = "AADM Get OneDrive Sync Util Status"
#     ScriptDirectory        = "C:\ProgramData\AADMigration\Scripts"
#     ScriptName             = "Check-ODSyncUtilStatus.Task.ps1"
#     TaskArguments          = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -file `"{ScriptPath}`""
#     TaskRepetitionDuration = "P1D"
#     TaskRepetitionInterval = "PT30M"
#     TaskPrincipalGroupId   = "BUILTIN\Users"
#     PowerShellPath         = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
#     TaskDescription        = "AADM Get OneDrive Sync Util Status"
#     AtLogOn                = $true
# }

# Create-OneDriveSyncUtilStatusTask @CreateOneDriveSyncUtilStatusTask



$CreateOneDriveSyncUtilStatusTask = @{
    TaskPath               = "AAD Migration"
    TaskName               = "AADM Get OneDrive Sync Util Status"
    ScriptDirectory        = "C:\ProgramData\AADMigration\Scripts"
    ScriptName             = "Check-ODSyncUtilStatus.Task.ps1"
    TaskArguments          = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -file `"{ScriptPath}`""
    TaskRepetitionDuration = "P1D"
    TaskRepetitionInterval = "PT30M"
    PowerShellPath         = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    TaskDescription        = "Get current OneDrive Sync Status and write to event log"
    AtLogOn                = $true
    UseCurrentUser         = $true  # Specify to use the current user
    # TaskPrincipalGroupId   = "BUILTIN\Users"
}

Create-OneDriveSyncUtilStatusTask @CreateOneDriveSyncUtilStatusTask



$taskParams = @{
    TaskPath = "AAD Migration"
    TaskName = "AADM Get OneDrive Sync Util Status"
}

# Call the function with splatting
Trigger-ScheduledTask @taskParams