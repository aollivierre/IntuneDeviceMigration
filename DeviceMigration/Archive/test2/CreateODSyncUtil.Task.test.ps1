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






      
# $NewScheduledTaskUtilityTaskParams = @{
    
#     ### General Task Settings ###
#     TaskPath             = "AAD Migration"  # The path to the task in the Task Scheduler (like a folder name). 
#     # Customize this to organize your tasks under a specific folder in Task Scheduler.

#     TaskName             = "AADM Get OneDrive Sync Util Status" # The name of the task. 
#     # Customize it based on what the task does (e.g., "BackupUserFiles").

#     TaskDescription      = "Get current OneDrive Sync Status and write to event log"  # A short description of what the task does. 
#     # Helpful for future reference when viewing tasks in Task Scheduler.

#     ### Script Details (PowerShell or Other Script) ###
#     ScriptDirectory      = "C:\ProgramData\AADMigration\Scripts"  # The directory where the PowerShell script is located. 
#     # Customize this to point to where your script is stored.
    
#     ScriptName           = "Check-ODSyncUtilStatus.Task.ps1" # The name of the PowerShell script to run. 
#     # This should match the file name of your PowerShell script.

#     # TaskArguments        = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -file `"{ScriptPath}`""  
#     # Arguments to pass when running the PowerShell script.
#     # Typically, you want to leave this as-is for most use cases, but you can customize the arguments 
#     # if you need to pass additional options to the script (e.g., different execution policies, paths, etc.).

#     # PowerShellPath       = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"  
#     # Path to the PowerShell executable. 
#     # Leave this as the default PowerShell path unless you want to use a custom PowerShell version or path.

#     ### Task Trigger (When to Run the Task) ###
#     AtLogOn              = $true  # Triggers the task to run when the user logs on. 
#     # Set this to `$true` if you want the task to run at user logon. 
#     # If you want to schedule it for another trigger (like daily or weekly), you can change this.

#     ### Task Principal (Who the Task Runs As) ###
#     # UseCurrentUser         = $true  # Uncomment this if you want the task to run as the current logged-in user. 
#     # This is useful if the task needs user-level permissions. 
#     # Leave this commented out if you're specifying a group or user in TaskPrincipalGroupId.
    
#     TaskPrincipalGroupId = "BUILTIN\Users"  # Specify the user group under which the task will run.
#     # Use this if you want the task to run under a specific group (e.g., "Administrators" or "Users").
#     # Leave this as is if you don’t need to specify a custom group and are using UseCurrentUser.

#     ### VBS Hidden Execution (Optional) ###
#     HideWithVBS          = $true  # Set to `$true` if you want the task to run using a hidden VBScript (prevents a visible PowerShell window).
#     # Leave this as `$false` if you don't need the task to run invisibly or hidden.

#     VbsFileName          = "run-ps-hidden.vbs"  # The name of the VBScript file that will be created if `HideWithVBS` is enabled. 
#     # You can customize this name if needed, but the default should work for most cases.
    
#     ### Task Repetition (Optional) ###
#     # EnableRepetition       = $true  # Uncomment this if you want the task to repeat at regular intervals (e.g., every 30 minutes).
#     # Leave it commented out if you don't need the task to repeat.

#     # TaskRepetitionDuration = "P1D"  # The total duration for which the task should repeat (e.g., "P1D" for 1 day).
#     # Only relevant if `EnableRepetition` is set to `$true`. You can customize this based on your needs.

#     # TaskRepetitionInterval = "PT30M"  # The interval between repetitions (e.g., "PT30M" for 30 minutes).
#     # Only relevant if `EnableRepetition` is set to `$true`. Customize it for different intervals (e.g., "PT1H" for hourly).

# }

# # Execute the utility function to create the scheduled task using the parameters defined above
# New-ScheduledTaskUtility @NewScheduledTaskUtilityTaskParams




$NewScheduledTaskUtilityTaskParams = @{
    ### General Task Settings ###
    TaskPath             = "AAD Migration"
    TaskName             = "AADM Get OneDrive Sync Util Status"
    TaskDescription      = "Get current OneDrive Sync Status and write to event log"

    ### Script Details ###
    ScriptDirectory      = "C:\ProgramData\AADMigration\Scripts"
    ScriptName           = "Check-ODSyncUtilStatus.Task.ps1"

    ### Task Trigger ###
    AtLogOn              = $true

    ### Task Principal ###
    TaskPrincipalGroupId = "BUILTIN\Users"

    ### VBS Hidden Execution ###
    HideWithVBS          = $true
    VbsFileName          = "run-ps-hidden.vbs"
}

# Execute the utility function to create the scheduled task using the parameters defined above
New-ScheduledTaskUtility @NewScheduledTaskUtilityTaskParams



Wait-Debugger

















$NewScheduledTaskUtilityTaskParams = @{
    
    ### General Task Settings ###
    TaskPath             = "AAD Migration"  # The path to the task in the Task Scheduler (like a folder name). 
    # Customize this to organize your tasks under a specific folder in Task Scheduler.

    TaskName             = "User File Backup to OneDrive"  # The name of the task. 
    # Customize it based on what the task does (e.g., "BackupUserFiles").

    TaskDescription      = "User File Backup to OneDrive"  # A short description of what the task does. 
    # Helpful for future reference when viewing tasks in Task Scheduler.

    ### Script Details (PowerShell or Other Script) ###
    ScriptDirectory      = "C:\ProgramData\AADMigration\Scripts"  # The directory where the PowerShell script is located. 
    # Customize this to point to where your script is stored.
    
    ScriptName           = "BackupUserFiles.Task.ps1"  # The name of the PowerShell script to run. 
    # This should match the file name of your PowerShell script.

    TaskArguments        = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -file `"{ScriptPath}`""  
    # Arguments to pass when running the PowerShell script.
    # Typically, you want to leave this as-is for most use cases, but you can customize the arguments 
    # if you need to pass additional options to the script (e.g., different execution policies, paths, etc.).

    PowerShellPath       = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"  
    # Path to the PowerShell executable. 
    # Leave this as the default PowerShell path unless you want to use a custom PowerShell version or path.

    ### Task Trigger (When to Run the Task) ###
    AtLogOn              = $true  # Triggers the task to run when the user logs on. 
    # Set this to `$true` if you want the task to run at user logon. 
    # If you want to schedule it for another trigger (like daily or weekly), you can change this.

    ### Task Principal (Who the Task Runs As) ###
    # UseCurrentUser         = $true  # Uncomment this if you want the task to run as the current logged-in user. 
    # This is useful if the task needs user-level permissions. 
    # Leave this commented out if you're specifying a group or user in TaskPrincipalGroupId.
    
    TaskPrincipalGroupId = "BUILTIN\Users"  # Specify the user group under which the task will run.
    # Use this if you want the task to run under a specific group (e.g., "Administrators" or "Users").
    # Leave this as is if you don’t need to specify a custom group and are using UseCurrentUser.

    ### VBS Hidden Execution (Optional) ###
    HideWithVBS          = $true  # Set to `$true` if you want the task to run using a hidden VBScript (prevents a visible PowerShell window).
    # Leave this as `$false` if you don't need the task to run invisibly or hidden.

    VbsFileName          = "run-ps-hidden.vbs"  # The name of the VBScript file that will be created if `HideWithVBS` is enabled. 
    # You can customize this name if needed, but the default should work for most cases.
    
    ### Task Repetition (Optional) ###
    # EnableRepetition       = $true  # Uncomment this if you want the task to repeat at regular intervals (e.g., every 30 minutes).
    # Leave it commented out if you don't need the task to repeat.

    # TaskRepetitionDuration = "P1D"  # The total duration for which the task should repeat (e.g., "P1D" for 1 day).
    # Only relevant if `EnableRepetition` is set to `$true`. You can customize this based on your needs.

    # TaskRepetitionInterval = "PT30M"  # The interval between repetitions (e.g., "PT30M" for 30 minutes).
    # Only relevant if `EnableRepetition` is set to `$true`. Customize it for different intervals (e.g., "PT1H" for hourly).

}

# Execute the utility function to create the scheduled task using the parameters defined above
# New-ScheduledTaskUtility @NewScheduledTaskUtilityTaskParams



# $CreateOneDriveSyncUtilStatusTaskParams = @{
#     TaskPath             = "AAD Migration"
#     TaskName             = "AADM Get OneDrive Sync Util Status"
#     ScriptDirectory      = "C:\ProgramData\AADMigration\Scripts"
#     ScriptName           = "Check-ODSyncUtilStatus.Task.ps1"
#     TaskArguments        = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -file `"{ScriptPath}`""
#     # TaskRepetitionDuration = "P1D"
#     # TaskRepetitionInterval = "PT30M"
#     PowerShellPath       = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
#     TaskDescription      = "Get current OneDrive Sync Status and write to event log"
#     AtLogOn              = $true
#     # UseCurrentUser         = $true
#     TaskPrincipalGroupId = "BUILTIN\Users"
#     HideWithVBS          = $true
#     # EnableRepetition       = $true
#     VbsFileName          = "run-ps-hidden.vbs"  # Optional: Custom VBS file name
# }

# Create-OneDriveSyncUtilStatusTask @CreateOneDriveSyncUtilStatusTaskParams




# $CreateOneDriveSyncUtilStatusTask = @{
#     TaskPath               = "AAD Migration"
#     TaskName               = "AADM Get OneDrive Sync Util Status"
#     ScriptDirectory        = "C:\ProgramData\AADMigration\Scripts"
#     ScriptName             = "Check-ODSyncUtilStatus.Task.ps1"
#     TaskArguments          = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -file `"{ScriptPath}`""
#     TaskRepetitionDuration = "P1D"
#     TaskRepetitionInterval = "PT30M"
#     PowerShellPath         = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
#     TaskDescription        = "Get current OneDrive Sync Status and write to event log"
#     AtLogOn                = $true
#     UseCurrentUser         = $true  # Specify to use the current user
#     HideWithVBS            = $true  # Optional: Hide with VBS
#     VbsFileName            = "run-ps-hidden.vbs"  # Optional: Custom VBS file name
# }

# Create-OneDriveSyncUtilStatusTask @CreateOneDriveSyncUtilStatusTask







# $CreateOneDriveSyncUtilStatusTask = @{
#     TaskPath               = "AAD Migration"
#     TaskName               = "AADM Get OneDrive Sync Status"
#     ScriptDirectory        = "C:\ProgramData\AADMigration\Scripts"
#     ScriptName             = "Check-OneDriveSyncStatus.ps1"
#     TaskArguments          = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -file `"{ScriptPath}`""
#     TaskRepetitionDuration = "P1D"
#     TaskRepetitionInterval = "PT30M"
#     PowerShellPath         = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
#     TaskDescription        = "Get current OneDrive Sync Status and write to event log"
#     AtLogOn                = $true
#     UseCurrentUser         = $true  # Specify to use the current user
# }

# Create-OneDriveSyncUtilStatusTask @CreateOneDriveSyncUtilStatusTask