function Set-Autologin {
    [CmdletBinding()]
    param (
        [string]$TempUser,
        [string]$TempUserPassword
    )

    Begin {
        Write-EnhancedLog -Message "Starting Set-Autologin function" -Level "INFO"
        Log-Params -Params @{ TempUser = $TempUser; TempUserPassword = $TempUserPassword }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Setting user account to Auto Login" -Level "INFO"
            $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
            Set-ItemProperty -Path $RegPath -Name "AutoAdminLogon" -Value "1" -Type String -Verbose
            Set-ItemProperty -Path $RegPath -Name "DefaultUsername" -Value $TempUser -Type String -Verbose
            Set-ItemProperty -Path $RegPath -Name "DefaultPassword" -Value $TempUserPassword -Type String -Verbose
        } catch {
            Write-EnhancedLog -Message "An error occurred while setting autologin: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Set-Autologin function" -Level "INFO"
    }
}

# Example usage
# Set-Autologin -TempUser "YourTempUser" -TempUserPassword "YourTempUserPassword"
