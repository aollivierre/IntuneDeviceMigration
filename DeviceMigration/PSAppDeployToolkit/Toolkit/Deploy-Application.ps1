﻿<#
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

	iex ((irm "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1") -replace '\$Mode = "dev"', '$Mode = "dev"')

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

	# $MigrationConfig = Import-LocalizedData -BaseDirectory "C:\ProgramData\AADMigration\scripts\" -FileName "MigrationConfig.psd1"
	# $MigrationConfig = Import-LocalizedData -BaseDirectory "$PSScriptRoot" -FileName "MigrationConfig.psd1"

	# $MigrationConfig = Import-LocalizedData -BaseDirectory (Split-Path -Path $MigrationConfigPath) -FileName (Split-Path -Path $MigrationConfigPath -Leaf)
	# $MigrationConfig = Import-LocalizedData "C:\code\IntuneDeviceMigration\DeviceMigration\MigrationConfig.psd1"

	# $DBG


	# Script variables
	# $DomainLeaveUser = $MigrationConfig.DomainLeaveUser
	# $DomainLeavePassword = $MigrationConfig.DomainLeavePass
	# $TempUser = $MigrationConfig.TempUser
	# $TempUserPassword = $MigrationConfig.TempPass
	# $PPKGName = $MigrationConfig.ProvisioningPack
	# $MigrationPath = $MigrationConfig.MigrationPath
	# $DeferDeadline = $MigrationConfig.DeferDeadline
	# $OneDriveKFM = $MigrationConfig.UseOneDriveKFM


	# Configuration settings
	$MigrationPath = "C:\ProgramData\AADMigration"
	$UseOneDriveKFM = $True
	$InstallOneDrive = $True
	$TenantID = "b5dae566-ad8f-44e1-9929-5669f1dbb343" # ICTC Tenant ID
	$DeferDeadline = "07/12/2024 18:00:00" # July 12, 2024
	$DeferTimes = ""
	$TempUser = "MigrationInProgress"
	$TempPass = "Default1234"
	$ProvisioningPack = "C:\code\CB\Entra\DeviceMigration\Files\ICTC_EJ_Bulk_Enrollment_v4\ICTC_EJ_Bulk_Enrollment_v5.ppkg"

	# Script variables
	$DomainLeaveUser = $DomainLeaveUser
	$DomainLeavePassword = $DomainLeavePassword
	$PPKGName = $ProvisioningPack



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
		# Start-Transcript -Path $MigrationPath\Logs\LaunchMigration.txt -Append -Force


		
		function Get-TranscriptFilePath {
			try {
				# Log the start of the function
				Write-Host "Starting Get-TranscriptFilePath..." -ForegroundColor Cyan

				# Check if running as SYSTEM using Test-RunningAsSystem
				$isSystem = Test-RunningAsSystem
				Write-Host "Is running as SYSTEM: $isSystem" -ForegroundColor Yellow

				if ($isSystem) {
					# If running as SYSTEM, use hostname, job name, and timestamp
					$jobName = "AAD Migration"  # Replace with your actual job name
					$hostname = $env:COMPUTERNAME
					$timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
					$logFilePath = "C:\Logs\$hostname-$jobName-SYSTEM-transcript-$timestamp.log"
					Write-Host "Generated log file path for SYSTEM: $logFilePath" -ForegroundColor Green
				}
				else {
					# If not running as SYSTEM, use the calling function name
					$callStack = Get-PSCallStack
					$callerFunction = if ($callStack.Count -ge 2) { $callStack[1].Command } else { 'UnknownFunction' }
					$currentDate = Get-Date -Format "yyyy-MM-dd"
					$logFilePath = "C:\Logs\$callerFunction-transcript-$currentDate.log"
					Write-Host "Generated log file path for non-SYSTEM: $logFilePath" -ForegroundColor Green
				}

				# Ensure the log directory exists
				if (-not (Test-Path -Path (Split-Path $logFilePath -Parent))) {
					New-Item -Path (Split-Path $logFilePath -Parent) -ItemType Directory -Force
					Write-Host "Created directory for log file: $(Split-Path $logFilePath -Parent)" -ForegroundColor Green
				}

				return $logFilePath
			}
			catch {
				Write-Host "An error occurred in Get-TranscriptFilePath: $_" -ForegroundColor Red
				throw $_  # Re-throw the error after logging it
			}
		}



		# Start the script with error handling
		try {
			# Generate the transcript file path
			$transcriptPath = Get-TranscriptFilePath

			# Start the transcript
			Write-Host "Starting transcript at: $transcriptPath" -ForegroundColor Cyan
			Start-Transcript -Path $transcriptPath

			# Example script logic
			Write-Host "This is an example action being logged."

		}
		catch {
			Write-Host "An error occurred during script execution: $_" -ForegroundColor Red
		} 


		# If ($OneDriveKFM) {

		# 	Write-Output "OneDriveKFM flag is set to True. Checking Sync Status before continuing."

		# 	#Check the most recent OD4B Sync status. Write error to event log if not healthy and exit
		# 	Try {

		# 		$Events = Get-EventLog -LogName Application -EntryType Information -Source 'AAD_Migration_Script'

		# 		$LastEvent = $Events[0].InstanceId
		# 		$LastEvent

		# 	}
		# 	Catch {

		# 		Write-Output "No OneDrive Sync status found. Exiting migration utility; will retry on next logon."
		# 		Exit 3

		# 	}

		# 	If ($LastEvent -eq 1337) {


		# 		Write-Output "OneDrive Sync status is considered healthy, continuing."


		# 	}
		# 	Else {

		# 		Write-Output "OneDrive sync status returned a value of $LastEvent. Migration will not launch at this time."
		# 		Exit 2

		# 	}

		# }


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

		# Initialize the global steps list
		$global:steps = [System.Collections.Generic.List[PSCustomObject]]::new()
		$global:currentStep = 0

		$MainMigrateParams = @{
			# PPKGName   = "C:\code\CB\Entra\DeviceMigration\Files\ICTC_EJ_Bulk_Enrollment_v4\ICTC_EJ_Bulk_Enrollment_v5.ppkg"
			PPKGName         = "ICTC_EJ_Bulk_Enrollment_v5.ppkg"
			# DomainLeaveUser     = "YourDomainUser"
			# DomainLeavePassword = "YourDomainPassword"
			TempUser         = "MigrationInProgress"
			TempUserPassword = "Default1234"
			ScriptPath       = "C:\ProgramData\AADMigration\Scripts\PostRunOnce.ps1"
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
	Stop-Transcript
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}
