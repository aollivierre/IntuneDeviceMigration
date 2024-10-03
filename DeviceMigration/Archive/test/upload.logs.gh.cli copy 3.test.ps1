# Define the full path to GitHub CLI and Git executables
param (
    [string]$GhPath = "C:\Program Files\GitHub CLI\gh.exe",
    [string]$GitPath = "C:\Program Files\Git\bin\git.exe",
    [string]$ZipFilePath = "C:\logs.zip",
    [string]$RepoPath = "C:\temp-git\syslog",
    [string]$SyslogRepo = "aollivierre/syslog"
)

# Validate that $GhPath and $GitPath are valid paths to the executables
if (-not (Test-Path -Path $GhPath)) {
    Write-Host "GitHub CLI executable not found at $GhPath"
    throw "GitHub CLI executable not found at $GhPath"
}
if (-not (Test-Path -Path $GitPath)) {
    Write-Host "Git executable not found at $GitPath"
    throw "Git executable not found at $GitPath"
}

# Remove temp folder if it exists
if (Test-Path -Path 'C:\temp-git') {
    Remove-Item -Path 'C:\temp-git' -Force -Recurse
    Write-Host "C:\temp-git folder found and removed."
} else {
    Write-Host "C:\temp-git folder not found."
}

# Clone the repository
$ghCloneSplat = @{
    GitPath = $GhPath
    Arguments = @("repo", "clone", $SyslogRepo, $RepoPath)
}
try {
    Invoke-GitCommandWithRetry @ghCloneSplat
    Write-Host "Cloned repository $SyslogRepo to $RepoPath"
} catch {
    Write-Host "Failed to clone the repository"
    throw
}

# Copy the logs.zip file to the cloned repository
Copy-Item -Path $ZipFilePath -Destination $RepoPath
Write-Host "Copied $ZipFilePath to $RepoPath"

# Stage, commit, and push the changes using Git
$gitAddSplat = @{
    GitPath = $GitPath
    Arguments = @("add", ".")
}
$gitCommitSplat = @{
    GitPath = $GitPath
    Arguments = @("commit", "-m", "`"Add logs.zip file`"")
}
$gitPushSplat = @{
    GitPath = $GitPath
    Arguments = @("push", "origin", "main")
}

try {
    Invoke-GitCommandWithRetry @gitAddSplat
    Write-Host "Staged changes in the repository"
    
    Invoke-GitCommandWithRetry @gitCommitSplat
    Write-Host "Committed changes to the repository"
    
    Invoke-GitCommandWithRetry @gitPushSplat
    Write-Host "Pushed changes to the repository"
} catch {
    Write-Host "Failed to push changes to the repository"
    throw
}

Write-Host "Script completed successfully"