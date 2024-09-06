# iex ((irm "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1") -replace '\$Mode = "dev"', '$Mode = "dev"')

function CreateAndRegisterScheduledTask {
    <#
    .SYNOPSIS
    Creates and registers a scheduled task based on the provided configuration, and executes it if necessary.

    .DESCRIPTION
    This function initializes variables, ensures necessary paths exist, copies files, creates a VBScript for hidden execution, and manages the execution of detection and remediation scripts. If the task does not exist, it sets up a new task environment and registers it.

    .PARAMETER ConfigPath
    The path to the JSON configuration file.

    .PARAMETER FileName
    The name of the file to be used for the VBScript.

    .PARAMETER Scriptroot
    The root directory where the scripts are located.

    .EXAMPLE
    CreateAndRegisterScheduledTask -ConfigPath "C:\Tasks\Config.json" -FileName "HiddenScript.vbs"

    This example creates and registers a scheduled task based on the provided configuration file and VBScript file name.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath,

        [Parameter(Mandatory = $true)]
        [string]$FileName,

        [Parameter(Mandatory = $true)]
        [string]$Scriptroot
    )

    begin {
        Write-EnhancedLog -Message 'Starting CreateAndRegisterScheduledTask function' -Level 'NOTICE'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            # Load configuration from PSD1 file
            $config = Import-PowerShellDataFile -Path $ConfigPath

            # Initialize variables directly from the config
            $PackageName = $config.PackageName
            $PackageUniqueGUID = $config.PackageUniqueGUID
            $Version = $config.Version
            $ScriptMode = $config.ScriptMode
            $PackageExecutionContext = $config.PackageExecutionContext
            $RepetitionInterval = $config.RepetitionInterval
            $DataFolder = $config.DataFolder

            # Determine local path based on execution context if not provided
            if (-not $Path_local) {
                if (Test-RunningAsSystem) {
                    Write-EnhancedLog -Message "Detected SYSTEM context. Setting Path_local to $($config.PathLocalSystem)" -Level "CRITICAL"
                    $Path_local = $config.PathLocalSystem
                }
                else {
                    Write-EnhancedLog -Message "Not running as SYSTEM. Setting Path_local to $($config.PathLocalUser)" -Level "CRITICAL"
                    $Path_local = $config.PathLocalUser
                }
            }
            else {
                Write-EnhancedLog -Message "Path_local is already set to $Path_local" -Level "INFO"
            }
            

            $Path_PR = Join-Path -Path $Path_local -ChildPath "Data\$PackageName-$PackageUniqueGUID"
            $schtaskName = [string]::Format($config.TaskNameFormat, $PackageName, $PackageUniqueGUID)
            $schtaskDescription = [string]::Format($config.TaskDescriptionFormat, $Version)


            # Ensure script paths exist
            if (-not (Test-Path -Path $Path_local)) {
                New-Item -Path $Path_local -ItemType Directory -Force | Out-Null
                Write-EnhancedLog -Message "Created directory: $Path_local" -Level "CRITICAL"
            }

            if (-not (Test-Path -Path $Path_PR)) {
                New-Item -Path $Path_PR -ItemType Directory -Force | Out-Null
                Write-EnhancedLog -Message "Created directory: $Path_PR" -Level "CRITICAL"
            }

            # Copy files to path
            $CopyFilesToPathParams = @{
                SourcePath      = $Scriptroot
                DestinationPath = $Path_PR
            }
            Copy-FilesToPath @CopyFilesToPathParams

            # Verify copy operation
            $VerifyCopyOperationParams = @{
                SourcePath      = $Scriptroot
                DestinationPath = $Path_PR
            }
            Verify-CopyOperation @VerifyCopyOperationParams

            # Ensure the script runs with administrative privileges
            CheckAndElevate -ElevateIfNotAdmin $true   

            # Ensure the Data folder exists
            $DataFolderPath = Join-Path -Path $Path_local -ChildPath $DataFolder
            if (-not (Test-Path -Path $DataFolderPath -PathType Container)) {
                New-Item -ItemType Directory -Path $DataFolderPath -Force | Out-Null
                Write-EnhancedLog -Message "Data folder created at $DataFolderPath" -Level "INFO"
            }

            # Create the VBScript to run PowerShell script hidden
            try {
                $CreateVBShiddenPSParams = @{
                    Path_local = $Path_local
                    DataFolder = $DataFolder
                    FileName   = $FileName
                }
                $Path_VBShiddenPS = Create-VBShiddenPS @CreateVBShiddenPSParams

                # Validation of the VBScript file creation
                if (Test-Path -Path $Path_VBShiddenPS) {
                    Write-EnhancedLog -Message "Validation successful: VBScript file exists at $Path_VBShiddenPS" -Level "INFO"
                }
                else {
                    Write-EnhancedLog -Message "Validation failed: VBScript file does not exist at $Path_VBShiddenPS. Check script execution and permissions." -Level "WARNING"
                }
            }
            catch {
                Write-EnhancedLog -Message "An error occurred while creating VBScript: $_" -Level "ERROR"
            }

            # Check if the task exists and execute or create it accordingly
            $checkTaskParams = @{
                taskName = $schtaskName
            }

            $taskExists = Check-ExistingTask @checkTaskParams

            if ($taskExists) {
                Write-EnhancedLog -Message "Existing task found. Executing detection and remediation scripts." -Level "INFO"
                
                $executeParams = @{
                    Path_PR = $Path_PR
                }

                if ($config.ScheduleOnly -eq $true) {
                    Write-EnhancedLog -Message "Registering task with ScheduleOnly set to $($config.ScheduleOnly)" -Level "INFO"
                }
                else {
                    Write-EnhancedLog -Message "Executing detection and remediation scripts." -Level "INFO"
                    Execute-DetectionAndRemediation @executeParams
                }
            }
            else {
                Write-EnhancedLog -Message "No existing task found. Setting up new task environment." -Level "INFO"

                # Setup new task environment
                $Path_PSscript = switch ($ScriptMode) {
                    "Remediation" { Join-Path $Path_PR $config.ScriptPaths.Remediation }
                    "PackageName" { Join-Path $Path_PR $config.ScriptPaths.PackageName }
                    Default { throw "Invalid ScriptMode: $ScriptMode. Expected 'Remediation' or 'PackageName'." }
                }
                

                # Register the scheduled task
                $startTime = (Get-Date).AddMinutes($config.StartTimeOffsetMinutes).ToString("HH:mm")

                if ($config.UsePSADT) {
                    Write-EnhancedLog -Message "Setting up Schedule Task action for Service UI and PSADT" -Level "INFO"
                
                    # Define the path to the PowerShell Application Deployment Toolkit executable
                    $ToolkitExecutable = Join-Path -Path $Path_PR -ChildPath $config.ToolkitExecutablePath
                    Write-EnhancedLog -Message "ToolkitExecutable set to: $ToolkitExecutable" -Level "INFO"
                
                    # Define the path to the ServiceUI executable
                    $ServiceUIExecutable = Join-Path -Path $Path_PR -ChildPath $config.ServiceUIExecutablePath
                    Write-EnhancedLog -Message "ServiceUIExecutable set to: $ServiceUIExecutable" -Level "INFO"
                
                    # Define the deployment type from the config
                    $DeploymentType = $config.DeploymentType
                    Write-EnhancedLog -Message "DeploymentType set to: $DeploymentType" -Level "INFO"
                
                    # Define the arguments for ServiceUI.exe
                    $argList = "-process:$($config.ProcessName) `"$ToolkitExecutable`" -DeploymentType $DeploymentType"
                    Write-EnhancedLog -Message "ServiceUI arguments: $argList" -Level "CRITICAL"
                
                    # Create the scheduled task action
                    $action = New-ScheduledTaskAction -Execute $ServiceUIExecutable -Argument $argList
                    Write-EnhancedLog -Message "Scheduled Task action $action for Service UI and PSADT created." -Level "INFO"
                }
                else {
                    Write-EnhancedLog -Message "Setting up Scheduled Task action for wscript and VBS" -Level "INFO"
                
                    # Define the arguments for wscript.exe
                    $argList = "`"$Path_VBShiddenPS`" `"$Path_PSscript`""
                    Write-EnhancedLog -Message "wscript arguments: $argList" -Level "INFO"
                
                    # Define the path to wscript.exe from the config
                    $WscriptPath = $config.WscriptPath
                    Write-EnhancedLog -Message "WscriptPath set to: $WscriptPath" -Level "INFO"
                
                    # Create the scheduled task action using the path from the config
                    $action = New-ScheduledTaskAction -Execute $WscriptPath -Argument $argList
                    Write-EnhancedLog -Message "Scheduled Task action for wscript and VBS created." -Level "INFO"
                }
                

                # Define the trigger based on the TriggerType
                $trigger = switch ($config.TriggerType) {
                    "Daily" {
                        Write-EnhancedLog -Message "Trigger set to Daily at $startTime" -Level "INFO"
                        $trigger = New-ScheduledTaskTrigger -Daily -At $startTime

                        # Apply StartBoundary and Delay if provided
                        if ($config.StartBoundary) {
                            $trigger.StartBoundary = $config.StartBoundary
                            Write-EnhancedLog -Message "StartBoundary set to $($config.StartBoundary)" -Level "INFO"
                        }

                        if ($config.Delay) {
                            $trigger.Delay = $config.Delay
                            Write-EnhancedLog -Message "Delay set to $($config.Delay)" -Level "INFO"
                        }
                        $trigger
                    }
                    "Logon" {
                        if (-not $config.LogonUserId) {
                            throw "LogonUserId must be specified for Logon trigger type."
                        }
                        Write-EnhancedLog -Message "Trigger set to logon of user $($config.LogonUserId)" -Level "INFO"
                        $trigger = New-ScheduledTaskTrigger -AtLogOn

                        # Only apply StartBoundary if provided
                        if ($config.StartBoundary) {
                            $trigger.StartBoundary = $config.StartBoundary
                            Write-EnhancedLog -Message "StartBoundary set to $($config.StartBoundary)" -Level "INFO"
                        }
                        $trigger
                    }
                    "AtStartup" {
                        Write-EnhancedLog -Message "Trigger set at startup" -Level "INFO"
                        $trigger = New-ScheduledTaskTrigger -AtStartup

                        # Apply StartBoundary and Delay if provided
                        if ($config.StartBoundary) {
                            $trigger.StartBoundary = $config.StartBoundary
                            Write-EnhancedLog -Message "StartBoundary set to $($config.StartBoundary)" -Level "INFO"
                        }

                        if ($config.Delay) {
                            $trigger.Delay = $config.Delay
                            Write-EnhancedLog -Message "Delay set to $($config.Delay)" -Level "INFO"
                        }
                        $trigger
                    }
                    default {
                        throw "Invalid TriggerType specified in the configuration."
                    }
                }



                $principal = New-ScheduledTaskPrincipal -UserId $config.PrincipalUserId -LogonType $config.LogonType -RunLevel $config.RunLevel

                # Ensure the task path is set, use the default root "\" if not specified
                $taskPath = if ($config.TaskFolderPath) { $config.TaskFolderPath } else { "\" }

                # Create a hashtable for common parameters
                $registerTaskParams = @{
                    TaskName    = $schtaskName
                    Action      = $action
                    Principal   = $principal
                    Description = $schtaskDescription
                    TaskPath    = $taskPath
                    Force       = $true
                }

                # Check if RunOnDemand is true and modify the hashtable accordingly
                if ($config.RunOnDemand -eq $true) {
                    Write-EnhancedLog -Message "Registering task with RunOnDemand set to $($config.RunOnDemand) at path $taskPath" -Level "CRITICAL"
                    # Register the task without a trigger (Run on demand)
                    $task = Register-ScheduledTask @registerTaskParams
                }
                else {
                    Write-EnhancedLog -Message "Registering task with RunOnDemand set to $($config.RunOnDemand) at path $taskPath" -Level "CRITICAL"
                    # Add the Trigger to the hashtable
                    $registerTaskParams.Trigger = $trigger
                    # Register the task with the trigger
                    $task = Register-ScheduledTask @registerTaskParams
                }


                $task = Get-ScheduledTask -TaskName $schtaskName

                if ($config.Repeat -eq $true) {
                    Write-EnhancedLog -Message "Registering task with Repeat set to $($config.Repeat)" -Level "INFO"
                    $task.Triggers[0].Repetition.Interval = $RepetitionInterval
                }

                $task | Set-ScheduledTask
                if ($PackageExecutionContext -eq $config.TaskExecutionContext) {
                    $ShedService = New-Object -ComObject 'Schedule.Service'
                    $ShedService.Connect()
                    $taskFolder = $ShedService.GetFolder($config.TaskFolderPath)
                    $Task = $taskFolder.GetTask("$schtaskName")
                    $taskFolder.RegisterTaskDefinition(
                        "$schtaskName", 
                        $Task.Definition, 
                        $config.TaskRegistrationFlags, 
                        $config.TaskUserGroup, 
                        $null, 
                        $config.TaskLogonType
                    )
                }                

                Write-EnhancedLog -Message "Scheduled task $schtaskName registered successfully." -Level "INFO"
            }
        }
        catch {
            Write-EnhancedLog -Message "An error occurred: $_" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'CreateAndRegisterScheduledTask function completed' -Level 'NOTICE'
    }
}



# CreateAndRegisterScheduledTask -ConfigPath "C:\code\IntuneDeviceMigration\DeviceMigration\config.psd1" -FileName "HiddenScript.vbs"

# # Define the parameters using a hashtable
# $taskParams = @{
#     ConfigPath = "C:\code\IntuneDeviceMigration\DeviceMigration\config.psd1"
#     FileName   = "HiddenScript.vbs"
#     Scriptroot = "$PSScriptroot"
# }

# # Call the function with the splatted parameters
# CreateAndRegisterScheduledTask @taskParams






# ################################################################################################################################
# ############### CALLING AS SYSTEM to simulate Intune deployment as SYSTEM (Uncomment for debugging) ############################
# ################################################################################################################################

# Example usage
$ensureRunningAsSystemParams = @{
    PsExec64Path = Join-Path -Path $PSScriptRoot -ChildPath "private\PsExec64.exe"
    ScriptPath   = $MyInvocation.MyCommand.Path
    TargetFolder = Join-Path -Path $PSScriptRoot -ChildPath "private"
}

Ensure-RunningAsSystem @ensureRunningAsSystemParams



# ################################################################################################################################
# ############### END CALLING AS SYSTEM to simulate Intune deployment as SYSTEM (Uncomment for debugging) ########################
# ################################################################################################################################



# Example usage of Download-And-Install-ServiceUI function with splatting
$DownloadAndInstallServiceUIparams = @{
    TargetFolder           = "$PSScriptRoot"
    DownloadUrl            = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
    MsiFileName            = "MicrosoftDeploymentToolkit_x64.msi"
    InstalledServiceUIPath = "C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\ServiceUI.exe"
}
Download-And-Install-ServiceUI @DownloadAndInstallServiceUIparams


# Example usage
$DownloadPSAppDeployToolkitparams = @{
    GithubRepository     = 'PSAppDeployToolkit/PSAppDeployToolkit'
    FilenamePatternMatch = '*.zip'
    ScriptDirectory      = $PSScriptRoot
}
Download-PSAppDeployToolkit @DownloadPSAppDeployToolkitparams



#right before rebooting we will schedule our install script (which is our script2 or our post-reboot script to run automatically at startup under the SYSTEM account)
# here I need to pass these in the config file (JSON or PSD1) or here in the splat but I need to have it outside of the function


# $schedulerconfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config.psd1"
$schedulerconfigPath = "C:\code\IntuneDeviceMigration\DeviceMigration\Interactive-Migration-Task-config.psd1"
$taskParams = @{
    ConfigPath = $schedulerconfigPath
    FileName   = "run-ps-hidden.vbs"
    Scriptroot = $PSScriptRoot
}

CreateAndRegisterScheduledTask @taskParams


# Yes, there is a difference between `StartBoundary` and `StartTime` in the context of scheduled tasks in PowerShell.

# ### 1. **StartBoundary:**
#    - **Definition:** `StartBoundary` is a property of a `ScheduledTaskTrigger` that defines the earliest time that the trigger can activate. It sets the date and time at which the task is eligible to run for the first time.
#    - **Format:** `StartBoundary` is typically set in an ISO 8601 date and time format, such as `"2024-08-16T12:00:00"`.
#    - **Purpose:** It's used to specify when the task becomes active. It doesn't specify a specific time the task should run every day, but rather when the task is allowed to start running, especially for triggers like `Daily`, `AtLogOn`, or `AtStartup`.
#    - **Example Use Case:** If you want a task to only be eligible to run after a certain date and time, you would set `StartBoundary`.

# ### 2. **StartTime:**
#    - **Definition:** `StartTime` is a property specifically associated with `Daily` or `Weekly` triggers and defines the exact time of day the task should start.
#    - **Format:** `StartTime` is generally a time-only value, like `"09:00:00"`.
#    - **Purpose:** It is used to specify a time of day for tasks that need to run on a recurring schedule (e.g., daily or weekly). It indicates when the task should be triggered every day (or on specified days of the week).
#    - **Example Use Case:** If you want a task to run every day at 9:00 AM, you would set the `StartTime` to `"09:00:00"`.

# ### Practical Differences:
# - **StartBoundary:** Controls when the task becomes eligible to run. It’s a one-time setting that dictates when the task can first start, often used with non-recurring tasks or as a gate for when recurring tasks can start.
# - **StartTime:** Controls the exact time on a daily or weekly basis when the task should be executed. It’s used for recurring tasks that need to start at the same time every day or on specific days of the week.

# ### Example Scenario:
# If you want a task to start running every day at 9:00 AM but only start doing so from September 1, 2024, you would set:
# - `StartBoundary = "2024-09-01T00:00:00"` (the task won’t run before this date).
# - `StartTime = "09:00:00"` (the task will run at 9:00 AM daily after September 1, 2024).

# ### Conclusion:
# - **Use `StartBoundary`** to define when the task becomes eligible to start (based on date and time).
# - **Use `StartTime`** to define the time of day for recurring tasks (daily or weekly schedules).