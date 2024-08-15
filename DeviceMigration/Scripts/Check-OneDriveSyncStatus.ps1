# iex ((irm "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1") -replace '\$Mode = "dev"', '$Mode = "prod"')

function Check-OneDriveSyncStatus {
    [CmdletBinding()]
    param (
        [string]$OneDriveLibPath,
        [string]$Scriptbasepath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Check-OneDriveSyncStatus function" -Level "NOTICE"
        Log-Params -Params @{ OneDriveLibPath = $OneDriveLibPath }

        # Check if running elevated; do not elevate if not
        $isAdmin = CheckAndElevate -ElevateIfNotAdmin $false

        if ($isAdmin) {
            Write-EnhancedLog -Message "Script is running with elevated privileges. Attempting to de-elevate for OneDrive sync status check..." -Level "WARNING"
            
            try {

                try {
                    try {
                        $powerShellPath = Get-PowerShellPath
                        
                        # Temporary file to store the output
                        $tempFile = [System.IO.Path]::GetTempFileName()
                        
                        # Start a non-elevated PowerShell process to run the external script and capture output
                        $startProcessParams = @{
                            FilePath     = $powerShellPath
                            ArgumentList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "$Scriptbasepath\Check-OneDriveSyncStatus-ScriptBlock.ps1", "-OneDriveLibPath", "`"$OneDriveLibPath`"", "> `"$tempFile`" 2>&1")
                            NoNewWindow  = $true
                            Wait         = $true
                        }
                        Start-Process @startProcessParams
                        
                        # Read the output from the temporary file
                        $nonElevatedStatus = Get-Content -Path $tempFile
                        
                        # Clean up the temporary file
                        Remove-Item -Path $tempFile -Force
                        
                        if ($nonElevatedStatus) {
                            Write-EnhancedLog -Message "De-elevated process output: $nonElevatedStatus" -Level "INFO"
                        }
                        else {
                            Write-EnhancedLog -Message "No output was captured from the de-elevated process." -Level "WARNING"
                        }
                        
                        return $nonElevatedStatus
                    
                    }
                    catch {
                        Write-EnhancedLog -Message "Failed to de-elevate and check OneDrive sync status: $($_.Exception.Message)" -Level "ERROR"
                        Handle-Error -ErrorRecord $_
                        throw $_
                    }
                    
                
                }
                catch {
                    Write-EnhancedLog -Message "Failed to de-elevate and check OneDrive sync status: $($_.Exception.Message)" -Level "ERROR"
                    Handle-Error -ErrorRecord $_
                    throw $_
                }
                


            }
            catch {
                Write-EnhancedLog -Message "Failed to de-elevate and check OneDrive sync status: $($_.Exception.Message)" -Level "ERROR"
                Handle-Error -ErrorRecord $_
                throw $_
            }
        }

        # If not elevated, proceed normally
        try {
            if (-not (Test-Path $OneDriveLibPath)) {
                Write-EnhancedLog -Message "The specified OneDriveLib.dll path does not exist: $OneDriveLibPath" -Level "ERROR"
                throw "The specified OneDriveLib.dll path does not exist."
            }

            Import-Module $OneDriveLibPath
            Write-EnhancedLog -Message "Successfully imported OneDriveLib module from $OneDriveLibPath" -Level "INFO"


            Get-ODStatus

            $Status = Get-ODStatus

            if (-not $Status) {
                Write-EnhancedLog -Message "OneDrive is not running or the user is not logged in to OneDrive." -Level "WARNING"
                return
            }

            $Success = @( "Shared", "UpToDate", "Up To Date" )
            $InProgress = @( "SharedSync", "Shared Sync", "Syncing" )
            $Failed = @( "Error", "ReadOnly", "Read Only", "OnDemandOrUnknown", "On Demand or Unknown", "Paused")

            ForEach ($s in $Status) {
                $StatusString = $s.StatusString
                $DisplayName = $s.DisplayName
                $User = $s.UserName

                if ($StatusString -in $Success) {
                    Write-EnhancedLog -Message "OneDrive sync status is healthy: Display Name: $DisplayName, User: $User, Status: $StatusString" -Level "INFO"
                }
                elseif ($StatusString -in $InProgress) {
                    Write-EnhancedLog -Message "OneDrive sync status is currently syncing: Display Name: $DisplayName, User: $User, Status: $StatusString" -Level "INFO"
                }
                elseif ($StatusString -in $Failed) {
                    Write-EnhancedLog -Message "OneDrive sync status is in a known error state: Display Name: $DisplayName, User: $User, Status: $StatusString" -Level "ERROR"
                }
                else {
                    Write-EnhancedLog -Message "Unable to get OneDrive Sync Status for Display Name: $DisplayName, User: $User" -Level "WARNING"
                }
            }
        }
        catch {
            Write-EnhancedLog -Message "An error occurred while checking OneDrive sync status: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Check-OneDriveSyncStatus function" -Level "NOTICE"
    }
}



# Example usage
$params = @{
    OneDriveLibPath = "C:\ProgramData\AADMigration\Files\OneDriveLib.dll"
    Scriptbasepath  = "$PSScriptroot"
}
Check-OneDriveSyncStatus @params