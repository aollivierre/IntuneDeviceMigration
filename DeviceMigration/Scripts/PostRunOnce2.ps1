
# function PostRunOnce2 {
#     <#
#     .SYNOPSIS
#     Executes post-run operations for the second phase of the migration process.

#     .DESCRIPTION
#     The PostRunOnce2 function blocks user input, displays a migration in progress form, creates a scheduled task for post-migration cleanup, escrows the BitLocker recovery key, sets various registry values, and restarts the computer.

#     .PARAMETER ImagePath
#     The path to the image file to be displayed on the migration progress form.

#     .PARAMETER TaskPath
#     The path of the task in Task Scheduler.

#     .PARAMETER TaskName
#     The name of the scheduled task.

#     .PARAMETER ScriptPath
#     The path to the PowerShell script to be executed by the scheduled task.

#     .PARAMETER BitlockerDrives
#     An array of drive letters for the BitLocker protected drives.

#     .PARAMETER RegistrySettings
#     A hashtable of registry settings to be applied.

#     .EXAMPLE
#     $params = @{
#         ImagePath = "C:\ProgramData\AADMigration\Files\MigrationInProgress.bmp"
#         TaskPath = "AAD Migration"
#         TaskName = "Run Post-migration cleanup"
#         ScriptPath = "C:\ProgramData\AADMigration\Scripts\PostRunOnce3.ps1"
#         BitlockerDrives = @("C:", "D:")
#         RegistrySettings = @{
#             "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" = @{
#                 "AutoAdminLogon" = @{
#                     "Type" = "DWORD"
#                     "Data" = "0"
#                 }
#             }
#             "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" = @{
#                 "dontdisplaylastusername" = @{
#                     "Type" = "DWORD"
#                     "Data" = "1"
#                 }
#                 "legalnoticecaption" = @{
#                     "Type" = "String"
#                     "Data" = "Migration Completed"
#                 }
#                 "legalnoticetext" = @{
#                     "Type" = "String"
#                     "Data" = "This PC has been migrated to Azure Active Directory. Please log in to Windows using your email address and password."
#                 }
#             }
#         }
#     }
#     PostRunOnce2 @params
#     Executes the post-run operations.
#     #>

#     [CmdletBinding()]
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$ImagePath,

#         [Parameter(Mandatory = $true)]
#         [string]$TaskPath,

#         [Parameter(Mandatory = $true)]
#         [string]$TaskName,

#         [Parameter(Mandatory = $true)]
#         [string]$ScriptPath,

#         [Parameter(Mandatory = $true)]
#         [string[]]$BitlockerDrives,

#         [Parameter(Mandatory = $true)]
#         [hashtable]$RegistrySettings
#     )

#     Begin {
#         Write-EnhancedLog -Message "Starting PostRunOnce2 function" -Level "Notice"
#         Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
#     }

#     Process {
#         try {
#             # Start-Transcript -Path "C:\ProgramData\AADMigration\Logs\AD2AADJ-R2.txt" -Append -Verbose

#             # Block user input
#             $blockParams = @{
#                 Block = $true
#             }
#             Block-UserInput @blockParams

#             # Show migration in progress form
#             $formParams = @{
#                 ImagePath = $ImagePath
#             }
#             Show-MigrationInProgressForm @formParams

#             # Create scheduled task for post-migration cleanup
#             $taskParams = @{
#                 TaskPath   = $TaskPath
#                 TaskName   = $TaskName
#                 ScriptPath = $ScriptPath
#             }
#             Create-ScheduledTask @taskParams

#             # $schedulerconfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config.psd1"
#             # $taskParams = @{
#             #     ConfigPath = $schedulerconfigPath
#             #     FileName   = "run-ps-hidden.vbs"
#             #     Scriptroot = $PSScriptRoot
#             # }

#             # CreateAndExecuteScheduledTask @taskParams


#             # Escrow BitLocker recovery key for each drive
#             foreach ($drive in $BitlockerDrives) {
#                 $escrowParams = @{
#                     DriveLetter = $drive
#                 }
#                 Escrow-BitLockerKey @escrowParams
#             }

#             # Set registry values
#             foreach ($regPath in $RegistrySettings.Keys) {
#                 foreach ($regName in $RegistrySettings[$regPath].Keys) {
#                     $regSetting = $RegistrySettings[$regPath][$regName]
#                     $regParams = @{
#                         RegKeyPath = $regPath
#                         RegValName = $regName
#                         RegValType = $regSetting["Type"]
#                         RegValData = $regSetting["Data"]
#                     }
#                     Set-RegistryValue @regParams
#                 }
#             }

#             # Stop-Transcript

#             # Unblock user input and close form
#             Block-UserInput -Block $false

#             Restart-Computer
#         }
#         catch {
#             Write-EnhancedLog -Message "An error occurred in PostRunOnce2 function: $($_.Exception.Message)" -Level "ERROR"
#             Handle-Error -ErrorRecord $_
#         }
#     }

#     End {
#         Write-EnhancedLog -Message "Exiting PostRunOnce2 function" -Level "Notice"
#     }
# }

# Example usage
$PostRunOnce2Params = @{
    ImagePath = "C:\ProgramData\AADMigration\Files\MigrationInProgress.bmp"
    TaskPath = "AAD Migration"
    TaskName = "Run Post-migration cleanup"
    ScriptPath = "C:\ProgramData\AADMigration\Scripts\PostRunOnce3.ps1"
    BitlockerDrives = @("C:", "D:")
    RegistrySettings = @{
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" = @{
            "AutoAdminLogon" = @{
                "Type" = "DWORD"
                "Data" = "0"
            }
        }
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" = @{
            "dontdisplaylastusername" = @{
                "Type" = "DWORD"
                "Data" = "1"
            }
            "legalnoticecaption" = @{
                "Type" = "String"
                "Data" = "Migration Completed"
            }
            "legalnoticetext" = @{
                "Type" = "String"
                "Data" = "This PC has been migrated to Azure Active Directory. Please log in to Windows using your email address and password."
            }
        }
    }
}
PostRunOnce2 @PostRunOnce2Params