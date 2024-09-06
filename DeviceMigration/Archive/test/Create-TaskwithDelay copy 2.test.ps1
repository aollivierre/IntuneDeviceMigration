function Create-TaskWithDelay {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TaskName,
        
        [Parameter(Mandatory = $true)]
        [string]$TaskPath,
        
        [Parameter(Mandatory = $true)]
        [string]$TaskExecutable,
        
        [Parameter(Mandatory = $true)]
        [string]$TaskArguments = "",
        
        [Parameter(Mandatory = $true)]
        [string]$TaskTriggerType = "AtLogOn",
        
        [Parameter(Mandatory = $true)]
        [string]$TaskDelay = "PT1H",  # ISO 8601 Duration Format
       
        [Parameter(Mandatory = $true)]
        [string]$TaskRepetitionInterval = "PT15M",
        
        [Parameter(Mandatory = $true)]
        [string]$TaskRepetitionDuration = "P1D",
        
        [Parameter(Mandatory = $true)]
        [string]$TaskPrincipalUserId = "NT AUTHORITY\SYSTEM",
        
        [Parameter(Mandatory = $true)]
        [string]$TaskRunLevel = "Highest",
        
        [Parameter(Mandatory = $true)]
        [string]$TaskDescription = "Scheduled Task with Delay"
    )

    Begin {
        Write-Host "Creating Task Trigger"
        $triggerParams = @{
            $TaskTriggerType = $true
        }
        $trigger = New-ScheduledTaskTrigger @triggerParams

        # Modify the Delay property
        $trigger.Delay = $TaskDelay

        Write-Host "Creating Task Action"
        $action = New-ScheduledTaskAction -Execute $TaskExecutable -Argument $TaskArguments

        Write-Host "Creating Task Principal"
        $principalParams = @{
            UserId   = $TaskPrincipalUserId
            RunLevel = $TaskRunLevel
        }
        $principal = New-ScheduledTaskPrincipal @principalParams

        Write-Host "Registering Task"
        $taskParams = @{
            Action      = $action
            Trigger     = $trigger
            Principal   = $principal
            TaskName    = $TaskName
            Description = $TaskDescription
            TaskPath    = $TaskPath
        }
        Register-ScheduledTask @taskParams

        Write-Host "Task Created Successfully with Delay of $TaskDelay"
    }

    Process {}

    End {}
}

# Example Usage:
$TaskParams = @{
    TaskName              = "TestTaskWithDelay"
    TaskPath              = "\TestFolder"
    TaskExecutable        = "notepad.exe"
    TaskArguments         = ""
    TaskTriggerType       = "AtLogOn"
    TaskDelay             = "PT2H"  # 2 hours delay
    TaskRepetitionInterval = "PT15M"
    TaskRepetitionDuration = "P1D"
    TaskPrincipalUserId    = "NT AUTHORITY\SYSTEM"
    TaskRunLevel           = "Highest"
    TaskDescription        = "Test Task with Delay at Logon"
}

Create-TaskWithDelay @TaskParams
