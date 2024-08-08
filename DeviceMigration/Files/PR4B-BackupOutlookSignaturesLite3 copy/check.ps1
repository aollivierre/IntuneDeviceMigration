#Unique Tracking ID: e2ff1880-638d-4e28-a197-cca64a109f7a, Timestamp: 2024-03-07 15:36:15
# JSON string
$json = @'
{
    "PackageName": "PR4B_BackupOutlookSignature",
    "PackageUniqueGUID": "59538485-f73b-42b2-975d-3365aa81ec3b",
    "Version": 1,
    "PackageExecutionContext": "User",
    "RepetitionInterval": "PT60M",
    "LoggingDeploymentName": "PR4B_BackupOutlookSignatureCustomlog",
    "ScriptMode": "Remediation"
  }
'@

# Convert JSON string to a PowerShell object
$Config = $json | ConvertFrom-Json


# Assign values from JSON to variables
$PackageName = $config.PackageName
$PackageUniqueGUID = $config.PackageUniqueGUID
$Version = $config.Version
$ScriptMode = $config.ScriptMode



function Test-RunningAsSystem {
    $systemSid = New-Object System.Security.Principal.SecurityIdentifier "S-1-5-18"
    $currentSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User

    return $currentSid -eq $systemSid
}


function Set-LocalPathBasedOnContext {
    # Write-EnhancedLog -Message "Checking running context..." -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Cyan)
    if (Test-RunningAsSystem) {
        # Write-EnhancedLog -Message "Running as system, setting path to Program Files" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Yellow)
        return "$ENV:Programfiles\_MEM"
    }
    else {
        # Write-EnhancedLog -Message "Running as user, setting path to Local AppData" -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Yellow)
        return "$ENV:LOCALAPPDATA\_MEM"
    }
}


$global:Path_local = Set-LocalPathBasedOnContext



# Write-EnhancedLog -Message "calling Initialize-ScriptVariables" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)








<#
.SYNOPSIS
Initializes global script variables and defines the path for storing related files.

.DESCRIPTION
This function initializes global script variables such as PackageName, PackageUniqueGUID, Version, and ScriptMode. Additionally, it constructs the path where related files will be stored based on the provided parameters.

.PARAMETER PackageName
The name of the package being processed.

.PARAMETER PackageUniqueGUID
The unique identifier for the package being processed.

.PARAMETER Version
The version of the package being processed.

.PARAMETER ScriptMode
The mode in which the script is being executed (e.g., "Remediation", "PackageName").

.EXAMPLE
Initialize-ScriptVariables -PackageName "MyPackage" -PackageUniqueGUID "1234-5678" -Version 1 -ScriptMode "Remediation"

This example initializes the script variables with the specified values.

#>
function Initialize-ScriptVariables {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [Parameter(Mandatory = $true)]
        [string]$PackageUniqueGUID,

        [Parameter(Mandatory = $true)]
        [int]$Version,

        [Parameter(Mandatory = $true)]
        [string]$ScriptMode
    )

    # Assuming Set-LocalPathBasedOnContext and Test-RunningAsSystem are defined elsewhere
    # $global:Path_local = Set-LocalPathBasedOnContext

    # Default logic for $Path_local if not set by Set-LocalPathBasedOnContext
    if (-not $Path_local) {
        if (Test-RunningAsSystem) {
            $Path_local = "$ENV:ProgramFiles\_MEM"
        }
        else {
            $Path_local = "$ENV:LOCALAPPDATA\_MEM"
        }
    }

    $Path_PR = "$Path_local\Data\$PackageName-$PackageUniqueGUID"
    $schtaskName = "$PackageName - $PackageUniqueGUID"
    $schtaskDescription = "Version $Version"

    try {
        # Assuming Write-EnhancedLog is defined elsewhere
        #Write-EnhancedLog -Message "Initializing script variables..." -Level "INFO" -ForegroundColor ([System.ConsoleColor]::Green)

        # Returning a hashtable of all the important variables
        return @{
            PackageName        = $PackageName
            PackageUniqueGUID  = $PackageUniqueGUID
            Version            = $Version
            ScriptMode         = $ScriptMode
            Path_local         = $Path_local
            Path_PR            = $Path_PR
            schtaskName        = $schtaskName
            schtaskDescription = $schtaskDescription
        }
    }
    catch {
        Write-Error "An error occurred while initializing script variables: $_"
    }
}

# Invocation of the function and storing returned hashtable in a variable
# $initializationInfo = Initialize-ScriptVariables -PackageName "YourPackageName" -PackageUniqueGUID "YourGUID" -Version 1 -ScriptMode "YourMode"

# Call Initialize-ScriptVariables with splatting
$InitializeScriptVariablesParams = @{
    PackageName       = $PackageName
    PackageUniqueGUID = $PackageUniqueGUID
    Version           = $Version
    ScriptMode        = $ScriptMode
}

$initializationInfo = Initialize-ScriptVariables @InitializeScriptVariablesParams

$initializationInfo

$global:PackageName = $initializationInfo['PackageName']
$global:PackageUniqueGUID = $initializationInfo['PackageUniqueGUID']
$global:Version = $initializationInfo['Version']
$global:ScriptMode = $initializationInfo['ScriptMode']
$global:Path_local = $initializationInfo['Path_local']
$global:Path_PR = $initializationInfo['Path_PR']
$global:schtaskName = $initializationInfo['schtaskName']
$global:schtaskDescription = $initializationInfo['schtaskDescription']



# Check if the scheduled task exists and matches the version
$Task_existing = Get-ScheduledTask -TaskName $schtaskName -ErrorAction SilentlyContinue
if ($Task_existing -and $Task_existing.Description -like "Version $Version*") {
    Write-Host "Found it!"
    exit 0
} else {
    # Write-Host "Not Found!"
    exit 1
}
