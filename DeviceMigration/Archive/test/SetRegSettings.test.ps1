Import-Module 'C:\code\ModulesV2\EnhancedModuleStarterAO\EnhancedModuleStarterAO.psm1'

# Define a hashtable for splatting
$moduleStarterParams = @{
    Mode                   = 'dev'
    SkipPSGalleryModules   = $true
    SkipCheckandElevate    = $true
    SkipPowerShell7Install = $true
    SkipEnhancedModules    = $true
    SkipGitRepos           = $true
}

# Call the function using the splat
Invoke-ModuleStarter @moduleStarterParams


$TenantID = 'b5dae566-ad8f-44e1-9929-5669f1dbb343'


$RegistrySettings = @(
    @{
        RegValName = "AllowTenantList"
        RegValType = "STRING"
        RegValData = $TenantID
    },
    @{
        RegValName = "SilentAccountConfig"
        RegValType = "DWORD"
        RegValData = "1"
    },
    @{
        RegValName = "KFMOptInWithWizard"
        RegValType = "STRING"
        RegValData = $TenantID
    },
    @{
        RegValName = "KFMSilentOptIn"
        RegValType = "STRING"
        RegValData = $TenantID
    },
    @{
        RegValName = "KFMSilentOptInDesktop"
        RegValType = "DWORD"
        RegValData = "1"
    },
    @{
        RegValName = "KFMSilentOptInDocuments"
        RegValType = "DWORD"
        RegValData = "1"
    },
    @{
        RegValName = "KFMSilentOptInPictures"
        RegValType = "DWORD"
        RegValData = "1"
    }
)



# Apply-RegistrySettings -RegistrySettings $RegistrySettings

$SetODKFMRegistrySettingsParams = @{
    TenantID         = $TenantID
    RegKeyPath       = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
    RegistrySettings = $RegistrySettings
}

Set-ODKFMRegistrySettings @SetODKFMRegistrySettingsParams