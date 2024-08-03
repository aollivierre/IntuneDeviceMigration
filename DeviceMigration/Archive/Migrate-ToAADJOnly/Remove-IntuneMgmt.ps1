function Remove-IntuneMgmt {
    [CmdletBinding()]
    param ()

    Begin {
        Write-EnhancedLog -Message "Starting Remove-IntuneMgmt function" -Level "INFO"
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking Intune enrollment status" -Level "INFO"
            $OMADMPath = "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*"
            $Account = (Get-ItemProperty -Path $OMADMPath -ErrorAction SilentlyContinue).PSChildName

            $Enrolled = $true
            $EnrollmentPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments\$Account"
            $EnrollmentUPN = (Get-ItemProperty -Path $EnrollmentPath -ErrorAction SilentlyContinue).UPN
            $ProviderID = (Get-ItemProperty -Path $EnrollmentPath -ErrorAction SilentlyContinue).ProviderID

            if (-not $EnrollmentUPN -or $ProviderID -ne "MS DM Server") {
                $Enrolled = $false
            }

            if ($Enrolled) {
                Write-EnhancedLog -Message "Device is enrolled in Intune. Proceeding with unenrollment." -Level "INFO"

                # Delete Task Schedule tasks
                Get-ScheduledTask -TaskPath "\Microsoft\Windows\EnterpriseMgmt\$Account\*" | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

                # Delete registry keys
                Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments\$Account" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments\Status\$Account" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$Account" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled\$Account" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\Providers\$Account" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$Account" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Logger\$Account" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions\$Account" -Recurse -Force -ErrorAction SilentlyContinue

                # Delete enrollment certificates
                $UserCerts = Get-ChildItem -Path cert:\CurrentUser -Recurse
                $IntuneCerts = $UserCerts | Where-Object { $_.Issuer -eq "CN=SC_Online_Issuing" }
                foreach ($Cert in $IntuneCerts) {
                    $Cert | Remove-Item -Force
                }
                $DeviceCerts = Get-ChildItem -Path cert:\LocalMachine -Recurse
                $IntuneCerts = $DeviceCerts | Where-Object { $_.Issuer -eq "CN=Microsoft Intune Root Certification Authority" -or $_.Issuer -eq "CN=Microsoft Intune MDM Device CA" }
                foreach ($Cert in $IntuneCerts) {
                    $Cert | Remove-Item -Force -ErrorAction SilentlyContinue
                }

                # Delete Intune Company Portal App
                Get-AppxPackage -AllUsers -Name "Microsoft.CompanyPortal" | Remove-AppxPackage -Confirm:$false
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while removing Intune management: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Remove-IntuneMgmt function" -Level "INFO"
    }
}

# Example usage
# Remove-IntuneMgmt
