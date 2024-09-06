iex ((irm "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1") -replace '\$Mode = "dev"', '$Mode = "dev"')


# Set-PSFConfig -Name 'PSFramework.Logging.Path' -Value 'C:\Logs\PSFramework' -Initialize

# Remove-PSFConfig -Name 'PSFramework.Logging.Path' -Module 'PSFramework'





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


Write-EnhancedLog -Message "This is a host message" -Level 'HOST'



# Define paths for SYSTEM profile and user profile log directories
$systemSourcePath = "C:\Windows\System32\config\systemprofile\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
# $userSourcePath = "$env:USERPROFILE\AppData\Roaming\WindowsPowerShell\PSFramework\Logs\"
$destinationPath = "C:\Logs\"

# Ensure the destination directory exists
if (-not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath -Force
}

# Copy logs from the SYSTEM profile path
if (Test-Path -Path $systemSourcePath) {
    try {
        Copy-Item -Path "$systemSourcePath*" -Destination $destinationPath -Recurse -Force -ErrorAction Stop
        Write-Host "SYSTEM profile log files successfully copied to $destinationPath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to copy SYSTEM profile logs. Error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "SYSTEM profile log path not found: $systemSourcePath" -ForegroundColor Yellow
}

# Verify that the files have been copied
if (Test-Path -Path $destinationPath) {
    Write-Host "Logs successfully processed to $destinationPath" -ForegroundColor Green
} else {
    Write-Host "Failed to process log files." -ForegroundColor Red
}


if (Test-Path -Path $systemSourcePath) {
    try {
        Remove-Item -Path "$systemSourcePath*" -Recurse -Force -ErrorAction Stop
        Write-Host "Logs successfully removed from $systemSourcePath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to remove logs. Error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Log path not found: $systemSourcePath" -ForegroundColor Yellow
}