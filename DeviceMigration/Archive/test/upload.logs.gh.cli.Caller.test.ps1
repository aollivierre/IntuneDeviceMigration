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


$SecurePAT = Read-Host "Please enter your GitHub Personal Access Token (PAT)" -AsSecureString
# & "$PSScriptRoot\upload.logs.gh.cli.working copy2.ps1" -SecurePAT $SecurePAT

$params = @{
    SecurePAT      = $securePat
    GitExePath     = "C:\Program Files\Git\bin\git.exe"
    LogsFolderPath = "C:\logs"
    TempCopyPath   = "C:\temp-logs"
    TempGitPath    = "C:\temp-git"
    GitUsername    = "aollivierre"
    BranchName     = "main"
    CommitMessage  = "Add logs.zip"
    RepoName       = "syslog"
    JobName        = "AADMigration"
}

Upload-LogsToGitHub @params