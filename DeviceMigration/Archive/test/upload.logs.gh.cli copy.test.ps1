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



# Check if the file exists
if (Test-Path -Path 'c:\temp-git') {
    # Remove the file
    Remove-Item -Path 'c:\temp-git' -Force -Recurse
    Write-Host "c:\temp-git file found and removed."
} else {
    Write-Host "c:\temp-git file not found."
}


# Convert paths to strings explicitly
$GhPath = [string]$GhPath
$GitPath = [string]$GitPath

# Logging the start of the script
Write-EnhancedLog -Message "Starting GitHub repository sync script" -Level "NOTICE"

# Authenticate with GitHub CLI (assuming Authenticate-GitHubCLI is defined elsewhere)
Authenticate-GitHubCLI -GhPath $GhPath -ScriptDirectory $PSScriptRoot

# Check if the $RepoPath directory exists; if not, create it
if (-not (Test-Path -Path $RepoPath)) {
    New-Item -ItemType Directory -Path $RepoPath -Force
    Write-EnhancedLog -Message "Created folder: $RepoPath" -Level "INFO"
} else {
    Write-EnhancedLog -Message "Folder already exists: $RepoPath" -Level "INFO"
}

# Clone the repository with sparse checkout using GitHub CLI
$ghCloneSplat = @{
    GitPath = $GhPath
    Arguments = @("repo", "clone", $SyslogRepo, $RepoPath, "--", "--depth", "1", "--sparse")
}
try {
    Invoke-GitCommandWithRetry @ghCloneSplat
    Write-EnhancedLog -Message "Cloned repository $SyslogRepo to $RepoPath" -Level "INFO"
} catch {
    Write-EnhancedLog -Message "Failed to clone the repository" -Level "ERROR"
    throw
}

# Navigate to the cloned repository
Set-Location -Path $RepoPath

# Initialize sparse-checkout and set the "Logs" folder
$gitSparseCheckoutSplat = @{
    GitPath = $GitPath
    Arguments = @("sparse-checkout", "init", "--cone")
}
$gitSparseCheckoutSetSplat = @{
    GitPath = $GitPath
    Arguments = @("sparse-checkout", "set", "Logs")
}

try {
    Invoke-GitCommandWithRetry @gitSparseCheckoutSplat
    Invoke-GitCommandWithRetry @gitSparseCheckoutSetSplat
    Write-EnhancedLog -Message "Initialized sparse checkout for Logs folder" -Level "INFO"
} catch {
    Write-EnhancedLog -Message "Failed to configure sparse checkout" -Level "ERROR"
    throw
}

# Ensure the subfolder exists before copying logs
if (-not (Test-Path -Path $RepoPath)) {
    New-Item -ItemType Directory -Path $RepoPath -Force
    Write-EnhancedLog -Message "Created subfolder: $RepoPath" -Level "INFO"
}

# Copy the logs folder content to the repository subdirectory (syslog)
Copy-Item -Recurse -Path "$LogsPath\*" -Destination $RepoPath
Write-EnhancedLog -Message "Copied logs from $LogsPath to $RepoPath" -Level "INFO"

# Stage, commit, and push the changes using Git
$gitAddSplat = @{
    GitPath = $GitPath
    Arguments = @("add", ".")
}
$gitCommitSplat = @{
    GitPath = $GitPath
    Arguments = @("commit", "-m", "Add Logs folder")
}
$gitPushSplat = @{
    GitPath = $GitPath
    Arguments = @("push", "origin", "main")
}

try {
    Invoke-GitCommandWithRetry @gitAddSplat
    Invoke-GitCommandWithRetry @gitCommitSplat
    Invoke-GitCommandWithRetry @gitPushSplat
    Write-EnhancedLog -Message "Pushed changes to the repository" -Level "INFO"
} catch {
    Write-EnhancedLog -Message "Failed to push changes to the repository" -Level "ERROR"
    throw
}

# Return to the original directory
Set-Location -Path $LogsPath
Write-EnhancedLog -Message "Script completed successfully" -Level "NOTICE"