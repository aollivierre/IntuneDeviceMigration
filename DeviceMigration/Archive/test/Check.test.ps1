<#
.SYNOPSIS
Checks if the device is Azure AD Joined and Intune Enrolled.

.DESCRIPTION
This script verifies if the device is joined to Azure AD and enrolled in Microsoft Intune. It checks specific registry keys and system properties to determine these conditions.

.NOTES
Version:        1.0
Author:         Abdullah Ollivierre
Creation Date:  2024-08-15
#>

# Function to check if the device is Azure AD Joined
function Is-AzureADJoined {
    try {
        $aadStatus = Get-WmiObject -Namespace "root\cimv2\mdm\dmmap" -Class "MDM_DevDetail_Ext01" -ErrorAction Stop
        return @{
            IsAzureADJoined = $null -ne $aadStatus.DeviceId
            AzureADDeviceId = $aadStatus.DeviceId
        }
    } catch {
        return @{IsAzureADJoined = $false}
    }
}

# Function to check if the device is Intune Enrolled
function Is-IntuneEnrolled {
    try {
        $intuneStatus = Get-WmiObject -Namespace "root\cimv2\mdm\dmmap" -Class "MDM_DevDetail" -ErrorAction Stop
        return @{
            IsIntuneEnrolled = $null -ne $intuneStatus.ClientCertificateThumbprint
            IntuneEnrollmentId = $intuneStatus.ClientCertificateThumbprint
        }
    } catch {
        return @{IsIntuneEnrolled = $false}
    }
}

# Main script execution block
$aadCheck = Is-AzureADJoined
$intuneCheck = Is-IntuneEnrolled

if ($aadCheck.IsAzureADJoined -and $intuneCheck.IsIntuneEnrolled) {
    Write-Output "Device is Azure AD Joined and Intune Enrolled."
    Write-Output "Azure AD Device ID: $($aadCheck.AzureADDeviceId)"
    Write-Output "Intune Enrollment ID: $($intuneCheck.IntuneEnrollmentId)"
    exit 0
} else {
    if (-not $aadCheck.IsAzureADJoined) {
        Write-Output "Device is NOT Azure AD Joined."
    }
    if (-not $intuneCheck.IsIntuneEnrolled) {
        Write-Output "Device is NOT Intune Enrolled."
    }
    exit 1
}