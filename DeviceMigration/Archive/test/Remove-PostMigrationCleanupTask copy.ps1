#region FIRING UP MODULE STARTER
#################################################################################################
#                                                                                               #
#                                 FIRING UP MODULE STARTER                                      #
#                                                                                               #
#################################################################################################

# Fetch the script content
$scriptContent = Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1"

# Define replacements in a hashtable
$replacements = @{
    '\$Mode = "dev"'                     = '$Mode = "dev"'
    '\$SkipPSGalleryModules = \$false'   = '$SkipPSGalleryModules = $True'
    '\$SkipCheckandElevate = \$false'    = '$SkipCheckandElevate = $True'
    '\$SkipAdminCheck = \$false'         = '$SkipAdminCheck = $True'
    '\$SkipPowerShell7Install = \$false' = '$SkipPowerShell7Install = $True'
    '\$SkipModuleDownload = \$false'     = '$SkipModuleDownload = $True'
}

# Apply the replacements
foreach ($pattern in $replacements.Keys) {
    $scriptContent = $scriptContent -replace $pattern, $replacements[$pattern]
}

# Execute the script
Invoke-Expression $scriptContent

#endregion



#region CALLING AS SYSTEM
#################################################################################################
#                                                                                               #
#                                 CALLING AS SYSTEM                                             #
#                Simulate Intune deployment as SYSTEM (Uncomment for debugging)                 #
#                                                                                               #
#################################################################################################

# $ensureRunningAsSystemParams = @{
#     PsExec64Path = Join-Path -Path $PSScriptRoot -ChildPath "private\PsExec64.exe"
#     ScriptPath   = $MyInvocation.MyCommand.Path
#     TargetFolder = Join-Path -Path $PSScriptRoot -ChildPath "private"
# }

# Ensure-RunningAsSystem @ensureRunningAsSystemParams



# $UnregisterParams = @{
#     TaskName = "Run Post migration cleanup"
#     TaskPath = "AAD Migration"
# }
    
# Unregister-ScheduledTaskWithLogging @UnregisterParams
    


# Example usage
# $TaskPath = "AAD Migration"
# $TaskName = "Run Post migration cleanup"
# Unregister-ScheduledTaskWithLogging -TaskName $TaskName


# Retrieve all tasks in the "AAD Migration" path
$tasks = Get-ScheduledTask -TaskPath "\AAD Migration\" -ErrorAction SilentlyContinue

# Loop through each task and unregister it using the Unregister-ScheduledTaskWithLogging function
foreach ($task in $tasks) {
    Unregister-ScheduledTaskWithLogging -TaskName $task.TaskName
}
