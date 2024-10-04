

$global:mode = $env:EnvironmentMode

#region FIRING UP MODULE STARTER
#################################################################################################
#                                                                                               #
#                                 FIRING UP MODULE STARTER                                      #
#                                                                                               #
#################################################################################################

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


#endregion FIRING UP MODULE STARTER


# # Define the path to the encrypted PAT file
$secureFilePath = "C:\temp\SecurePAT.txt"

# Ensure the file exists before attempting to read it
if (-not (Test-Path $secureFilePath)) {
    Write-EnhancedLog -Message"The encrypted PAT file does not exist!" -Level 'ERROR'
    exit 1
}

# # Read the encrypted PAT from the file and convert it back to a SecureString
# $SecurePAT = Get-Content -Path $secureFilePath | ConvertTo-SecureString

# # Now you can pass $SecurePAT to any function or use it as needed
# Write-EnhancedLog -Message "Successfully retrieved the encrypted PAT"






# Gather

# $SecurePAT = Get-GitHubPAT

# if ($null -ne $SecurePAT) {
#     # Continue with the secure PAT
#     Write-EnhancedLog -Message "Using the captured PAT..."
#     # Further logic here
# }
# else {
#     Write-EnhancedLog -Message "No PAT was captured."
# }


# if ($SecurePAT -is [System.Security.SecureString]) {
#     Write-Host "SecurePAT is a valid SecureString."
# } else {
#     Write-Host "SecurePAT is NOT a valid SecureString."
# }


# # Wait-Debugger


# # Key Gen

# # Generate a valid 256-bit (32-byte) key
# $key = (1..32 | ForEach-Object { Get-Random -Maximum 256 }) -join ','

# # Convert the key into a byte array
# $keyBytes = $key -split ',' | ForEach-Object { [byte]$_ }

# # Save the key as comma-separated values to a file
# $key | Out-File "C:\temp\SecureKey.txt"



#Encryption

# Convert the PAT to SecureString
# $SecurePAT = $SecurePAT | ConvertTo-SecureString -AsPlainText -Force

# Encrypt using the generated 256-bit key
# $EncryptedPAT = $SecurePAT | ConvertFrom-SecureString -Key $keyBytes

# Save the encrypted PAT to a file
# $EncryptedPAT | Out-File "C:\temp\SecurePAT.txt"



# Wait-Debugger



# Decryption

# Read the key from the file
$keyString = Get-Content "C:\temp\SecureKey.txt" -Raw

# Split the key string into an array of byte values
$key = $keyString -split ',' | ForEach-Object { [byte]$_ }

# Read the encrypted PAT from the file
$EncryptedPAT = Get-Content "C:\temp\SecurePAT.txt" -Raw

# Decrypt the SecurePAT using the key
$SecurePAT = $EncryptedPAT | ConvertTo-SecureString -Key $key

# Convert SecurePAT to plain text
$ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePAT)
$PersonalAccessToken = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)

# Check if it's successfully converted
if ($PersonalAccessToken) {
    Write-Host "Successfully converted to plain text."
} else {
    Write-Host "Failed to convert the SecureString."
}




# Now $SecurePAT is ready for use

Wait-Debugger


$params = @{
    SecurePAT      = $SecurePAT
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