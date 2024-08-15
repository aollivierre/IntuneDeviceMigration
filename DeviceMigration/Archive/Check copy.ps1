<#
.SYNOPSIS
Checks if the device is Azure AD Joined and Intune Enrolled using dsregcmd.

.DESCRIPTION
This script runs the dsregcmd /status command and parses its output to verify if the device is joined to Azure AD and enrolled in Microsoft Intune.

.NOTES
Version:        1.0
Author:         Abdullah Ollivierre
Creation Date:  2024-08-15
#>

# Function to parse dsregcmd /status output
function Get-DSRegStatus {
    $dsregcmdOutput = dsregcmd /status

    # Parse AzureADJoined status
    $isAzureADJoined = $dsregcmdOutput -match '.*AzureAdJoined\s*:\s*YES'
    
    # Parse Intune MDM Enrollment status
    $isMDMEnrolled = $dsregcmdOutput -match '.*MDMUrl\s*:\s*(https://manage\.microsoft\.com|https://enrollment\.manage\.microsoft\.com)'

    return @{
        IsAzureADJoined = $isAzureADJoined
        IsMDMEnrolled   = $isMDMEnrolled
    }
}

# Main script execution block
$dsregStatus = Get-DSRegStatus

if ($dsregStatus.IsAzureADJoined -and $dsregStatus.IsMDMEnrolled) {
    Write-Output "Device is Azure AD Joined and Intune Enrolled."
    exit 0
} else {
    if (-not $dsregStatus.IsAzureADJoined) {
        Write-Output "Device is NOT Azure AD Joined."
    }
    if (-not $dsregStatus.IsMDMEnrolled) {
        Write-Output "Device is NOT Intune Enrolled."
    }
    exit 1
}
