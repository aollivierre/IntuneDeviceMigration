$TaskName = "PR4B-AADM Launch PSADT for Interactive Migration"
$TaskPath = "AAD Migration"
$TaskTriggerType = "AtLogOn"
$TaskRepetitionDuration = "P1D"
$TaskRepetitionInterval = "PT15M"
$TaskPrincipalUserId = "NT AUTHORITY\SYSTEM"
$TaskRunLevel = "Highest"
$TaskDescription = "AADM Launch PSADT for Interactive Migration Version 1.0"
$ServiceUIPath = "C:\ProgramData\AADMigration\ServiceUI.exe"
$ToolkitExecutablePath = "C:\ProgramData\AADMigration\PSAppDeployToolkit\Toolkit\Deploy-Application.exe"
$ProcessName = "explorer.exe"
$DeploymentType = "install"
$DeployMode = "Interactive"
$Delay = "PT2H"

# Unregister the task if it exists
Unregister-ScheduledTaskWithLogging -TaskName $TaskName

# Define the arguments for ServiceUI.exe
$argList = "-process:$ProcessName `"$ToolkitExecutablePath`" -DeploymentType $DeploymentType -DeployMode $DeployMode"
Write-EnhancedLog -Message "ServiceUI arguments: $argList" -Level "INFO"

# Create the scheduled task action
$actionParams = @{
    Execute  = $ServiceUIPath
    Argument = $argList
}
$action = New-ScheduledTaskAction @actionParams

# Create the scheduled task trigger
$triggerParams = @{
    $TaskTriggerType = $true
}
$trigger = New-ScheduledTaskTrigger @triggerParams

# Create the scheduled task principal
$principalParams = @{
    UserId   = $TaskPrincipalUserId
    RunLevel = $TaskRunLevel
}
$principal = New-ScheduledTaskPrincipal @principalParams

# Register the scheduled task
$registerTaskParams = @{
    Principal   = $principal
    Action      = $action
    Trigger     = $trigger
    TaskName    = $TaskName
    Description = $TaskDescription
    TaskPath    = $TaskPath
}
$Task = Register-ScheduledTask @registerTaskParams

# Set repetition properties
$Task.Triggers.Repetition.Duration = $TaskRepetitionDuration
$Task.Triggers.Repetition.Interval = $TaskRepetitionInterval
$Task | Set-ScheduledTask

Write-EnhancedLog -Message "Initial task created. Now setting the delay..." -Level "INFO"





$ShedService = New-Object -ComObject 'Schedule.Service'
$ShedService.Connect()
$taskFolder = $ShedService.GetFolder("\$TaskPath")
$Task = $taskFolder.GetTask("$TaskName")

$Task.Definition.Triggers[0].Delay = $Delay

$taskFolder.RegisterTaskDefinition(
    "$TaskName",
    $Task.Definition,
    6,  # Task registration flags, typically set to 6 for update existing task
    $null,
    $null,
    3   # Task logon type, typically 3 for the SYSTEM account
)

Write-EnhancedLog -Message "Delay of $Delay set for task $TaskName" -Level "INFO"