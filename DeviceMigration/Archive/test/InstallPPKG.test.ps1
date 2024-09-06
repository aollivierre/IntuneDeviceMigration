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



# # Example: Validate if a specific provisioning package is installed
# $ppkgInstalled = Validate-PPKGInstallation -PPKGName "ICTC_Project_2"
# if ($ppkgInstalled) {
#     Write-Host "Provisioning package is installed."
# }
# else {
#     Write-Host "Provisioning package is not installed."
# }


# Wait-Debugger



# Example usage
$params = @{
    PPKGName     = "C:\code\IntuneDeviceMigration\DeviceMigration\Files\ICTC_Project_2_Aug_29_2024\ICTC_Project_2.ppkg"
    # MigrationPath = "C:\ProgramData\AADMigration"
}
Install-PPKG @params


# # $ppkgPath = "C:\ProgramData\AADMigration\Files\ICTC_EJ_Bulk_Enrollment_v4\ICTC_EJ_Bulk_Enrollment_v5.ppkg"
# $ppkgPath = "C:\code\IntuneDeviceMigration\DeviceMigration\Files\ICTC_Project_2_Aug_29_2024\ICTC_Project_2.ppkg"
# $logPath = "C:\code\IntuneDeviceMigration\DeviceMigration\Files\ICTC_Project_1_Aug_29_2024\InstallLog.etl"

# Install-ProvisioningPackage -PackagePath $ppkgPath -ForceInstall -LogsDirectory $logPath



