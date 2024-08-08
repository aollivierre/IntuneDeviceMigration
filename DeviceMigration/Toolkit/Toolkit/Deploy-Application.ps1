<#
.SYNOPSIS
	This script performs the installation or uninstallation of an application(s).
	# LICENSE #
	PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows.
	Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
	This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
	The script is provided as a template to perform an install or uninstall of an application(s).
	The script either performs an "Install" deployment type or an "Uninstall" deployment type.
	The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
	The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
	Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
	Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
	Disables logging to file for the script. Default is: $false.
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
.EXAMPLE
    Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"
.NOTES
	Toolkit Exit Code Ranges:
	60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
	69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory = $false)]
	[ValidateSet('Install', 'Uninstall', 'Repair')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory = $false)]
	[ValidateSet('Interactive', 'Silent', 'NonInteractive')]
	[string]$DeployMode = 'Interactive',
	[Parameter(Mandatory = $false)]
	[switch]$AllowRebootPassThru = $false,
	[Parameter(Mandatory = $false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory = $false)]
	[switch]$DisableLogging = $false
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}

	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = ''
	[string]$appName = ''
	[string]$appVersion = ''
	[string]$appArch = ''
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.0'
	[string]$appScriptDate = 'XX/XX/20XX'
	[string]$appScriptAuthor = '<author name>'
	##*===============================================
	## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = 'Azure Active Directory Migration'
	[string]$installTitle = 'AAD Migration Utility'

	$MigrationConfig = Import-LocalizedData -BaseDirectory "C:\ProgramData\AADMigration\scripts\" -FileName "MigrationConfig.psd1"


	# Script variables
	$DomainLeaveUser = $MigrationConfig.DomainLeaveUser
	$DomainLeavePassword = $MigrationConfig.DomainLeavePass
	$TempUser = $MigrationConfig.TempUser
	$TempUserPassword = $MigrationConfig.TempPass
	$PPKGName = $MigrationConfig.ProvisioningPack
	$MigrationPath = $MigrationConfig.MigrationPath
	$DeferDeadline = $MigrationConfig.DeferDeadline
	$OneDriveKFM = $MigrationConfig.UseOneDriveKFM

	##* Do not modify section below
	#region DoNotModify

	## Variables: Exit Code
	[int32]$mainExitCode = 0

	## Variables: Script
	[string]$deployAppScriptFriendlyName = 'Deploy Application'
	[version]$deployAppScriptVersion = [version]'3.8.4'
	[string]$deployAppScriptDate = '26/01/2021'
	[hashtable]$deployAppScriptParameters = $psBoundParameters

	## Variables: Environment
	If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
	[string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

	## Dot source the required App Deploy Toolkit Functions
	Try {
		[string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
		If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
		If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
	}
	Catch {
		If ($mainExitCode -eq 0) { [int32]$mainExitCode = 60008 }
		Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
		## Exit the script, returning the exit code to SCCM
		If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
	}

	#endregion
	##* Do not modify section above
	##*===============================================
	##* END VARIABLE DECLARATION
	##*===============================================

	If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'

		#Check OneDrive Sync Status prior to prompting user.
		Start-Transcript -Path $MigrationPath\Logs\LaunchMigration.txt -Append -Force


		If ($OneDriveKFM) {

			Write-Output "OneDriveKFM flag is set to True. Checking Sync Status before continuing."

			#Check the most recent OD4B Sync status. Write error to event log if not healthy and exit
			Try {

				$Events = Get-EventLog -LogName Application -EntryType Information -Source 'AAD_Migration_Script'

				$LastEvent = $Events[0].InstanceId
				$LastEvent

			}
			Catch {

				Write-Output "No OneDrive Sync status found. Exiting migration utility; will retry on next logon."
				Exit 3

			}

			If ($LastEvent -eq 1337) {


				Write-Output "OneDrive Sync status is considered healthy, continuing."


			}
			Else {

				Write-Output "OneDrive sync status returned a value of $LastEvent. Migration will not launch at this time."
				Exit 2

			}

		}


		## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
		Show-InstallationWelcome -AllowDefer -DeferDeadline $DeferDeadline -PersistPrompt -ForceCountdown 600

		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Installation tasks here>



		##*===============================================
		##* INSTALLATION
		##*===============================================
		[string]$installPhase = 'Installation'

		## Handle Zero-Config MSI Installations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) { $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ } }
		}

		## <Perform Installation tasks here>
		#Start Transcription
		#Start Transcription
		# Start-Transcript -Path $MigrationPath\Logs\AD2AADJ.txt -NoClobber


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
		# $configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.json"
		# $env:MYMODULE_CONFIG_PATH = $configPath

		# $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

		#  Variables from JSON file
		# $CertPassword = $certsecrets.certexportpassword


		function Initialize-Environment {
			param (
				[string]$WindowsModulePath = "\EnhancedBoilerPlateAO\EnhancedBoilerPlateAO.psm1",
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
					$global:modulesBasePath = "C:\code\modulesv2"
					if (-Not (Test-Path $global:modulesBasePath)) {
						$global:modulesBasePath = "$PSScriptRoot\modulesv2"
					}
					if (-Not (Test-Path $global:modulesBasePath)) {
						$global:modulesBasePath = "$PSScriptRoot\modulesv2"
						Download-Modules -destinationPath $global:modulesBasePath
					}
				}
			}
		
			function Download-Modules {
				param (
					[string]$repoUrl = "https://github.com/aollivierre/modules/archive/refs/heads/main.zip",
					[string]$destinationPath
				)
		
				$timestamp = Get-Date -Format "yyyyMMddHHmmss"
				$tempExtractPath = "$env:TEMP\modulesv2-$timestamp"
				$zipPath = "$env:TEMP\modulesv2.zip"
		
				Write-Host "Downloading modules from GitHub..."
				Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath
				Expand-Archive -Path $zipPath -DestinationPath $tempExtractPath -Force
				Remove-Item -Path $zipPath
		
				$extractedFolder = Join-Path -Path $tempExtractPath -ChildPath "modules-main"
				if (Test-Path $extractedFolder) {
					Write-Host "Copying extracted modules to $destinationPath"
					robocopy $extractedFolder $destinationPath /E
					Remove-Item -Path $tempExtractPath -Recurse -Force
				}
		
				# $DBG
		
				Write-Host "Modules downloaded and extracted to $destinationPath"
			}
		
			function Setup-WindowsEnvironment {
				# Get the base paths from the global variables
				Setup-GlobalPaths
		
				# Construct the paths dynamically using the base paths
				$modulePath = Join-Path -Path $global:modulesBasePath -ChildPath $WindowsModulePath
		
				$global:modulePath = $modulePath
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
				$global:AOscriptDirectory = Convert-WindowsPathToLinuxPath -WindowsPath "$PSscriptroot"
				$global:directoryPath = Convert-WindowsPathToLinuxPath -WindowsPath "$PSscriptroot\Win32Apps-DropBox"
				$global:Repo_Path = Convert-WindowsPathToLinuxPath -WindowsPath "$PSscriptroot"
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
		
		
		try {
		
			# Check if C:\code\modules exists
			if (Test-Path "C:\code\modulesv2") {
				$ModulesFolderPath = Get-ModulesFolderPath -WindowsPath "C:\code\modulesv2" -UnixPath "/usr/src/code/modulesv2"
			}
			else {
				$ModulesFolderPath = Get-ModulesFolderPath -WindowsPath "$PsScriptRoot\modulesv2" -UnixPath "$PsScriptRoot/modulesv2"
			}
		
			Write-Host "Modules Folder Path: $ModulesFolderPath"
		
		}
		catch {
			Write-Error $_.Exception.Message
		}
		
		
		Write-Host "Starting to call Import-LatestModulesLocalRepository..."
		Import-ModulesFromLocalRepository -ModulesFolderPath $ModulesFolderPath -ScriptPath $PSScriptRoot
		
		###############################################################################################################################
		############################################### END MODULE LOADING ############################################################
		###############################################################################################################################
		try {
			# Ensure-LoggingFunctionExists -LoggingFunctionName "# Write-EnhancedLog"
			# Continue with the rest of the script here
			# exit
		}
		catch {
			Write-Host "Critical error: $_" -ForegroundColor Red
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
		InstallAndImportModulesPSGallery -modulePsd1Path "$PSScriptRoot/modules.psd1"
		
		$DBG

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

		$MainMigrateParams = @{
			# PPKGName   = "C:\code\CB\Entra\DeviceMigration\Files\ICTC_EJ_Bulk_Enrollment_v4\ICTC_EJ_Bulk_Enrollment_v5.ppkg"
			PPKGName   = "ICTC_EJ_Bulk_Enrollment_v5.ppkg"
			# DomainLeaveUser     = "YourDomainUser"
			# DomainLeavePassword = "YourDomainPassword"
			TempUser   = "MigrationInProgress"
			TempPass   = "Default1234"
			ScriptPath = "C:\ProgramData\AADMigration\Scripts\PostRunOnce.ps1"
		}

		Main-MigrateToAADJOnly @MainMigrateParams

		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'

		## <Perform Post-Installation tasks here>

		## Display a message at the end of the install
		If (-not $useDefaultMsi) { Show-InstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait }
	}
	ElseIf ($deploymentType -ieq 'Uninstall') {
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'

		## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'iexplore' -CloseAppsCountdown 60

		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Uninstallation tasks here>


		##*===============================================
		##* UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Uninstallation'

		## Handle Zero-Config MSI Uninstallations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat
		}

		# <Perform Uninstallation tasks here>


		##*===============================================
		##* POST-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'

		## <Perform Post-Uninstallation tasks here>


	}
	ElseIf ($deploymentType -ieq 'Repair') {
		##*===============================================
		##* PRE-REPAIR
		##*===============================================
		[string]$installPhase = 'Pre-Repair'

		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Repair tasks here>

		##*===============================================
		##* REPAIR
		##*===============================================
		[string]$installPhase = 'Repair'

		## Handle Zero-Config MSI Repairs
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Repair'; Path = $defaultMsiFile; }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat
		}
		# <Perform Repair tasks here>

		##*===============================================
		##* POST-REPAIR
		##*===============================================
		[string]$installPhase = 'Post-Repair'

		## <Perform Post-Repair tasks here>


	}
	##*===============================================
	##* END SCRIPT BODY
	##*===============================================

	## Call the Exit-Script function to perform final cleanup operations
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}
