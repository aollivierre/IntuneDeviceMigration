function Remove-ADJoin {
    [CmdletBinding()]
    param (
        [string]$DomainLeaveUser,
        [string]$DomainLeavePassword,
        [string]$TempUser,
        [string]$TempUserPassword
    )

    Begin {
        Write-EnhancedLog -Message "Starting Remove-ADJoin function" -Level "INFO"
        Log-Params -Params @{
            DomainLeaveUser = $DomainLeaveUser;
            DomainLeavePassword = $DomainLeavePassword;
            TempUser = $TempUser;
            TempUserPassword = $TempUserPassword;
        }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking if device is domain joined" -Level "INFO"
            $ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
            $Domain = $ComputerSystem.Domain
            $PartOfDomain = $ComputerSystem.PartOfDomain

            if ($PartOfDomain) {
                Write-EnhancedLog -Message "Computer is domain member, removing domain membership" -Level "INFO"

                if (Test-Connection -ComputerName $Domain -Count 1 -Quiet) {
                    Write-EnhancedLog -Message "Connected to domain, attempting to leave domain." -Level "INFO"

                    if ($DomainLeaveUser) {
                        $SecurePassword = ConvertTo-SecureString -String $DomainLeavePassword -AsPlainText -Force
                        $Credentials = New-Object System.Management.Automation.PSCredential($DomainLeaveUser, $SecurePassword)

                        try {
                            Remove-Computer -ComputerName "localhost" -Credential $Credentials -Verbose -Force -ErrorAction Stop
                            Disable-ScheduledTask -TaskName "AADM Launch PSADT for Interactive Migration"
                            Stop-Transcript
                            Restart-Computer
                        } catch {
                            Write-EnhancedLog -Message "Leaving domain with domain credentials failed. Will leave domain with local account." -Level "ERROR"
                        }
                    }

                    $SecurePassword = ConvertTo-SecureString -String $TempUserPassword -AsPlainText -Force
                    $Credentials = New-Object System.Management.Automation.PSCredential($TempUser, $SecurePassword)
                    $ConnectedAdapters = Get-NetAdapter | Where-Object { $_.MediaConnectionState -eq "Connected" }

                    foreach ($Adapter in $ConnectedAdapters) {
                        Write-EnhancedLog -Message "Disabling network adapter $($Adapter.Name)" -Level "INFO"
                        Disable-NetAdapter -Name $Adapter.Name -Confirm:$false
                    }

                    Start-Sleep -Seconds 5
                    Remove-Computer -ComputerName "localhost" -Credential $Credentials -Verbose -Force

                    foreach ($Adapter in $ConnectedAdapters) {
                        Write-EnhancedLog -Message "Enabling network adapter $($Adapter.Name)" -Level "INFO"
                        Enable-NetAdapter -Name $Adapter.Name -Confirm:$false
                    }

                    Start-Sleep -Seconds 15
                    Write-EnhancedLog -Message "Computer removed from domain. Network adapters re-enabled. Restarting." -Level "INFO"
                    Disable-ScheduledTask -TaskName "AADM Launch PSADT for Interactive Migration"
                    Stop-Transcript
                    Restart-Computer
                } else {
                    Write-Verbose "Removing computer from domain and forcing restart"
                    Write-EnhancedLog -Message "Stopping transcript and calling Remove-Computer with -Restart switch." -Level "INFO"
                    Stop-Transcript
                    Remove-Computer -ComputerName "localhost" -Credential $Credentials -Verbose -Force -ErrorAction Stop
                    Disable-ScheduledTask -TaskName "AADM Launch PSADT for Interactive Migration"
                    Stop-Transcript
                    Restart-Computer
                }
            } else {
                Write-EnhancedLog -Message "Computer is not a domain member, restarting computer." -Level "INFO"
                Disable-ScheduledTask -TaskName "AADM Launch PSADT for Interactive Migration"
                Stop-Transcript
                Restart-Computer
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while removing AD join: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Remove-ADJoin function" -Level "INFO"
    }
}

# Example usage
# Remove-ADJoin -DomainLeaveUser "YourDomainUser" -DomainLeavePassword "YourDomainPassword" -TempUser "YourTempUser" -TempUserPassword "YourTempUserPassword"
