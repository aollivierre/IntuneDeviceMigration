function Create-OneDriveSyncUtilStatusTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TaskPath,
        [Parameter(Mandatory = $true)]
        [string]$TaskName,
        [Parameter(Mandatory = $true)]
        [string]$ScriptDirectory,
        [Parameter(Mandatory = $true)]
        [string]$ScriptName,
        [Parameter(Mandatory = $true)]
        [string]$TaskArguments,
        [Parameter(Mandatory = $true)]
        [string]$TaskRepetitionDuration,
        [Parameter(Mandatory = $true)]
        [string]$TaskRepetitionInterval,
        [Parameter(Mandatory = $true)]
        [string]$TaskPrincipalGroupId,
        [Parameter(Mandatory = $true)]
        [string]$PowerShellPath,
        [Parameter(Mandatory = $true)]
        [string]$TaskDescription
    )

    Begin {
        Write-EnhancedLog -Message "Starting Create-OneDriveSyncUtilStatusTask function" -Level "Notice"
        Log-Params -Params @{
            TaskPath               = $TaskPath
            TaskName               = $TaskName
            ScriptDirectory        = $ScriptDirectory
            ScriptName             = $ScriptName
            TaskArguments          = $TaskArguments
            TaskRepetitionDuration = $TaskRepetitionDuration
            TaskRepetitionInterval = $TaskRepetitionInterval
            TaskPrincipalGroupId   = $TaskPrincipalGroupId
            PowerShellPath         = $PowerShellPath
            TaskDescription        = $TaskDescription
        }
    }

    Process {
        try {
            $arguments = $TaskArguments.Replace("{ScriptPath}", "$ScriptDirectory\$ScriptName")

            $actionParams = @{
                Execute = $PowerShellPath
                Argument = $arguments
            }
            $action = New-ScheduledTaskAction @actionParams

            $triggerParams = @{
                AtLogOn = $true
            }
            $trigger = New-ScheduledTaskTrigger @triggerParams

            $principalParams = @{
                GroupId = $TaskPrincipalGroupId
            }
            $principal = New-ScheduledTaskPrincipal @principalParams

            $registerTaskParams = @{
                Principal = $principal
                Action = $action
                Trigger = $trigger
                TaskName = $TaskName
                Description = $TaskDescription
                TaskPath = $TaskPath
            }
            $Task = Register-ScheduledTask @registerTaskParams

            $Task.Triggers.Repetition.Duration = $TaskRepetitionDuration
            $Task.Triggers.Repetition.Interval = $TaskRepetitionInterval
            $Task | Set-ScheduledTask
        }
        catch {
            Write-EnhancedLog -Message "An error occurred while creating the OneDrive sync status task: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Create-OneDriveSyncUtilStatusTask function" -Level "Notice"
    }
}

# # Example usage with splatting
$CreateOneDriveSyncUtilStatusTask = @{
    TaskPath                = "AAD Migration"
    TaskName                = "AADM Get OneDrive Sync Status"
    ScriptDirectory         = "C:\ProgramData\AADMigration\Scripts"
    ScriptName              = "Check-OneDriveSyncStatus.ps1"
    TaskArguments           = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -file `"{ScriptPath}`""
    TaskRepetitionDuration  = "P1D"
    TaskRepetitionInterval  = "PT30M"
    TaskPrincipalGroupId    = "BUILTIN\Users"
    PowerShellPath          = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    TaskDescription         = "Get current OneDrive Sync Status and write to event log"
}

Create-OneDriveSyncUtilStatusTask @CreateOneDriveSyncStatusTaskParams
