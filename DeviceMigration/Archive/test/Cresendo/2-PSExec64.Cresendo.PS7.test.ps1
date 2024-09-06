# Import Crescendo module
# Import-Module Microsoft.PowerShell.Crescendo


# Get-Module -Name Microsoft.PowerShell.Crescendo -ListAvailable | Select-Object Name, Version, Path


# Get-Command -Module Microsoft.PowerShell.Crescendo



# Wait-Debugger

# Export the module based on the JSON configuration

$exportParams = @{
    # ConfigurationFile = "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test\Cresendo\Invoke-PsExec.crescendo-v2.json"
    ConfigurationFile = "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test\Cresendo\Invoke-PsExec.crescendo.json"
    ModuleName        = "PSExecModule"
    Force             = $true
}

Export-CrescendoModule @exportParams


# Wait-Debugger


Import-Module "C:\code\IntuneDeviceMigration\PSExecModule.psm1"

# Running PsExec locally with a simple command
# Invoke-PsExec -ComputerName 'localhost' -Command 'cmd.exe' -Args '/c echo Hello World' -Verbose

# PsExec64.exe \\localhost cmd.exe /c echo Hello World


# Invoke-PsExec -Command "-accepteula -i -s -d whoami" -Args "cmd.exe" -Verbose
# Invoke-PsExec -Command "cmd.exe" -Args "whoami" -Verbose
# Invoke-PsExec -Command "powershell.exe" -Args "whoami" -Verbose
# Invoke-PsExec -Command "whoami" -Args "/upn"

# Invoke-PsExec -Command "whoami" -Args "`"$ScriptPathAsSYSTEM`""

$ScriptPathAsSYSTEM = "C:\code\IntuneDeviceMigration\DeviceMigration\PSAppDeployToolkit\Toolkit\Execute-PSADTConsole.ps1"

Invoke-PsExec -Args "`"$ScriptPathAsSYSTEM`""


# Invoke-PsExec -ComputerName 'localhost'

# Invoke-PsExec -ComputerName 'localhost' -Command 'cmd.exe'


# Invoke-PsExec -ComputerName 'localhost' -Command 'cmd.exe' -Args '/c echo Hello World' -ExecutablePath "C:\ProgramData\SystemTools\PsExec64.exe"


# Example: Running a remote command on another machine
# Invoke-PsExec -ComputerName 'RemotePC01' -Command 'powershell.exe' -Args '-NoProfile -ExecutionPolicy Bypass -File C:\Scripts\RemoteTask.ps1'



# function Invoke-MockPsExec {
#     param (
#         [string]$ComputerName = "localhost",
#         [string]$Command = "cmd.exe",
#         [string]$Args = "/c echo Hello World"
#     )

#     # Mock the behavior by echoing the constructed command (simulating Crescendo)
#     $fullCommand = "PsExec64.exe \\$ComputerName $Command $Args"
#     Write-Host "Simulating Crescendo by running: $fullCommand"

#     # Optionally, simulate execution by running the constructed command
#     # Using Start-Process or Invoke-Expression
#     Start-Process -FilePath "PsExec64.exe" -ArgumentList "\\$ComputerName $Command $Args" -NoNewWindow -Wait
# }


# Invoke-MockPsExec -ComputerName 'localhost' -Command 'cmd.exe' -Args '/c echo Simulating Crescendo'

