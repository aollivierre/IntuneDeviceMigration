
#region FIRING UP MODULE STARTER
#################################################################################################
#                                                                                               #
#                                 FIRING UP MODULE STARTER                                      #
#                                                                                               #
#################################################################################################

# Define a hashtable for splatting
$moduleStarterParams = @{
    Mode                   = "dev"
    SkipPSGalleryModules   = $true
    SkipCheckandElevate    = $true
    SkipPowerShell7Install = $true
    SkipEnhancedModules    = $true
    SkipGitRepos           = $true
}

# Call the function using the splat
Invoke-ModuleStarter @moduleStarterParams

# Remove Intune management
$RemoveIntuneMgmtParams = @{
    OMADMPath             = "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*"
    EnrollmentBasePath    = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments"
    TrackedBasePath       = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked"
    PolicyManagerBasePath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager"
    ProvisioningBasePath  = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning"
    CertCurrentUserPath   = "cert:\CurrentUser"
    CertLocalMachinePath  = "cert:\LocalMachine"
    TaskPathBase          = "\Microsoft\Windows\EnterpriseMgmt"
    MSDMProviderID        = "MS DM Server"
    RegistryPathsToRemove = @(
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments",
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments\Status",
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked",
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled",
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\Providers",
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts",
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Logger",
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions"
    )
    UserCertIssuer        = "CN=SC_Online_Issuing"
    DeviceCertIssuers     = @("CN=Microsoft Intune Root Certification Authority", "CN=Microsoft Intune MDM Device CA")
}
Remove-IntuneMgmt @RemoveIntuneMgmtParams


Perform-IntuneCleanup