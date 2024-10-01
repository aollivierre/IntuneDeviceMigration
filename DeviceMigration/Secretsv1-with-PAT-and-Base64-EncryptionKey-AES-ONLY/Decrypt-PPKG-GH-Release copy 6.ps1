

# Function to securely convert SecureString to plain text
function ConvertFrom-SecureStringToPlainText {
    param (
        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]$SecureString
    )
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr)
    }
    finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

# Function to retrieve secrets (GitHub PAT and Decryption Key) from secrets.psd1
function Get-Secrets {
    $secretsFilePath = Join-Path -Path $PSScriptRoot -ChildPath "secrets.psd1"

    if (-not (Test-Path -Path $secretsFilePath)) {
        Write-Warning "Secrets file not found. Please enter your GitHub token and decryption key."

        # Prompt for GitHub PAT and Decryption Key
        $gitHubToken = Read-Host "Enter your GitHub Personal Access Token (PAT)" -AsSecureString
        $decryptionKey = Read-Host "Enter the decryption key (Base64 encoded)" -AsSecureString

        # Store them securely in secrets.psd1
        $secretsContent = @{
            GitHubToken   = $gitHubToken | ConvertFrom-SecureString
            DecryptionKey = $decryptionKey | ConvertFrom-SecureString
        }

        $secretsContent | Export-Clixml -Path $secretsFilePath
        Write-Host "Secrets have been saved securely to $secretsFilePath."

        # Return the secrets
        return $secretsContent
    }
    else {
        # If secrets file exists, load it
        return Import-Clixml -Path $secretsFilePath
    }
}

# Retrieve the secrets
$secrets = Get-Secrets

# Convert GitHub PAT and Decryption Key back to plain text
$patSecure = $secrets.GitHubToken | ConvertTo-SecureString
$decryptionKeySecure = $secrets.DecryptionKey | ConvertTo-SecureString

# Convert secure string to plain text for use in the script
$pat = ConvertFrom-SecureStringToPlainText -SecureString $patSecure
$base64Key = ConvertFrom-SecureStringToPlainText -SecureString $decryptionKeySecure



# GitHub repository details
$repoOwner = "aollivierre"
$repoName = "Vault"
$releaseTag = "0.1"
$fileName = "ICTC_Project_2_Aug_29_2024.zip.aes.zip"

# Headers for GitHub API request using the stored PAT
$headers = @{
    Authorization = "token $pat"
    Accept        = "application/vnd.github+json"
    UserAgent     = "PowerShell"
}

# GitHub API URL to get the release details by tag
$apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases"

# Fetch the release details
$releases = Invoke-RestMethod -Uri $apiUrl -Headers $headers

# Find the release with the specified tag
$release = $releases | Where-Object { $_.tag_name -eq $releaseTag }

if (-not $release) {
    Write-Error "Release with tag $releaseTag not found."
    exit 1
}

# Find the asset by name
$asset = $release.assets | Where-Object { $_.name -eq $fileName }

if (-not $asset) {
    Write-Error "Asset $fileName not found in the release."
    exit 1
}

# Set download URL and download the asset
$downloadUrl = $asset.url
Write-Host "Download URL: $downloadUrl"

# Set the download headers for binary data
$downloadHeaders = @{
    Authorization = "token $pat"
    Accept        = "application/octet-stream"
}

# Download the file to the temp directory
$localEncryptedZipPath = "C:\Temp\ICTC_Project_2_Aug_29_2024.zip.aes.zip"

try {
    Invoke-WebRequest -Uri $downloadUrl -Headers $downloadHeaders -OutFile $localEncryptedZipPath
    Write-Host "File downloaded successfully to: $localEncryptedZipPath"
} catch {
    Write-Error "File download failed. Error: $_"
    exit 1
}

# Check if the file exists after the download
if (-not (Test-Path $localEncryptedZipPath)) {
    Write-Error "File download failed or the file does not exist."
    exit 1
}

# Step 1: Unzip the outer ZIP file
$outerUnzipPath = "C:\Temp\DecryptedOuter"
Expand-Archive -Path $localEncryptedZipPath -DestinationPath $outerUnzipPath
Write-Host "Extracted outer ZIP. Path: $outerUnzipPath"

# Step 2: Decrypt the AES file (which is a ZIP)
$encryptedAESPath = Get-ChildItem -Path $outerUnzipPath -Filter "*.aes" | Select-Object -First 1

if (-not $encryptedAESPath) {
    Write-Error "No encrypted AES file found inside the outer ZIP."
    exit 1
}

$encryptedFileContent = [IO.File]::ReadAllBytes($encryptedAESPath.FullName)
$iv = $encryptedFileContent[0..15]
$encryptedData = $encryptedFileContent[16..($encryptedFileContent.Length - 1)]

$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = [Convert]::FromBase64String($base64Key)
$aes.IV = $iv

$decryptor = $aes.CreateDecryptor()
$decryptedStream = New-Object System.IO.MemoryStream
$cryptoStream = New-Object System.Security.Cryptography.CryptoStream($decryptedStream, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
$cryptoStream.Write($encryptedData, 0, $encryptedData.Length)
$cryptoStream.FlushFinalBlock()

$decryptedZipPath = "C:\Temp\Decrypted_Provisioning_Package.zip"
[IO.File]::WriteAllBytes($decryptedZipPath, $decryptedStream.ToArray())
Write-Host "Decrypted AES file to ZIP. Path: $decryptedZipPath"

# Step 3: Unzip the decrypted ZIP
$finalUnzipPath = "C:\Temp\Final_Provisioning_Package"
Expand-Archive -Path $decryptedZipPath -DestinationPath $finalUnzipPath
Write-Host "Final ZIP extracted. Path: $finalUnzipPath"

Wait-Debugger


# Cleanup script to remove temporary files and directories
function Cleanup-TempFiles {
    # Define paths for the files and directories to remove
    $filesToRemove = @(
        "C:\Temp\ICTC_Project_2_Aug_29_2024.zip.aes.zip",  # Encrypted ZIP file
        "C:\Temp\Decrypted_Provisioning_Package.zip"       # Decrypted ZIP file
    )

    $directoriesToRemove = @(
        "C:\Temp\DecryptedOuter",                          # Extracted outer directory
        "C:\Temp\Final_Provisioning_Package"               # Final extracted provisioning package
    )

    # Remove files
    foreach ($file in $filesToRemove) {
        if (Test-Path $file) {
            Remove-Item $file -Force
            Write-Host "Deleted file: $file"
        } else {
            Write-Host "File not found: $file"
        }
    }

    # Remove directories
    foreach ($dir in $directoriesToRemove) {
        if (Test-Path $dir) {
            Remove-Item $dir -Recurse -Force
            Write-Host "Deleted directory: $dir"
        } else {
            Write-Host "Directory not found: $dir"
        }
    }
}

# Call the cleanup function
Cleanup-TempFiles

