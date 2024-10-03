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

# Prompt for the decryption key (Base64 encoded)
$base64Key = Read-Host -Prompt "Enter the encryption key (Base64 encoded)"

# Direct download link for the attachment (no need for API call)
$downloadUrl = "https://github.com/user-attachments/files/17181466/ICTC_Project_2_Aug_29_2024.zip.aes.zip"

# Download the encrypted ZIP file
$localEncryptedZipPath = "C:\Temp\ICTC_Project_2_Aug_29_2024.zip.aes.zip"
Invoke-WebRequest -Uri $downloadUrl -OutFile $localEncryptedZipPath
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
