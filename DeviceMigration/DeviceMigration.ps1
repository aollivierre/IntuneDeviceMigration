iex ((irm "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1") -replace '\$Mode = "dev"', '$Mode = "dev"')


# ################################################################################################################################
# ################################################ START GRAPH CONNECTING ########################################################
# ################################################################################################################################
# # Path to the scopes.json file
# $jsonFilePath = "$PSscriptroot\scopes.json"

# # Read the JSON file
# $jsonContent = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json

# # Extract the scopes
# $scopes = $jsonContent.Scopes -join " "

# # Connect to Microsoft Graph with the specified scopes
# # Connect to Graph interactively
# Disconnect-MgGraph -Verbose

# # Call the function to connect to Microsoft Graph
# Connect-ToMicrosoftGraphIfServerCore -Scopes $scopes




# $dbg


# Get the tenant details
# $tenantDetails = $null
# $tenantDetails = Get-TenantDetails
# if ($null -eq $tenantDetails) {
#     Write-EnhancedLog -Message "Unable to proceed without tenant details" -Level "ERROR"
#     throw "Tenant Details name is empty. Cannot proceed without a valid tenant details"
#     exit
# }

#################################################################################################################################
################################################# END Connecting to Graph #######################################################
#################################################################################################################################

#Endregion #########################################DEALING WITH MODULES########################################################



# Initialize the global steps list
$global:steps = [System.Collections.Generic.List[PSCustomObject]]::new()
$global:currentStep = 0

# Function to add a step


# Function to log and execute the current step

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


# ################################################################################################################################
# ############### CALLING AS SYSTEM to simulate Intune deployment as SYSTEM (Uncomment for debugging) ############################
# ################################################################################################################################

# Example usage
$ensureRunningAsSystemParams = @{
    PsExec64Path = Join-Path -Path $PSScriptRoot -ChildPath "private\PsExec64.exe"
    ScriptPath   = $MyInvocation.MyCommand.Path
    TargetFolder = Join-Path -Path $PSScriptRoot -ChildPath "private"
}

Ensure-RunningAsSystem @ensureRunningAsSystemParams


# ################################################################################################################################
# ############### END CALLING AS SYSTEM to simulate Intune deployment as SYSTEM (Uncomment for debugging) ########################
# ################################################################################################################################


# Example usage of Download-And-Install-ServiceUI function with splatting
$DownloadAndInstallServiceUIparams = @{
    TargetFolder           = "$PSScriptRoot"
    DownloadUrl            = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
    MsiFileName            = "MicrosoftDeploymentToolkit_x64.msi"
    InstalledServiceUIPath = "C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\ServiceUI.exe"
}
Download-And-Install-ServiceUI @DownloadAndInstallServiceUIparams


# Example usage
# Example usage
$DownloadPSAppDeployToolkitParams = @{
    GithubRepository = 'PSAppDeployToolkit/PSAppDeployToolkit';
    FilenamePatternMatch = '*.zip';
    DestinationDirectory = "$PSScriptroot"
}
Download-PSAppDeployToolkit @DownloadPSAppDeployToolkitParams



# we are skipping Download-ODSyncUtil here becuase we are calling withing the scheduled script of Check-ODSyncUtilStatus.ps1 as that will download the file as the user owner not as the SYSTEM owner below as the download logic will remove files and will encounter errors if files are not owned by the user
# you may call the following during the Execute-MigrationTasks function flow


# $DownloadODSyncUtilParams = @{
#     Destination    = "$PSScriptRoot\Files\ODSyncUtil\ODSyncUtil.exe"
#     ApiUrl         = "https://api.github.com/repos/rodneyviana/ODSyncUtil/releases/latest"
#     ZipFileName    = "ODSyncUtil-64-bit.zip"
#     ExecutableName = "ODSyncUtil.exe"
#     MaxRetries     = 3
# }
# Download-ODSyncUtil @DownloadODSyncUtilParams


# ################################################################################################################################
# ############### END Downloading Service UI and PSADT ###########################################################################
# ################################################################################################################################


# Import migration configuration
$ConfigFileName = "MigrationConfig.psd1"
$ConfigBaseDirectory = $PSScriptRoot
$MigrationConfig = Import-LocalizedData -BaseDirectory $ConfigBaseDirectory -FileName $ConfigFileName
# $StartBoundary = $MigrationConfig.StartBoundary

$TenantID = $MigrationConfig.TenantID
$OneDriveKFM = $MigrationConfig.UseOneDriveKFM
$InstallOneDrive = $MigrationConfig.InstallOneDrive



# Define parameters
$PrepareAADMigrationParams = @{
    MigrationPath       = "C:\ProgramData\AADMigration"
    PSScriptbase        = $PSScriptRoot
    # ConfigBaseDirectory = "C:\ConfigDirectory\Scripts"
    ConfigBaseDirectory = $PSScriptRoot
    ConfigFileName      = "MigrationConfig.psd1"
    TenantID            = $TenantID
    OneDriveKFM         = $OneDriveKFM
    InstallOneDrive     = $InstallOneDrive
}

# Example usage with splatting
Prepare-AADMigration @PrepareAADMigrationParams

$DBG


# Set up migration task

# $ScriptPath = "C:\ProgramData\AADMigration\Scripts\Execute-MigrationToolkit.ps1"
# $MigrationTaskParams = @{
#     StartBoundary = $StartBoundary
#     ScriptPath    = "C:\ProgramData\AADMigration\Scripts\Execute-MigrationToolkit.ps1"
#     TaskPath      = "AAD Migration"
#     TaskName      = "AADM Launch PSADT for Interactive Migration"
#     Description   = "AADM Launch PSADT for Interactive Migration"
#     UserId        = "SYSTEM"
#     RunLevel      = "Highest"
#     Delay         = "PT1M"
#     ExecutePath   = "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe"
#     Arguments     = "-executionpolicy Bypass -file `"$ScriptPath`""
# }

      
# Example usage with splatting
#Phase 2 Create the Migration task

# Unregister-ScheduledTaskWithLogging -TaskName "AADM Launch PSADT for Interactive Migration"

$DBG

# New-MigrationTask @MigrationTaskParams


# Define the parameters using a hashtable
# $schedulerconfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config.psd1"
# $taskParams = @{
#     ConfigPath  = $schedulerconfigPath
#     FileName    = "HiddenScript.vbs"
#     Scriptroot  = "$PSScriptroot"
# }

# # Call the function with the splatted parameters
# CreateAndRegisterScheduledTask @taskParams



# ################################################################################################################################
# ############### END CALLING AS SYSTEM to simulate Intune deployment as SYSTEM (Uncomment for debugging) ########################
# ################################################################################################################################


#Here we will schedule our Interactive Migration script (which is our script2 or our post-reboot script to run automatically at startup under the SYSTEM account)
# here I need to pass these in the config file (JSON or PSD1) or here in the splat but I need to have it outside of the function


# # $schedulerconfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config.psd1"
# $schedulerconfigPath = "C:\code\IntuneDeviceMigration\DeviceMigration\Interactive-Migration-Task-config.psd1"
# $taskParams = @{
#     ConfigPath = $schedulerconfigPath
#     FileName   = "run-ps-hidden.vbs"
#     Scriptroot = $PSScriptRoot
# }

# CreateAndRegisterScheduledTask @taskParams

# $DBG




# Example usage with splatting
$CreateInteractiveMigrationTaskParams = @{
    TaskPath               = "AAD Migration"
    TaskName               = "PR4B-AADM Launch PSADT for Interactive Migration"
    ServiceUIPath          = "C:\ProgramData\AADMigration\ServiceUI.exe"
    ToolkitExecutablePath  = "C:\ProgramData\AADMigration\PSAppDeployToolkit\Toolkit\Deploy-Application.exe"
    ProcessName            = "explorer.exe"
    DeploymentType         = "Install"
    DeployMode             = "Interactive"
    TaskTriggerType        = "AtLogOn"
    TaskRepetitionDuration = "P1D"  # 1 day
    TaskRepetitionInterval = "PT15M"  # 15 minutes
    TaskPrincipalUserId    = "NT AUTHORITY\SYSTEM"
    TaskRunLevel           = "Highest"
    TaskDescription        = "AADM Launch PSADT for Interactive Migration Version 1.0"
    Delay                  = "PT2H"  # 2 hours delay before starting
}

Create-InteractiveMigrationTask @CreateInteractiveMigrationTaskParams