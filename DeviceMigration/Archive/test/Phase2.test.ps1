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


$mode = 'dev'

$RegistrySettings = @(
    @{
        RegValName = "AutoAdminLogon"
        RegValType = "DWORD"
        RegValData = "0"
        RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    },
    @{
        RegValName = "dontdisplaylastusername"
        RegValType = "DWORD"
        RegValData = "1"
        RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    },
    @{
        RegValName = "legalnoticecaption"
        RegValType = "String"
        RegValData = "Migration Completed"
        RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    },
    @{
        RegValName = "legalnoticetext"
        RegValType = "String"
        RegValData = "This PC has been migrated to Azure Active Directory. Please log in to Windows using your email address and password."
        RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    }
)


$PostRunOncePhase2EscrowBitlockerParams = @{
    ImagePath         = "C:\ProgramData\AADMigration\Files\MigrationInProgress.bmp"
    TaskPath          = "AAD Migration"
    TaskName          = "Run Post migration cleanup"
    BitlockerDrives   = @("C:")
    RegistrySettings  = $RegistrySettings  # Correctly assign the array here
    Mode              = $mode
}

PostRunOnce-Phase2EscrowBitlocker @PostRunOncePhase2EscrowBitlockerParams


   # RegistrySettings = @{
    #     "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"     = @{
    #         "AutoAdminLogon" = @{
    #             "Type" = "DWORD"
    #             "Data" = "0"
    #         }
    #     }
    #     "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" = @{
    #         "dontdisplaylastusername" = @{
    #             "Type" = "DWORD"
    #             "Data" = "1"
    #         }
    #         "legalnoticecaption"      = @{
    #             "Type" = "String"
    #             "Data" = "Migration Completed"
    #         }
    #         "legalnoticetext"         = @{
    #             "Type" = "String"
    #             "Data" = "This PC has been migrated to Azure Active Directory. Please log in to Windows using your email address and password."
    #         }
    #     }
    # }