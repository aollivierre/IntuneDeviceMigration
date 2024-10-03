# Function to securely convert SecureString to plain text
function ConvertFrom-SecureStringToPlainText {
    param (
        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]$SecureString
    )
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

# Prompt for GitHub PAT (Personal Access Token)
$patSecure = Read-Host -Prompt "Enter your GitHub Personal Access Token (PAT)" -AsSecureString
$pat = ConvertFrom-SecureStringToPlainText -SecureString $patSecure

# Prompt for the decryption key (Base64 encoded)
$base64Key = Read-Host -Prompt "Enter the encryption key (Base64 encoded)"

# GitHub repository details
$repoOwner = "aollivierre"  # Replace with your GitHub username
$repoName = "Vault"    # Your private repo name
$releaseTag = "0.1"  # The tag for your release
$fileName = "ICTC_Project_2_Aug_29_2024.zip.aes.zip"  # Name of the uploaded ZIP in the release

# GitHub API URL to get the release body
$apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases/tags/$releaseTag"

# Headers to authenticate the API call
$headers = @{
    Authorization = "token $pat"
    Accept = "application/vnd.github.v3+json"
    UserAgent = "PowerShell"
}

# Fetch the release details, including the body
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers

# Extract the URL from the body (assuming the URL is enclosed in parentheses)
$downloadUrl = $response.body -match '\(https://.*\.zip\)' | Out-Null
$downloadUrl = $Matches[0].Trim('()')  # Extract URL from the match

# Add this line to print the extracted URL
Write-Host "Download URL: $downloadUrl"

if (-not $downloadUrl) {
    Write-Error "Download URL not found in the release body."
    exit 1
}


# Using curl instead of Invoke-WebRequest
$localEncryptedZipPath = "C:\Temp\ICTC_Project_2_Aug_29_2024.zip.aes.zip"
$downloadUrl = "https://github.com/user-attachments/files/17181466/ICTC_Project_2_Aug_29_2024.zip.aes.zip"

# Download the file using curl
Invoke-Expression -Command "curl -L -o `"$localEncryptedZipPath`" `"$downloadUrl`""

# Check if file exists
if (-not (Test-Path $localEncryptedZipPath)) {
    Write-Error "File download failed or the file does not exist."
    exit 1
}

Write-Host "Downloaded encrypted ZIP file to $localEncryptedZipPath"



# Step 1: Unzip the outer ZIP file
$outerUnzipPath = "C:\Temp\DecryptedOuter"
Expand-Archive -Path $localEncryptedZipPath -DestinationPath $outerUnzipPath
Write-Host "Extracted outer ZIP. Path: $outerUnzipPath"

# Find the encrypted AES file inside the extracted folder
$encryptedAESPath = Get-ChildItem -Path $outerUnzipPath -Filter "*.aes" | Select-Object -First 1

if (-not $encryptedAESPath) {
    Write-Error "No encrypted AES file found inside the outer ZIP."
    exit 1
}

# Step 2: Decrypt the AES file (which is a ZIP)
$encryptedFileContent = [IO.File]::ReadAllBytes($encryptedAESPath.FullName)

# Extract IV and encrypted data
$iv = $encryptedFileContent[0..15]
$encryptedData = $encryptedFileContent[16..($encryptedFileContent.Length - 1)]

# Convert the Base64 key to byte array
$encryptionKey = [Convert]::FromBase64String($base64Key)

# Create AES object
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $encryptionKey
$aes.IV = $iv

# Decrypt the data
$decryptor = $aes.CreateDecryptor()
$decryptedStream = New-Object System.IO.MemoryStream
$cryptoStream = New-Object System.Security.Cryptography.CryptoStream($decryptedStream, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
$cryptoStream.Write($encryptedData, 0, $encryptedData.Length)
$cryptoStream.FlushFinalBlock()

# Step 3: Save the decrypted ZIP file
$decryptedZipPath = "C:\Temp\Decrypted_Provisioning_Package.zip"
[IO.File]::WriteAllBytes($decryptedZipPath, $decryptedStream.ToArray())
Write-Host "Decrypted AES file to ZIP. Path: $decryptedZipPath"

# Step 4: Unzip the decrypted ZIP to access the provisioning package folder
$finalUnzipPath = "C:\Temp\Final_Provisioning_Package"
Expand-Archive -Path $decryptedZipPath -DestinationPath $finalUnzipPath
Write-Host "Final ZIP extracted. Path: $finalUnzipPath"

# You should now have the provisioning package folder with the PPKG file and other metadata
Write-Host "Provisioning package folder with PPKG file is located at $finalUnzipPath"
