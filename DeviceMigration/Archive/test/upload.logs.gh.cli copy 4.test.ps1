# Define paths and variables
$logFilePath = "C:\logs.zip"
$repoPath = "C:\code\syslog"
$repoUrl = "https://github.com/aollivierre/syslog.git" # Your repo URL
$commitMessage = "Add logs.zip"
$branchName = "main" # Change if you're using a different branch name

# Check if logs.zip exists
if (-Not (Test-Path -Path $logFilePath)) {
    Write-Host "Log file not found at $logFilePath" -ForegroundColor Red
    exit 1
}

# Clone the repo if it doesn't exist
if (-Not (Test-Path -Path $repoPath)) {
    Write-Host "Cloning repository from $repoUrl..."
    git clone $repoUrl $repoPath
}

# Copy the log file to the repository
Copy-Item -Path $logFilePath -Destination $repoPath -Force

# Change to the repo directory
Set-Location -Path $repoPath

# Add, commit, and push the log file
git add logs.zip
git commit -m $commitMessage
git push origin $branchName

Write-Host "Log file copied and pushed to the repository." -ForegroundColor Green