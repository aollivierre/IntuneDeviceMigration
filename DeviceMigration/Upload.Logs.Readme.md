1. Input Parameters
   └── [SecureString] $SecurePAT
        └── Convert $SecurePAT to plain text using [System.Runtime.InteropServices.Marshal] methods

2. Ensure Git is Installed
   └── Params: 
        - MinVersion = 2.46.0
        - RegistryPath = HKLM:\SOFTWARE\GitForWindows
        - ExePath = C:\Program Files\Git\bin\git.exe
   └── Ensure-GitIsInstalled

3. Define Paths and Variables
   ├── $logsFolderPath = "C:\logs"
   ├── $tempCopyPath = "C:\temp-logs"
   ├── $tempGitPath = "C:\temp-git"
   ├── $tempZipFile = "C:\temp-git\logs.zip"
   ├── $repoPath = "C:\temp-git\syslog"
   ├── $gitExePath = "C:\Program Files\Git\bin\git.exe"
   ├── $gitUsername = "aollivierre"
   ├── $personalAccessToken = $pat
   ├── $repoUrl = GitHub repository URL using username and PAT
   ├── $commitMessage = "Add logs.zip"
   └── $branchName = "main"

4. System Info Gathering
   ├── Get $computerName (from environment)
   └── Get $currentDate (formatted as yyyy-MM-dd)

5. Clean Up Temp Paths (if exist)
   ├── Check if $tempGitPath exists
   └── Remove $tempGitPath if it exists
   ├── Check if $tempCopyPath exists
   └── Remove $tempCopyPath if it exists

6. Create Temp Paths
   ├── Ensure $tempGitPath exists (create if not)
   └── Ensure $tempCopyPath exists (create if not)

7. Copy Logs to Temp Folder
   └── Use Copy-FilesWithRobocopy to copy files from $logsFolderPath to $tempCopyPath (excluding .git)

8. Zip Logs
   └── Use Zip-Directory to compress $tempCopyPath into $tempZipFile

9. Check and Clean Up Temp Copy Path
   ├── If $tempZipFile does not exist, log error and exit
   └── Remove $tempCopyPath after zipping

10. Prepare Git Repository
   ├── Set Location to $tempGitPath
   └── Clone repository from $repoUrl if $repoPath does not exist

11. Copy Zipped Log File
   ├── Create $destFolder named after $computerName-$currentDate
   └── Copy $tempZipFile to $destFolder

12. Commit and Push Changes to GitHub
   ├── Set Location to $repoPath
   ├── Add all files to git
   ├── Commit with $commitMessage
   └── Push to remote repository branch $branchName

13. Clean Up
   ├── Change location to "C:\"
   └── Remove $tempGitPath directory

14. Completion
   └── Log completion and cleanup
