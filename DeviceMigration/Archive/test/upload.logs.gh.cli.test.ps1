# Define the full path to GitHub CLI and Git executables
$ghPath = "C:\Program Files\GitHub CLI\gh.exe"
$gitPath = "C:\Program Files\Git\bin\git.exe"

# Define the paths to the directories and repository
$logsPath = "C:\Logs"
$repoPath = "C:\temp-git\syslog"
$syslogRepo = "aollivierre/syslog"
$repoSubfolder = "$repoPath"

# Authenticate with GitHub CLI (assuming Authenticate-GitHubCLI is defined elsewhere)
Authenticate-GitHubCLI -GhPath $ghPath -ScriptDirectory $PSScriptRoot

# Check if the $repoPath directory exists; if not, create it
if (-not (Test-Path -Path $repoPath)) {
    New-Item -ItemType Directory -Path $repoPath -Force
    Write-Host "Created folder: $repoPath"
} else {
    Write-Host "Folder already exists: $repoPath"
}

# Clone the repository with sparse checkout using GitHub CLI (Fix: separating git clone flags with '--')
& $ghPath repo clone $syslogRepo $repoPath -- --depth 1 --sparse

# Navigate to the cloned repository
Set-Location -Path $repoPath

# Initialize sparse-checkout and set the "Logs" folder
& $gitPath sparse-checkout init --cone
& $gitPath sparse-checkout set Logs

# Ensure the subfolder exists before copying logs
if (-not (Test-Path -Path $repoSubfolder)) {
    New-Item -ItemType Directory -Path $repoSubfolder -Force
    Write-Host "Created subfolder: $repoSubfolder"
}

# Copy the logs folder content to the repository subdirectory (syslog)
Copy-Item -Recurse -Path "$logsPath\*" -Destination $repoSubfolder

# Stage, commit, and push the changes using Git
& $gitPath add .
& $gitPath commit -m "Add Logs folder"
& $gitPath push origin main

# Return to the original directory
Set-Location -Path $logsPath
