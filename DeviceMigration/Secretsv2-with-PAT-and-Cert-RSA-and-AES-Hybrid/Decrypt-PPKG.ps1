# Step 1: Create necessary directories
$certsDir = "C:\temp\certs"
if (-not (Test-Path -Path $certsDir)) {
    New-Item -Path $certsDir -ItemType Directory
    Write-Host "Created directory: $certsDir"
}

# Step 2: Decode Base64-encoded certificate and save as .pfx
$base64Cert = Get-Content "C:\temp\certs\cert.pfx.base64"
$certBytes = [Convert]::FromBase64String($base64Cert)
$certPath = "C:\temp\certs\cert.pfx"
[System.IO.File]::WriteAllBytes($certPath, $certBytes)
Write-Host "Certificate restored at: $certPath"

# Step 3: Get the certificate password from the file
$certPassword = Get-Content "C:\temp\certpassword.txt"

# Step 4: Import the certificate with the private key using UserKeySet
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import($certPath, $certPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::UserKeySet)

if ($cert.HasPrivateKey) {
    Write-Host "The certificate's private key is accessible."
} else {
    Write-Host "The certificate's private key is not accessible."
    exit 1
}

# Step 5: Decode Base64-encoded AES key and IV
$base64Key = Get-Content "C:\temp\certs\secret.key.encrypted.base64"
$keyBytes = [Convert]::FromBase64String($base64Key)
$aesKeyFilePath = "C:\temp\secret.key.encrypted"
[System.IO.File]::WriteAllBytes($aesKeyFilePath, $keyBytes)
Write-Host "AES key and IV restored at: $aesKeyFilePath"

# Step 6: Read encrypted AES key and IV
$encryptedAESPackage = [System.IO.File]::ReadAllBytes($aesKeyFilePath)

# Step 7: Extract IV (first 16 bytes) and encrypted AES key (remaining bytes)
$iv = $encryptedAESPackage[0..15]
$encryptedAESKey = $encryptedAESPackage[16..($encryptedAESPackage.Length - 1)]

# Step 8: Decrypt the AES key using the certificate's private key with RSA-OAEP padding
$rsaProvider = $cert.PrivateKey -as [System.Security.Cryptography.RSACryptoServiceProvider]
if (-not $rsaProvider) {
    Write-Host "Unable to retrieve RSA private key from certificate."
    exit 1
}

try {
    $aesKey = $rsaProvider.Decrypt($encryptedAESKey, $true)  # Use $true for OAEP padding
    Write-Host "AES Key successfully decrypted."
} catch {
    Write-Host "AES key decryption failed: $($_.Exception.Message)"
    exit 1
}

# Step 9: Decrypt the original file using AES
# $encryptedFile = "C:\temp\secret.txt.encrypted"
$encryptedFile = "C:\temp\myDatabase.zip.encrypted"
$decryptedFile = "C:\temp\myDatabase.zip"

# Read encrypted file content
$encryptedContent = [System.IO.File]::ReadAllBytes($encryptedFile)

# Decrypt the file content using the AES key and IV
$aes = [System.Security.Cryptography.AesCryptoServiceProvider]::Create()
$aes.Key = $aesKey
$aes.IV = $iv
$decryptor = $aes.CreateDecryptor($aes.Key, $aes.IV)
$decryptedBytes = $decryptor.TransformFinalBlock($encryptedContent, 0, $encryptedContent.Length)

# Write the decrypted content to a new file
[System.IO.File]::WriteAllBytes($decryptedFile, $decryptedBytes)
Write-Host "Decrypted file saved to: $decryptedFile"
