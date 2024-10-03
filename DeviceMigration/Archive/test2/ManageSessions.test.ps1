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


# Main execution
try {
    Write-EnhancedLog -Message "Script execution started" -Level "NOTICE"
    Manage-UserSessions
} catch {
    Handle-Error -ErrorRecord $_
} finally {
    Write-EnhancedLog -Message "Script execution finished" -Level "NOTICE"
}
