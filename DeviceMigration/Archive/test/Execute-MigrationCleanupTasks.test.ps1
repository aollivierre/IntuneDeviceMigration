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

$ExecuteMigrationCleanupTasksParams = @{
    TempUser             = "MigrationInProgress"
    RegistrySettings     = @(
        @{
            RegValName = "dontdisplaylastusername"
            RegValType = "DWORD"
            RegValData = "0"
            RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        },
        @{
            RegValName = "legalnoticecaption"
            RegValType = "String"
            RegValData = ""
            RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        },
        @{
            RegValName = "legalnoticetext"
            RegValType = "String"
            RegValData = ""
            RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        },
        @{
            RegValName = "NoLockScreen"
            RegValType = "DWORD"
            RegValData = "0"
            RegKeyPath = "HKLM:\Software\Policies\Microsoft\Windows\Personalization"
        }
    )
    MigrationDirectories = @(
        "C:\ProgramData\AADMigration\Files",
        # "C:\ProgramData\AADMigration\Scripts",
        "C:\ProgramData\AADMigration\Toolkit"
    )
    Mode                 = "Dev"
}

Execute-MigrationCleanupTasks @ExecuteMigrationCleanupTasksParams


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