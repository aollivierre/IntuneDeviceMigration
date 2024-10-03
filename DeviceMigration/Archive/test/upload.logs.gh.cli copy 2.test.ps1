# Define the full path to GitHub CLI and Git executables
param (
    [string]$GhPath = "C:\Program Files\GitHub CLI\gh.exe",
    [string]$GitPath = "C:\Program Files\Git\bin\git.exe",
    [string]$LogsPath = "C:\Logs",
    [string]$RepoPath = "C:\temp-git\syslog",
    [string]$SyslogRepo = "aollivierre/syslog"
)

# Validate that $GhPath and $GitPath are valid paths to the executables
if (-not (Test-Path -Path $GhPath)) {
    Write-EnhancedLog -Message "GitHub CLI executable not found at $GhPath" -Level "ERROR"
    throw "GitHub CLI executable not found at $GhPath"
}
if (-not (Test-Path -Path $GitPath)) {
    Write-EnhancedLog -Message "Git executable not found at $GitPath" -Level "ERROR"
    throw "Git executable not found at $GitPath"
}

# Define the path to the secrets.psd1 file
$secretsPath = Join-Path -Path $PSScriptRoot -ChildPath "secrets.psd1"

# Check if the file exists
if (Test-Path -Path $secretsPath) {
    # Remove the file
    Remove-Item -Path $secretsPath -Force
    Write-Host "secrets.psd1 file found and removed."
} else {
    Write-Host "secrets.psd1 file not found."
}

# Remove temp folder if it exists
if (Test-Path -Path 'C:\temp-git') {
    Remove-Item -Path 'C:\temp-git' -Force -Recurse
    Write-Host "C:\temp-git folder found and removed."
} else {
    Write-Host "C:\temp-git folder not found."
}

# Logging the start of the script
Write-EnhancedLog -Message "Starting GitHub repository sync script" -Level "NOTICE"

# Authenticate with GitHub CLI (assuming Authenticate-GitHubCLI is defined elsewhere)
Authenticate-GitHubCLI -GhPath $GhPath -ScriptDirectory $PSScriptRoot

# Clone the full repository
$ghCloneSplat = @{
    GitPath = $GhPath
    Arguments = @("repo", "clone", $SyslogRepo, $RepoPath)
}
try {
    Invoke-GitCommandWithRetry @ghCloneSplat
    Write-EnhancedLog -Message "Cloned repository $SyslogRepo to $RepoPath" -Level "INFO"
} catch {
    Write-EnhancedLog -Message "Failed to clone the repository" -Level "ERROR"
    throw
}

# Copy the logs folder content to the cloned repository
$destinationLogsPath = Join-Path -Path $RepoPath -ChildPath "Logs"
if (-not (Test-Path -Path $destinationLogsPath)) {
    New-Item -ItemType Directory -Path $destinationLogsPath -Force
    Write-EnhancedLog -Message "Created folder: $destinationLogsPath" -Level "INFO"
}

# Copy logs to the repo Logs folder
Copy-Item -Recurse -Path "$LogsPath\*" -Destination $destinationLogsPath
Write-EnhancedLog -Message "Copied logs from $LogsPath to $destinationLogsPath" -Level "INFO"

# Stage the changes (use '.' to stage all files)
$gitAddSplat = @{
    GitPath = $GitPath
    Arguments = @("add", ".")
}

# Commit the changes with a message (ensuring message is properly quoted)
$gitCommitSplat = @{
    GitPath = $GitPath
    Arguments = @("commit", "-m", "`"Add Logs folder and files`"")
}

# Push the changes to the repository
$gitPushSplat = @{
    GitPath = $GitPath
    Arguments = @("push", "origin", "main")
}

# Try to add, commit, and push changes
try {
    Invoke-GitCommandWithRetry @gitAddSplat
    Write-EnhancedLog -Message "Staged changes in the repository" -Level "INFO"
    
    Invoke-GitCommandWithRetry @gitCommitSplat
    Write-EnhancedLog -Message "Committed changes to the repository" -Level "INFO"
    
    Invoke-GitCommandWithRetry @gitPushSplat
    Write-EnhancedLog -Message "Pushed changes to the repository" -Level "INFO"
} catch {
    Write-EnhancedLog -Message "Failed to push changes to the repository" -Level "ERROR"
    throw
}

# Return to the original directory
Set-Location -Path $LogsPath
Write-EnhancedLog -Message "Script completed successfully" -Level "NOTICE"

