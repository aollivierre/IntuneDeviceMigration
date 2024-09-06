function Remove-Hybrid {
    [CmdletBinding()]
    param ()

    Begin {
        Write-EnhancedLog -Message "Starting Remove-Hybrid function" -Level "INFO"
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking if device is Azure AD joined" -Level "INFO"
            $Dsregcmd = New-Object PSObject
            Dsregcmd /status | Where-Object { $_ -match ' : ' } | ForEach-Object {
                $Item = $_.Trim() -split '\s:\s'
                $Dsregcmd | Add-Member -MemberType NoteProperty -Name $($Item[0] -replace '[:\s]', '') -Value $Item[1] -ErrorAction SilentlyContinue
            }

            $AzureADJoined = $Dsregcmd.AzureAdJoined

            if ($AzureADJoined -eq 'Yes') {
                Write-EnhancedLog -Message "Device is Azure AD joined. Removing hybrid join." -Level "INFO"
                & "C:\Windows\System32\dsregcmd.exe" /leave
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while removing hybrid join: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Remove-Hybrid function" -Level "INFO"
    }
}

# Example usage
# Remove-Hybrid
