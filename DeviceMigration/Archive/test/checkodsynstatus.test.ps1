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

$CheckODSyncUtilStatusParams = @{
    ScriptPath     = "C:\ProgramData\AADMigration\Files\ODSyncUtil"
    LogFolderName  = "logs"
    StatusFileName = "ODSyncUtilStatus.json"
}
Check-ODSyncUtilStatus @CheckODSyncUtilStatusParams