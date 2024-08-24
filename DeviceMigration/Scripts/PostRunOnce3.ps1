$jobName = "AAD Migration"
# Start the script with error handling
try {
    # Generate the transcript file path
    # $transcriptPath = Get-TranscriptFilePath -Jobname $jobName

    $GetTranscriptFilePathParams = @{
        TranscriptsPath = "C:\Logs\Transcript"
        JobName         = $jobName
    }
    $transcriptPath = Get-TranscriptFilePath @GetTranscriptFilePathParams
    

    # Start the transcript
    Write-Host "Starting transcript at: $transcriptPath" -ForegroundColor Cyan
    Start-Transcript -Path $transcriptPath

    # Example script logic
    Write-Host "This is an example action being logged."

}
catch {
    Write-Host "An error occurred during script execution: $_" -ForegroundColor Red
} 


# function PostRunOnce3 {
#   <#
#   .SYNOPSIS
#   Executes post-run operations for the third phase of the migration process.

#   .DESCRIPTION
#   The PostRunOnce3 function performs cleanup tasks after migration, including removing temporary user accounts, disabling local user accounts, removing scheduled tasks, clearing OneDrive cache, and setting registry values.

#   .PARAMETER TempUser
#   The name of the temporary user account to be removed.

#   .PARAMETER RegistrySettings
#   A hashtable of registry settings to be applied.

#   .PARAMETER MigrationDirectories
#   An array of directories to be removed as part of migration cleanup.

#   .EXAMPLE
#   $params = @{
#       TempUser = "TempUser"
#       RegistrySettings = @{
#           "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" = @{
#               "dontdisplaylastusername" = @{
#                   "Type" = "DWORD"
#                   "Data" = "0"
#               }
#               "legalnoticecaption" = @{
#                   "Type" = "String"
#                   "Data" = $null
#               }
#               "legalnoticetext" = @{
#                   "Type" = "String"
#                   "Data" = $null
#               }
#           }
#           "HKLM:\Software\Policies\Microsoft\Windows\Personalization" = @{
#               "NoLockScreen" = @{
#                   "Type" = "DWORD"
#                   "Data" = "0"
#               }
#           }
#       }
#       MigrationDirectories = @(
#           "C:\ProgramData\AADMigration\Files",
#           "C:\ProgramData\AADMigration\Scripts",
#           "C:\ProgramData\AADMigration\Toolkit"
#       )
#   }
#   PostRunOnce3 @params
#   Executes the post-run operations.
#   #>

#   [CmdletBinding()]
#   param (
#       [Parameter(Mandatory = $true)]
#       [string]$TempUser,

#       [Parameter(Mandatory = $true)]
#       [hashtable]$RegistrySettings,

#       [Parameter(Mandatory = $true)]
#       [string[]]$MigrationDirectories
#   )

#   Begin {
#       Write-EnhancedLog -Message "Starting PostRunOnce3 function" -Level "Notice"
#       Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
#   }

#   Process {
#       try {
#           Start-Transcript -Path "C:\ProgramData\AADMigration\Logs\AD2AADJ-R3.txt" -Append -Force

#           # Remove temporary user account
#           $removeUserParams = @{
#               UserName = $TempUser
#           }
#           Remove-LocalUserAccount @removeUserParams

#           # Disable local user accounts
#           Disable-LocalUserAccounts

#           # Set registry values
#           foreach ($regPath in $RegistrySettings.Keys) {
#               foreach ($regName in $RegistrySettings[$regPath].Keys) {
#                   $regSetting = $RegistrySettings[$regPath][$regName]
#                   $regParams = @{
#                       RegKeyPath = $regPath
#                       RegValName = $regName
#                       RegValType = $regSetting["Type"]
#                       RegValData = $regSetting["Data"]
#                   }
#                   Set-RegistryValue @regParams
#               }
#           }

#           # Remove scheduled tasks
#           $taskParams = @{
#               TaskPath = "AAD Migration"
#           }
#           Remove-ScheduledTasks @taskParams

#           # Remove migration files
#           $removeFilesParams = @{
#               Directories = $MigrationDirectories
#           }
#           Remove-MigrationFiles @removeFilesParams

#           # Clear OneDrive cache
#           Clear-OneDriveCache

#           Stop-Transcript
#       }
#       catch {
#           Write-EnhancedLog -Message "An error occurred in PostRunOnce3 function: $($_.Exception.Message)" -Level "ERROR"
#           Handle-Error -ErrorRecord $_
#       }
#   }

#   End {
#       Write-EnhancedLog -Message "Exiting PostRunOnce3 function" -Level "Notice"
#   }
# }

# Example usage
$PostRunOnce3params = @{
  TempUser = "TempUser"
  RegistrySettings = @{
      "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" = @{
          "dontdisplaylastusername" = @{
              "Type" = "DWORD"
              "Data" = "0"
          }
          "legalnoticecaption" = @{
              "Type" = "String"
              "Data" = $null
          }
          "legalnoticetext" = @{
              "Type" = "String"
              "Data" = $null
          }
      }
      "HKLM:\Software\Policies\Microsoft\Windows\Personalization" = @{
          "NoLockScreen" = @{
              "Type" = "DWORD"
              "Data" = "0"
          }
      }
  }
  MigrationDirectories = @(
      "C:\ProgramData\AADMigration\Files",
      "C:\ProgramData\AADMigration\Scripts",
      "C:\ProgramData\AADMigration\Toolkit"
  )
}
PostRunOnce3 @PostRunOnce3params

Stop-Transcript