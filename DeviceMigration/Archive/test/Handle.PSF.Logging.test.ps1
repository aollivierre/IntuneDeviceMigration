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





$JobName = "AAD_Migration"
$parentScriptName = Get-ParentScriptName
Write-EnhancedLog -Message "Parent Script Name: $parentScriptName"

$HandlePSFLoggingParams = @{
    SystemSourcePathWindowsPS = "C:\Windows\System32\config\systemprofile\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
    SystemSourcePathPS        = "C:\Windows\System32\config\systemprofile\AppData\Roaming\PowerShell\PSFramework\Logs\"
    # UserSourcePathWindowsPS   = "$env:USERPROFILE\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
    # UserSourcePathPS          = "$env:USERPROFILE\AppData\Roaming\PowerShell\PSFramework\Logs\"
    PSFPath                   = "C:\Logs\PSF"
    ParentScriptName          = $parentScriptName
    JobName                   = $JobName
    SkipSYSTEMLogCopy         = $false
    SkipSYSTEMLogRemoval      = $false
}

Handle-PSFLogging @HandlePSFLoggingParams