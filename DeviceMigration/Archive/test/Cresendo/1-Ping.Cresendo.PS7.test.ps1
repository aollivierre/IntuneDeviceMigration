# Import Crescendo module
# Import-Module Microsoft.PowerShell.Crescendo


# Get-Module -Name Microsoft.PowerShell.Crescendo -ListAvailable | Select-Object Name, Version, Path


# Get-Command -Module Microsoft.PowerShell.Crescendo



# Wait-Debugger

# Export the module based on the JSON configuration

$exportParams = @{
    ConfigurationFile = "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test\Cresendo\Ping.Cresendo.json"
    ModuleName        = "PingModule"
    Force             = $true
}

Export-CrescendoModule @exportParams


# Wait-Debugger


Import-Module "C:\code\IntuneDeviceMigration\PingModule.psm1"


# Run the ping command as a PowerShell cmdlet
Test-Connection "google.com" -Count 4