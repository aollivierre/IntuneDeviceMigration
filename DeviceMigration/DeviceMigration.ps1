#!ToDO work on creatng a function for importing all modules in the modules folders without specifying the path of each module.
#fix permissions of the client app to add Intune permissions

# Load the secrets from the JSON file
#First, load secrets and create a credential object:
# Assuming secrets.json is in the same directory as your script
# $certsecretsPath = Join-Path -Path $PSScriptRoot -ChildPath "certsecrets.json"

# Load the secrets from the JSON file
# $certsecrets = Get-Content -Path $certsecretsPath -Raw | ConvertFrom-Json

# Read configuration from the JSON file
# Assign values from JSON to variables

# Read configuration from the JSON file
$configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.json"
$env:MYMODULE_CONFIG_PATH = $configPath

$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

#  Variables from JSON file
# $CertPassword = $certsecrets.certexportpassword




function Initialize-Environment {
    param (
        [string]$WindowsModulePath = "EnhancedBoilerPlateAO\2.0.0\EnhancedBoilerPlateAO.psm1",
        [string]$LinuxModulePath = "/usr/src/code/Modules/EnhancedBoilerPlateAO/2.0.0/EnhancedBoilerPlateAO.psm1"
    )

    function Get-Platform {
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            return $PSVersionTable.Platform
        }
        else {
            return [System.Environment]::OSVersion.Platform
        }
    }

    function Setup-GlobalPaths {
        if ($env:DOCKER_ENV -eq $true) {
            $global:scriptBasePath = $env:SCRIPT_BASE_PATH
            $global:modulesBasePath = $env:MODULES_BASE_PATH
        }
        else {
            $global:scriptBasePath = $PSScriptRoot
            # $global:modulesBasePath = "$PSScriptRoot\modules"
            $global:modulesBasePath = "c:\code\modules"
        }
    }

    function Setup-WindowsEnvironment {
        # Get the base paths from the global variables
        Setup-GlobalPaths

        # Construct the paths dynamically using the base paths
        $global:modulePath = Join-Path -Path $modulesBasePath -ChildPath $WindowsModulePath
        $global:AOscriptDirectory = Join-Path -Path $scriptBasePath -ChildPath "Win32Apps-DropBox"
        $global:directoryPath = Join-Path -Path $scriptBasePath -ChildPath "Win32Apps-DropBox"
        $global:Repo_Path = $scriptBasePath
        $global:Repo_winget = "$Repo_Path\Win32Apps-DropBox"


        # Import the module using the dynamically constructed path
        Import-Module -Name $global:modulePath -Verbose -Force:$true -Global:$true

        # Log the paths to verify
        Write-Output "Module Path: $global:modulePath"
        Write-Output "Repo Path: $global:Repo_Path"
        Write-Output "Repo Winget Path: $global:Repo_winget"
    }

    function Setup-LinuxEnvironment {
        # Get the base paths from the global variables
        Setup-GlobalPaths

        # Import the module using the Linux path
        Import-Module $LinuxModulePath -Verbose

        # Convert paths from Windows to Linux format
        $global:AOscriptDirectory = Convert-WindowsPathToLinuxPath -WindowsPath "C:\Users\Admin-Abdullah\AppData\Local\Intune-Win32-Deployer"
        $global:directoryPath = Convert-WindowsPathToLinuxPath -WindowsPath "C:\Users\Admin-Abdullah\AppData\Local\Intune-Win32-Deployer\Win32Apps-DropBox"
        $global:Repo_Path = Convert-WindowsPathToLinuxPath -WindowsPath "C:\Users\Admin-Abdullah\AppData\Local\Intune-Win32-Deployer"
        $global:Repo_winget = "$global:Repo_Path\Win32Apps-DropBox"
    }

    $platform = Get-Platform
    if ($platform -eq 'Win32NT' -or $platform -eq [System.PlatformID]::Win32NT) {
        Setup-WindowsEnvironment
    }
    elseif ($platform -eq 'Unix' -or $platform -eq [System.PlatformID]::Unix) {
        Setup-LinuxEnvironment
    }
    else {
        throw "Unsupported operating system"
    }
}

# Call the function to initialize the environment
Initialize-Environment


# Example usage of global variables outside the function
Write-Output "Global variables set by Initialize-Environment:"
Write-Output "scriptBasePath: $scriptBasePath"
Write-Output "modulesBasePath: $modulesBasePath"
Write-Output "modulePath: $modulePath"
Write-Output "AOscriptDirectory: $AOscriptDirectory"
Write-Output "directoryPath: $directoryPath"
Write-Output "Repo_Path: $Repo_Path"
Write-Output "Repo_winget: $Repo_winget"

#################################################################################################################################
################################################# END VARIABLES #################################################################
#################################################################################################################################

###############################################################################################################################
############################################### START MODULE LOADING ##########################################################
###############################################################################################################################

<#
.SYNOPSIS
Dot-sources all PowerShell scripts in the 'private' folder relative to the script root.

.DESCRIPTION
This function finds all PowerShell (.ps1) scripts in a 'private' folder located in the script root directory and dot-sources them. It logs the process, including any errors encountered, with optional color coding.

.EXAMPLE
Dot-SourcePrivateScripts

Dot-sources all scripts in the 'private' folder and logs the process.

.NOTES
Ensure the Write-EnhancedLog function is defined before using this function for logging purposes.
#>


Write-Host "Starting to call Get-ModulesFolderPath..."

# Store the outcome in $ModulesFolderPath
try {
  
    $ModulesFolderPath = Get-ModulesFolderPath -WindowsPath "C:\code\modules" -UnixPath "/usr/src/code/modules"
    # $ModulesFolderPath = Get-ModulesFolderPath -WindowsPath "$PsScriptRoot\modules" -UnixPath "$PsScriptRoot/modules"
    Write-host "Modules folder path: $ModulesFolderPath"

}
catch {
    Write-Error $_.Exception.Message
}


Write-Host "Starting to call Import-LatestModulesLocalRepository..."
Import-LatestModulesLocalRepository -ModulesFolderPath $ModulesFolderPath -ScriptPath $PSScriptRoot

###############################################################################################################################
############################################### END MODULE LOADING ############################################################
###############################################################################################################################
try {
    Ensure-LoggingFunctionExists -LoggingFunctionName "Write-EnhancedLog"
    # Continue with the rest of the script here
    # exit
}
catch {
    Write-Host "Critical error: $_" -ForegroundColor Red
    Handle-Error $_.
    exit
}

###############################################################################################################################
###############################################################################################################################
###############################################################################################################################

# Setup logging
Write-EnhancedLog -Message "Script Started" -Level "INFO"

################################################################################################################################
################################################################################################################################
################################################################################################################################

# Execute InstallAndImportModulesPSGallery function
InstallAndImportModulesPSGallery -moduleJsonPath "$PSScriptRoot/modules.json"

################################################################################################################################
################################################ END MODULE CHECKING ###########################################################
################################################################################################################################

    
################################################################################################################################
################################################ END LOGGING ###################################################################
################################################################################################################################

#  Define the variables to be used for the function
#  $PSADTdownloadParams = @{
#      GithubRepository     = "psappdeploytoolkit/psappdeploytoolkit"
#      FilenamePatternMatch = "PSAppDeployToolkit*.zip"
#      ZipExtractionPath    = Join-Path "$PSScriptRoot\private" "PSAppDeployToolkit"
#  }

#  Call the function with the variables
#  Download-PSAppDeployToolkit @PSADTdownloadParams

################################################################################################################################
################################################ END DOWNLOADING PSADT #########################################################
################################################################################################################################


##########################################################################################################################
############################################STARTING THE MAIN FUNCTION LOGIC HERE#########################################
##########################################################################################################################


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
        [string]$ProvisioningPackageSource = "C:\code\CB\Entra\DeviceMigration\ProvisioningPackage.ppkg"
    )

    Begin {
        Write-EnhancedLog -Message "Starting Execute-MigrationTasks function" -Level "INFO"
        Log-Params -Params @{
            ToolkitFolder             = $ToolkitFolder
            FilesFolder               = $FilesFolder
            ScriptsFolder             = $ScriptsFolder
            BannerImageSource         = $BannerImageSource
            DeployApplicationSource   = $DeployApplicationSource
            BannerImageDestination    = $BannerImageDestination
            MigrationToolURL          = $MigrationToolURL
            PSAppDeployToolkitURL     = $PSAppDeployToolkitURL
            MDTURL                    = $MDTURL
            OneDriveLibURL            = $OneDriveLibURL
            ProvisioningPackageSource = $ProvisioningPackageSource
        }
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
                Download-OneDriveLib -Destination "$FilesFolder\OneDriveLib.dll"
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



# Import migration configuration
$ConfigFileName = "MigrationConfig.psd1"
$ConfigBaseDirectory = $PSScriptRoot
$MigrationConfig = Import-LocalizedData -BaseDirectory $ConfigBaseDirectory -FileName $ConfigFileName
$StartBoundary = $MigrationConfig.StartBoundary

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

# $DBG


Check-OneDriveSyncStatus -OneDriveLibPath "C:\ProgramData\AADMigration\Files\OneDriveLib.dll"

$DBG

# Set up migration task

$ScriptPath = "C:\ProgramData\AADMigration\Scripts\Execute-MigrationToolkit.ps1"
$MigrationTaskParams = @{
    StartBoundary = $StartBoundary
    # ScriptPath    = "C:\ProgramData\AADMigration\Scripts\Launch-DeployApplication_SchTask.ps1"
    ScriptPath    = "C:\ProgramData\AADMigration\Scripts\Execute-MigrationToolkit.ps1"
    TaskPath      = "AAD Migration"
    TaskName      = "AADM Launch PSADT for Interactive Migration"
    Description   = "AADM Launch PSADT for Interactive Migration"
    UserId        = "SYSTEM"
    RunLevel      = "Highest"
    Delay         = "PT1M"
    ExecutePath   = "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe"
    Arguments     = "-executionpolicy Bypass -file `"$ScriptPath`""
}
      
# Example usage with splatting
#Phase 2 Create the Migration task

Unregister-ScheduledTaskWithLogging -TaskName "AADM Launch PSADT for Interactive Migration"

$DBG

New-MigrationTask @MigrationTaskParams

$DBG