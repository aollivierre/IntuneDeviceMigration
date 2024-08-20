iex ((irm "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1") -replace '\$Mode = "dev"', '$Mode = "dev"')


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



# Start the process, wait for it to complete, and optionally hide the window
# Start-Process -FilePath "$Psscriptroot\Deploy-Application.exe" -Wait -WindowStyle Hidden

# Start-Process -FilePath "$PSScriptRoot\Deploy-Application.exe" -ArgumentList "-DeploymentType `"Install`" -DeployMode `"Interactive`"" -Wait -WindowStyle Hidden


# # Get the path to the installed PowerShell executable
# try {
#     $pwshPath = Get-PowerShellPath
#     Write-Host "PowerShell executable found at: $pwshPath"
    
#     # Example: Start a new PowerShell session using the found path
#     Start-Process -FilePath $pwshPath -ArgumentList "-NoProfile", "-Command", "Get-Process" -NoNewWindow -Wait
# }
# catch {
#     Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
# }

# $pwshPath = Get-PowerShellPath

# Define the path to the PowerShell executable
$pwshPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

# Define the path to the deploy-application.ps1 script
$scriptPath = "$PSScriptRoot\deploy-application.ps1"

# Define the arguments for the script
$arguments = '-NoExit -ExecutionPolicy Bypass -File "' + $scriptPath + '" -DeploymentType "Install" -DeployMode "Interactive"'

# Start the process without hiding the window
Start-Process -FilePath $pwshPath -ArgumentList $arguments -Wait