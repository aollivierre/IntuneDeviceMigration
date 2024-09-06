#region FIRING UP MODULE STARTER
#################################################################################################
#                                                                                               #
#                                 FIRING UP MODULE STARTER                                      #
#                                                                                               #
#################################################################################################

# Fetch the script content
$scriptContent = Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1"

# Define replacements in a hashtable
$replacements = @{
    '\$Mode = "dev"'                     = '$Mode = "dev"'
    '\$SkipPSGalleryModules = \$false'   = '$SkipPSGalleryModules = $true'
    '\$SkipCheckandElevate = \$false'    = '$SkipCheckandElevate = $true'
    '\$SkipAdminCheck = \$false'         = '$SkipAdminCheck = $true'
    '\$SkipPowerShell7Install = \$false' = '$SkipPowerShell7Install = $true'
    '\$SkipModuleDownload = \$false'     = '$SkipModuleDownload = $true'
    '\$SkipGitrepos = \$false'           = '$SkipGitrepos = $true'
}

# Apply the replacements
foreach ($pattern in $replacements.Keys) {
    $scriptContent = $scriptContent -replace $pattern, $replacements[$pattern]
}

# Execute the script
Invoke-Expression $scriptContent



# Configuration settings
# Path to the PSD1 configuration file
$configPath = "C:\ProgramData\AADMigration\MigrationConfig.psd1"

# Import the configuration settings from the PSD1 file
$config = Import-PowerShellDataFile -Path $configPath

# Access the configuration settings
$MigrationPath = $config.MigrationPath
$UseOneDriveKFM = $config.UseOneDriveKFM
$InstallOneDrive = $config.InstallOneDrive
$TenantID = $config.TenantID
$DeferDeadline = $config.DeferDeadline
$DeferTimes = $config.DeferTimes
$TempUser = $config.TempUser
$TempPass = $config.TempPass
$ProvisioningPack = $config.ProvisioningPack
$ProvisioningPackName = $config.ProvisioningPackname

# Example of logging the loaded configuration
Write-EnhancedLog -Message "Loaded configuration from $configPath" -Level "INFO"
Write-EnhancedLog -Message "MigrationPath: $MigrationPath" -Level "INFO"
Write-EnhancedLog -Message "UseOneDriveKFM: $UseOneDriveKFM" -Level "INFO"
Write-EnhancedLog -Message "InstallOneDrive: $InstallOneDrive" -Level "INFO"
Write-EnhancedLog -Message "TenantID: $TenantID" -Level "INFO"
Write-EnhancedLog -Message "DeferDeadline: $DeferDeadline" -Level "INFO"
Write-EnhancedLog -Message "TempUser: $TempUser" -Level "INFO"
Write-EnhancedLog -Message "ProvisioningPack: $ProvisioningPack" -Level "INFO"
Write-EnhancedLog -Message "ProvisioningPackName: $ProvisioningPackName" -Level "INFO"

# Wait-Debugger


# Script variables
$DomainLeaveUser = $DomainLeaveUser
$DomainLeavePassword = $DomainLeavePassword


$MainMigrateParams = @{
    # PPKGName   = "C:\code\CB\Entra\DeviceMigration\Files\ICTC_EJ_Bulk_Enrollment_v4\ICTC_EJ_Bulk_Enrollment_v5.ppkg"
    # PPKGName         = "ICTC_EJ_Bulk_Enrollment_v5.ppkg"
    PPKGPath         = $ProvisioningPack
    # DomainLeaveUser     = "YourDomainUser"
    # DomainLeavePassword = "YourDomainPassword"
    TempUser         = $TempUser
    TempUserPassword = $TempPass
    ScriptPath       = "C:\ProgramData\AADMigration\Scripts\PostRunOnce.ps1"
}

Main-MigrateToAADJOnly @MainMigrateParams