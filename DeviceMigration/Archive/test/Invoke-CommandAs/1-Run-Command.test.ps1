# $WebClient = New-Object Net.WebClient
# $WebClient.DownloadString("https://raw.githubusercontent.com/mkellerman/Invoke-CommandAs/master/Invoke-CommandAs/Private/Invoke-ScheduledTask.ps1") | Set-Content -Path ".\Invoke-ScheduledTask.ps1"
# $WebClient.DownloadString("https://raw.githubusercontent.com/mkellerman/Invoke-CommandAs/master/Invoke-CommandAs/Public/Invoke-CommandAs.ps1") | Set-Content -Path ".\Invoke-CommandAs.ps1"

Import-Module -Name Invoke-CommandAs


Invoke-CommandAs -ScriptBlock {
    & "C:\code\IntuneDeviceMigration\DeviceMigration\PSAppDeployToolkit\Toolkit\Execute-PSADTConsole.ps1"
} -AsSystem
