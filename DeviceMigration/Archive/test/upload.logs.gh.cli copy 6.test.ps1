# Define paths and variables
$logsFolderPath = "C:\logs"
$tempGitPath = "C:\temp-git"
$tempZipFile = Join-Path -Path $tempGitPath -ChildPath "logs.zip"
$repoPath = "C:\temp-git\syslog"
$repoUrl = "https://github.com/aollivierre/syslog.git" # Your repo URL
$commitMessage = "Add logs.zip"
$branchName = "main" # Change if you're using a different branch name
$gitPath = "C:\Program Files\Git\bin\git.exe" # Adjust if needed

# Get the computer name and current date
$computerName = $env:COMPUTERNAME
$currentDate = Get-Date -Format "yyyy-MM-dd"
$destFolder = Join-Path -Path $repoPath -ChildPath "$computerName-$currentDate"

# Ensure the temp directory exists
if (-Not (Test-Path -Path $tempGitPath)) {
    New-Item -Path $tempGitPath -ItemType Directory | Out-Null
}

# Zip the logs folder to the temp location
Write-Host "Zipping the logs folder..."
Compress-Archive -Path $logsFolderPath -DestinationPath $tempZipFile -Force

# Check if the zip file was created
if (-Not (Test-Path -Path $tempZipFile)) {
    Write-Host "Failed to zip the logs folder." -ForegroundColor Red
    exit 1
}

Set-Location -Path $tempGitPath

# Clone the repo if it doesn't exist
if (-Not (Test-Path -Path $repoPath)) {
    Write-Host "Cloning repository from $repoUrl..."
    $cloneArgs = "clone $repoUrl"
    Invoke-GitCommandWithRetry -GitPath $gitPath -Arguments $cloneArgs
}

# Create the folder named after the computer name and current date
if (-Not (Test-Path -Path $destFolder)) {
    New-Item -Path $destFolder -ItemType Directory | Out-Null
}

# Copy the zipped log file to the repository folder
Copy-Item -Path $tempZipFile -Destination $destFolder -Force

# Change to the repo directory
Set-Location -Path $repoPath

# Add, commit, and push the zipped log file
$addArgs = "add *"
Invoke-GitCommandWithRetry -GitPath $gitPath -Arguments $addArgs

$commitArgs = "commit -m '$commitMessage from $computerName on $currentDate'"
Invoke-GitCommandWithRetry -GitPath $gitPath -Arguments $commitArgs

$pushArgs = "push origin $branchName"
Invoke-GitCommandWithRetry -GitPath $gitPath -Arguments $pushArgs

Write-Host "Zipped log file copied to $destFolder and pushed to the repository." -ForegroundColor Green

# Clean up the temp directory
Write-Host "Cleaning up the temp directory..."
# Remove-Item -Path $tempGitPath -Recurse -Force

Write-Host "Process completed and temp directory cleaned up." -ForegroundColor Green