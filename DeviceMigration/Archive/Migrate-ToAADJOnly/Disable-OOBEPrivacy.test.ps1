function Disable-OOBEPrivacy {
    [CmdletBinding()]
    param ()

    Begin {
        Write-EnhancedLog -Message "Starting Disable-OOBEPrivacy function" -Level "INFO"
    }

    Process {
        try {
            Write-EnhancedLog -Message "Disabling privacy experience" -Level "INFO"
            $RegistryPath = 'HKLM:\Software\Policies\Microsoft\Windows\OOBE'
            $Name = 'DisablePrivacyExperience'
            $Value = '1'
            if (-not (Test-Path -Path $RegistryPath)) {
                New-Item -Path $RegistryPath -Force | Out-Null
            }
            New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force -Verbose

            Write-EnhancedLog -Message "Disabling first logon animation" -Level "INFO"
            $AnimationRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
            $AnimationName = 'EnableFirstLogonAnimation'
            $AnimationValue = '0'
            if (-not (Test-Path -Path $AnimationRegistryPath)) {
                New-Item -Path $AnimationRegistryPath -Force | Out-Null
            }
            New-ItemProperty -Path $AnimationRegistryPath -Name $AnimationName -Value $AnimationValue -PropertyType DWORD -Force -Verbose

            Write-EnhancedLog -Message "Removing lock screen" -Level "INFO"
            $LockRegPath = "HKLM:\Software\Policies\Microsoft\Windows\Personalization"
            $LockRegName = "NoLockScreen"
            $LockValue = "1"
            if (-not (Test-Path -Path $LockRegPath)) {
                New-Item -Path $LockRegPath -Force | Out-Null
            }
            New-ItemProperty -Path $LockRegPath -Name $LockRegName -Value $LockValue -PropertyType DWORD -Force -Verbose
        } catch {
            Write-EnhancedLog -Message "An error occurred while disabling OOBE privacy: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Disable-OOBEPrivacy function" -Level "INFO"
    }
}

# Example usage
# Disable-OOBEPrivacy
