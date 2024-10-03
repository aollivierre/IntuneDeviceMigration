param (
    [SecureString]$SecurePAT
)

$ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePAT)
$pat = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)



$params = @{
    MinVersion   = [version]"2.46.0"
    RegistryPath = "HKLM:\SOFTWARE\GitForWindows"
    ExePath      = "C:\Program Files\Git\bin\git.exe"
}
Ensure-GitIsInstalled @params

# Wait-Debugger

# Define paths and variables
$logsFolderPath = "C:\logs"
$tempCopyPath = "C:\temp-logs"
$tempGitPath = "C:\temp-git"
$tempZipFile = Join-Path -Path $tempGitPath -ChildPath "logs.zip"
$repoPath = "C:\temp-git\syslog"
$gitExePath = "C:\Program Files\Git\bin\git.exe" # Adjust if needed
$gitUsername = "aollivierre" # Your GitHub username
$personalAccessToken = $pat # Your GitHub PAT
# $repoUrl = "https://$gitUsername:$personalAccessToken@github.com/$gitUsername/syslog.git"
$repoUrl = "https://{0}:{1}@github.com/{2}/syslog.git" -f $gitUsername, $personalAccessToken, $gitUsername
$commitMessage = "Add logs.zip"
$branchName = "main" # Change if you're using a different branch name







# Remove tempGitPath if it exists
if (Test-Path -Path $tempGitPath) {
    Write-Host "Removing $tempGitPath..."
    Remove-Item -Path $tempGitPath -Recurse -Force
}
else {
    Write-Host "$tempGitPath does not exist, skipping removal."
}


# Ensure the temp directory exists
if (-Not (Test-Path -Path $tempGitPath)) {
    New-Item -Path $tempGitPath -ItemType Directory | Out-Null
}


# Remove-Item -Path $tempGitPath -Recurse -Force

# Zip the logs folder to the temp location
Write-Host "Zipping the logs folder..."


# Remove tempCopyPath if it exists
if (Test-Path -Path $tempCopyPath) {
    Write-Host "Removing $tempCopyPath..."
    Remove-Item -Path $tempCopyPath -Recurse -Force
}
else {
    Write-Host "$tempCopyPath does not exist, skipping removal."
}


# Ensure the destination directory exists
if (-not (Test-Path -Path $tempCopyPath)) {
    New-Item -Path $tempCopyPath -ItemType Directory
}

# Use the Copy-FilesWithRobocopy function to copy files
Copy-FilesWithRobocopy -Source $logsFolderPath -Destination $tempCopyPath -FilePattern '*' -Exclude ".git"

# Wait-Debugger

# Compress the copied files
# Compress-Archive -Path $tempCopyPath -DestinationPath $tempZipFile -Force

$params = @{
    SourceDirectory = $tempCopyPath
    ZipFilePath     = $tempZipFile
}
Zip-Directory @params


# Wait-Debugger

# Cleanup the temporary copy

# Remove tempCopyPath if it exists
if (Test-Path -Path $tempCopyPath) {
    Write-Host "Removing $tempCopyPath..."
    Remove-Item -Path $tempCopyPath -Recurse -Force
}
else {
    Write-Host "$tempCopyPath does not exist, skipping removal."
}



# Check if the zip file was created
if (-Not (Test-Path -Path $tempZipFile)) {
    Write-Host "Failed to zip the logs folder." -ForegroundColor Red
    exit 1
}

Set-Location -Path $tempGitPath

# Clone the repo if it doesn't exist
if (-Not (Test-Path -Path $repoPath)) {
    Write-Host "Cloning repository from $repoUrl..."
    & "$gitExePath" clone $repoUrl

    # Initialize a new git repository
    # & "$gitExePath" init

    # Add the remote repository
    # & "$gitExePath" remote add origin $repoUrl

}

# Wait-Debugger




#Region Creating the Destination Folder inside the Repo Folder
# Get the computer name
$computerName = $env:COMPUTERNAME
# $destFolder = Join-Path -Path $repoPath -ChildPath "$computerName-$currentDate"
# Define the folder for the computer name
$computerNameFolder = Join-Path -Path $repoPath -ChildPath "$computerName"

# Define the folder for the date inside the computer name folder
$currentDate = Get-Date -Format "yyyy-MM-dd"
$dateFolder = Join-Path -Path $computerNameFolder -ChildPath "$currentDate"

# Get the current time and format it like 7-08-AM or 7-08-PM
$currentTime = Get-Date -Format "h-mm-tt" # Example: 7-08-AM
$timeFolder = Join-Path -Path $dateFolder -ChildPath "$currentTime"

# Define the job name folder inside the timestamp folder
$jobname = 'AADMigration'
$jobFolder = Join-Path -Path $timeFolder -ChildPath "$jobname"

# Ensure the computer name folder exists
if (-Not (Test-Path -Path $computerNameFolder)) {
    New-Item -Path $computerNameFolder -ItemType Directory | Out-Null
}

# Ensure the date folder exists
if (-Not (Test-Path -Path $dateFolder)) {
    New-Item -Path $dateFolder -ItemType Directory | Out-Null
}

# Ensure the time folder exists inside the date folder
if (-Not (Test-Path -Path $timeFolder)) {
    New-Item -Path $timeFolder -ItemType Directory | Out-Null
}

# Ensure the job name folder exists inside the time folder
if (-Not (Test-Path -Path $jobFolder)) {
    New-Item -Path $jobFolder -ItemType Directory | Out-Null
}

# Now, $jobFolder is the destination folder
$destFolder = $jobFolder

# Wait-Debugger

#endregion Creating the Destination Folder inside the Repo Folder




# Create the folder named after the computer name, date, time and joba name
# if (-Not (Test-Path -Path $destFolder)) {
#     New-Item -Path $destFolder -ItemType Directory | Out-Null
# }

# Copy the zipped log file to the repository folder
Copy-Item -Path $tempZipFile -Destination $destFolder -Force

# Change to the repo directory
Set-Location -Path $repoPath

# Add, commit, and push the zipped log file
& "$gitExePath" add *
& "$gitExePath" commit -m "$commitMessage from $computerName on $currentDate"
& "$gitExePath" push origin $branchName

Write-Host "Zipped log file copied to $destFolder and pushed to the repository." -ForegroundColor Green


# Change to a location outside the $tempGitPath directory before deleting it
Set-Location -Path "C:\" # Change to any path that is not inside $tempGitPath

# Clean up the temp directory
Write-Host "Cleaning up the temp directory..."
Remove-Item -Path $tempGitPath -Recurse -Force

Write-Host "Process completed and temp directory cleaned up." -ForegroundColor Green