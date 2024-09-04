function Execute-MigrationTasks {
    [CmdletBinding()]
    param (
        [string]$ToolkitFolder = "C:\code\CB\Entra\DeviceMigration\Toolkit",
        [string]$FilesFolder = "C:\code\CB\Entra\DeviceMigration\Files",
        [string]$ScriptsFolder = "C:\code\CB\Entra\DeviceMigration\Scripts",
        [string]$BannerImageSource = "C:\code\CB\Entra\DeviceMigration\YourBannerImage.png",
        [string]$DeployApplicationSource = "$ScriptsFolder\Deploy-Application.ps1",
        [string]$BannerImageDestination = "$ToolkitFolder\Toolkit\AppDeployToolkit\AppDeployToolkitBanner.png",
        [string]$MigrationToolURL = "https://github.com/managedBlog/Managed_Blog/tree/main/AD%20to%20AAD%20Only%20Migration%20Tool/Beta%20-%20PS1%20Script%20based",
        [string]$PSAppDeployToolkitURL = "https://github.com/PSAppDeployToolkit/PSAppDeployToolkit/releases/download/v3.8.4/PSAppDeployToolkit_v3.8.4.zip",
        [string]$MDTURL = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi",
        # [string]$OneDriveLibURL = "https://github.com/rodneyviana/ODSyncService/raw/main/OneDriveLib.dll",
        # [string]$OneDriveLibURL = "https://api.github.com/repos/rodneyviana/ODSyncService/releases/latest",
        [string]$ODSyncUtil = "https://api.github.com/repos/rodneyviana/ODSyncUtil/releases/latest",
        [string]$ProvisioningPackageSource = "C:\code\CB\Entra\DeviceMigration\ProvisioningPackage.ppkg"
    )

    Begin {
        Write-EnhancedLog -Message "Starting Execute-MigrationTasks function" -Level "INFO"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            # Add steps
            Add-Step "Preparing solution directory" {
                Prepare-SolutionDirectory -ToolkitFolder $ToolkitFolder -FilesFolder $FilesFolder
            }

            # $DBG

            Add-Step "Downloading migration tool" {
                #the following is not downloading the actual content for the migration tool from GitHub so it needs to be fixed for now we are downloading manually and perhaps we need to build a Git based function around that or figure out how to better download this via IWR or IRM
                Download-MigrationTool -url $MigrationToolURL -destination "$FilesFolder\MigrationTool.zip"
            }

            Add-Step "Downloading and extracting PSAppDeployToolkit" {
                # Download-PSAppDeployToolkit -url $PSAppDeployToolkitURL -destination "$FilesFolder\PSAppDeployToolkit.zip" -ToolkitFolder $ToolkitFolder

                #  Define the variables to be used for the function
                $PSADTdownloadParams = @{
                    GithubRepository     = "psappdeploytoolkit/psappdeploytoolkit"
                    FilenamePatternMatch = "PSAppDeployToolkit*.zip"
                    # ZipExtractionPath    = Join-Path "$PSScriptRoot\Toolkit" "PSAppDeployToolkit"
                    ZipExtractionPath    = "$PSScriptRoot\Toolkit"
                }

                # Call the function with the variables
                Download-PSAppDeployToolkit @PSADTdownloadParams


            }

            Add-Step "Downloading and installing Microsoft Deployment Toolkit" {
                # Download-InstallMDT -url $MDTURL -destination "$FilesFolder\MDT.exe" -FilesFolder $FilesFolder

                Download-InstallServiceUI -url $MDTURL -TargetFolder "$FilesFolder"
            }

            Add-Step "Downloading OneDriveLib.dll" {
                # Download-OneDriveLib -url $OneDriveLibURL -destination "$FilesFolder\OneDriveLib.dll"
                # Download-OneDriveLib -Destination "$FilesFolder\OneDriveLib.dll"

                # Example usage
                # $DownloadOneDriveLibParams = @{
                #     Destination = "$FilesFolder\OneDriveLib.dll"
                #     ApiUrl      = "$OneDriveLibURL"
                #     FileName    = "OneDriveLib.dll"
                #     MaxRetries  = 3
                # }
                # Download-OneDriveLib @DownloadOneDriveLibParams


                $DownloadODSyncUtilParams = @{
                    Destination    = "$FilesFolder\ODSyncUtil.exe"
                    ApiUrl         = "$ODSyncUtil"
                    ZipFileName    = "ODSyncUtil-64-bit.zip"
                    ExecutableName = "ODSyncUtil.exe"
                    MaxRetries     = 3
                }
                Download-ODSyncUtil @DownloadODSyncUtilParams


            }


            Add-Step "Downloading Assessment and Deployment Kit and Imaging and Configuration Designer" {
            
                # Step 1: Download ADK for Offline Installation on an Online Computer
                $downloadParams = @{
                    ADKUrl       = 'https://go.microsoft.com/fwlink/?linkid=2271337'
                    DownloadPath = "$env:TEMP\adksetup.exe"
                    OfflinePath  = "$env:TEMP\ADKOffline"
                }

                Download-ADKOffline @downloadParams

                # Copy the contents of the OfflinePath to the target offline computer.

                # Step 2: Install ADK on the Offline Computer
                $installParams = @{
                    OfflinePath = "$env:TEMP\ADKOffline\Installers"
                    ICDPath     = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Imaging and Configuration Designer\x86\ICD.exe"
                }

                Install-ADKFromMSI @installParams
                
            }

            Add-Step "Creating provisioning package for AAD bulk enrollment" {
                # Create-ProvPackageAADEnrollment -source $ProvisioningPackageSource -destination "$FilesFolder\ProvisioningPackage.ppkg"

                # Add-EnvPath -Path 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Imaging and Configuration Designer\x86' -Container 'Machine'

                # Example usage
                $envPathParams = @{
                    Path      = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Imaging and Configuration Designer\x86'
                    Container = 'Machine'
                }

                Add-EnvPath @envPathParams


                #The following works provided that I already pre-create the full ppkg with the customizations.xml file using the WCD GUI to fetch the EJ bulk enrollment tokent

                # Create-PPKG -CustomizationXMLPath "$FilesFolder\customizations.xml" -PackagePath "$FilesFolder\ProvisioningPackage.ppkg" -Overwrite
                $ppkgParams = @{
                    ICDPath              = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Imaging and Configuration Designer\x86\ICD.exe"
                    CustomizationXMLPath = "C:\code\CB\Entra\DeviceMigration\Files\customizations.xml"
                    PackagePath          = "C:\code\CB\Entra\DeviceMigration\Files\ProvisioningPackage.ppkg"
                    Encrypted            = $false
                    Overwrite            = $true
                }

                Create-PPKG @ppkgParams


                # Example usage of the Check-PackageAccount function
                try {
                    # Define the package GUID and domain
                    $packageGuid = "75cc34e6-141c-4577-8792-c238a4293408"
                    $domain = "ictc-ctic.ca"

                    # Invoke the Check-PackageAccount function
                    Check-PackageAccount -PackageGuid $packageGuid -Domain $domain
                }
                catch {
                    Write-Host "An error occurred during the account check: $($_.Exception.Message)" -ForegroundColor Red
                }
                
                
            }

            Add-Step "Replacing Deploy-Application.ps1 in the toolkit folder" {
                Replace-DeployApplicationPS1 -source $DeployApplicationSource -destination "$ToolkitFolder\Toolkit\Deploy-Application.ps1"
            }

            Add-Step "Replacing the banner image in the toolkit folder" {
                Replace-BannerImage -source $BannerImageSource -destination $BannerImageDestination
            }

            # $DBG

            # Execute steps
            foreach ($step in $global:steps) {
                Log-And-Execute-Step

                $DBG

            }

            $DBG

            Write-Output "All tasks completed successfully."
        }
        catch {
            Write-EnhancedLog -Message "An error occurred while executing migration tasks: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Execute-MigrationTasks function" -Level "INFO"
    }
}

# Example usage
# Execute-MigrationTasks -ToolkitFolder 'C:\code\CB\Entra\DeviceMigration\Toolkit' -FilesFolder 'C:\code\CB\Entra\DeviceMigration\Files' -ScriptsFolder 'C:\code\CB\Entra\DeviceMigration\Scripts' -BannerImageSource 'C:\code\CB\Entra\DeviceMigration\YourBannerImage.png' -DeployApplicationSource 'C:\code\CB\Entra\DeviceMigration\Scripts\Deploy-Application.ps1' -ProvisioningPackageSource 'C:\code\CB\Entra\DeviceMigration\ProvisioningPackage.ppkg'

$ExecuteMigrationTasksParams = @{
    ToolkitFolder             = 'C:\code\CB\Entra\DeviceMigration\Toolkit'
    FilesFolder               = 'C:\code\CB\Entra\DeviceMigration\Files'
    ScriptsFolder             = 'C:\code\CB\Entra\DeviceMigration\Scripts'
    BannerImageSource         = 'C:\code\CB\Entra\DeviceMigration\ICTC_Banner.png'
    DeployApplicationSource   = 'C:\code\CB\Entra\DeviceMigration\Scripts\Deploy-Application.ps1'
    ProvisioningPackageSource = 'C:\code\CB\Entra\DeviceMigration\ProvisioningPackage.ppkg'
}


#Phase 1 Prepare the solution directory
# Execute-MigrationTasks @ExecuteMigrationTasksParams


# $MainMigrateParams = @{
#     PPKGName   = "YourProvisioningPackName"
#     # DomainLeaveUser     = "YourDomainUser"
#     # DomainLeavePassword = "YourDomainPassword"
#     TempUser = "MigrationInProgress"
#     TempPass = "Default1234"
#     ScriptPath = "C:\ProgramData\AADMigration\Scripts\PostRunOnce.ps1"
# }


# You may call the following independently or from within PSADT. I will comment it out here as I am calling it throughh PSADT
# Main-MigrateToAADJOnly @MainMigrateParams
