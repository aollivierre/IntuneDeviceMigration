Import-Module 'C:\code\ModulesV2\EnhancedModuleStarterAO\EnhancedModuleStarterAO.psm1'

# Define a hashtable for splatting
$moduleStarterParams = @{
    Mode                   = 'dev'
    SkipPSGalleryModules   = $true
    SkipCheckandElevate    = $true
    SkipPowerShell7Install = $true
    SkipEnhancedModules    = $true
    SkipGitRepos           = $true
}

# Call the function using the splat
Invoke-ModuleStarter @moduleStarterParams

$Path = 'C:\temp\open.docx'

# # Identify processes locking the file using Sysinternals Handle or similar tool
# $lockingProcessesParams = @{
#     FilePath   = $Path
#     HandlePath = "C:\ProgramData\SystemTools\handle64.exe"
# }
# Get-LockingProcess @lockingProcessesParams



Manage-LockingProcesses -FilePath $Path -HandlePath "C:\ProgramData\SystemTools\handle64.exe"