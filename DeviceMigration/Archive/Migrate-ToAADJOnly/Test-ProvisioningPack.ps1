function Test-ProvisioningPack {
    [CmdletBinding()]
    param (
        [string]$PPKGName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Test-ProvisioningPack function" -Level "INFO"
        Log-Params -Params @{ PPKGName = $PPKGName }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Testing to see if provisioning package previously installed" -Level "INFO"
            $PPKGStatus = Get-ProvisioningPackage | Where-Object { $_.PackagePath -like "*$PPKGName*" }
            if ($PPKGStatus) {
                Write-EnhancedLog -Message "Provisioning package previously installed. Removing PPKG." -Level "INFO"
                $PPKGID = $PPKGStatus.PackageID
                Remove-ProvisioningPackage -PackageId $PPKGID
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while testing provisioning pack: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Test-ProvisioningPack function" -Level "INFO"
    }
}

# Example usage
# Test-ProvisioningPack -PPKGName "YourProvisioningPackName"
