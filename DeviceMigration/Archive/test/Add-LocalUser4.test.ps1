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

# # Add local user
# $AddLocalUserParams = @{
#     TempUser         = 'MigrationinProgress'
#     TempUserPassword = 'Default1234'
#     Description      = "account for autologin"
#     Group            = "Administrators"
# }
# Add-LocalUser @AddLocalUserParams







# Main Logic
Write-EnhancedLog -Message "Starting group member verification..." -Level "NOTICE"

# Verify current group members
Verify-GroupMembers -GroupName 'Administrators'

# Ensure TempUser is in the Administrators group
Add-UserToGroup -UserName 'TempUser010' -GroupName 'Administrators'

Write-EnhancedLog -Message "Group member verification completed." -Level "NOTICE"