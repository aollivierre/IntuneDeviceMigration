if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script! Please re-run the script as an Administrator."
    exit
}



# Load the module list from the .psd1 file
$moduleManifestPath = 'C:\code\IntuneDeviceMigration\DeviceMigration\modules.psd1'
$modulesToLoad = Import-PowerShellDataFile -Path $moduleManifestPath

# Create a GUID-stamped, time-stamped temporary folder
# $tempFolder = Join-Path -Path $env:TEMP -ChildPath ([guid]::NewGuid().ToString() + "_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
$tempFolder = Join-Path -Path 'c:\temp' -ChildPath ([guid]::NewGuid().ToString() + "_" + (Get-Date -Format "yyyyMMdd_HHmmss"))
New-Item -Path $tempFolder -ItemType Directory | Out-Null

# Save and load the modules to the temp folder
foreach ($module in $modulesToLoad.RequiredModules) {
    Write-Host "Checking availability of $module in the repository..."

    # Use Find-Module to check if the module is available
    $foundModule = Find-Module -Name $module -Repository PSGallery -ErrorAction SilentlyContinue

    if ($null -ne $foundModule) {
        Write-Host "$module is available. Proceeding to save..."
        
        # Save the module to the temporary folder from the PowerShell Gallery
        try {
            Write-Host "Saving $module to $tempFolder..."
            Save-Module -Name $module -Path $tempFolder -Force -ErrorAction Stop
            Write-Host "$module saved successfully to $tempFolder."
        }
        catch {
            Write-Warning "Failed to save $module. There was an issue saving the module."
            Write-Warning "Attempting to use Install-Module as a fallback..."
            
            # Fallback to Install-Module with -Scope AllUsers and -Force
            try {
                # Install-Module -Name $module -Scope AllUsers -Force -AllowClobber -ErrorAction Stop

                Ensure-NuGetProvider
                CheckAndElevate -ElevateIfNotAdmin $true
                Update-ModuleIfOldOrMissing -ModuleName $module

                Write-Host "$module installed successfully using Install-Module."
            }
            catch {
                Write-Warning "Failed to install $module using Install-Module. Skipping this module."
                continue
            }
        }

        # Import the module from the temp folder if it exists
        $modulePath = Join-Path -Path $tempFolder -ChildPath $module
        if (Test-Path $modulePath) {
            Write-Host "Importing module $module from $tempFolder..."
            try {
                Import-Module -Name $modulePath -ErrorAction Stop
                Write-Host "$module imported successfully from $tempFolder."
            }
            catch {
                Write-Warning "Failed to import $module. Some required files might be missing."
            }
        } else {
            Write-Warning "$module was not found in the temp folder after saving."
        }
    }
    else {
        Write-Warning "$module is not available in the repository. Skipping."
    }
}

# Clean up temp folder at the end
# Write-Host "Cleaning up temporary folder $tempFolder..."
# Remove-Item -Path $tempFolder -Recurse -Force

# Write-Host "Script finished."


# Your script logic here...

# Example usage
# try {
#     # $tempPath = Get-ReliableTempPath -LogLevel "INFO"
#     write-enhancedlog -Message "Temp Path Set To: $tempPath"
# }
# catch {
#     write-enhancedlog -Message "Failed to get a valid temp path: $_"
# }


# Clean up temp folder at the end
write-enhancedlog "Cleaning up temporary folder..."
# Remove-Item -Path $tempFolder -Recurse -Force

write-enhancedlog "Script finished."