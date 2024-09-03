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

# Example usage with splatting
$CreatePostMigrationCleanupTaskParams = @{
    TaskPath            = "AAD Migration"
    TaskName            = "Run Post migration cleanup"
    ScriptDirectory     = "C:\ProgramData\AADMigration\Scripts"
    ScriptName          = "ExecuteMigrationCleanupTasks.ps1"
    TaskArguments       = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"{ScriptPath}`""
    TaskPrincipalUserId = "NT AUTHORITY\SYSTEM"
    TaskRunLevel        = "Highest"
    PowerShellPath      = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    TaskDescription     = "Run post AAD Migration cleanup"
    TaskTriggerType     = "AtLogOn"  # The trigger type can be passed as a parameter now
    Delay               = "PT1M"  # Optional delay before starting
}

Create-PostMigrationCleanupTask @CreatePostMigrationCleanupTaskParams