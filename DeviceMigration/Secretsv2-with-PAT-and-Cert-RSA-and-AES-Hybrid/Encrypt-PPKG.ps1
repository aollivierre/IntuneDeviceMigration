# Step 1: Define paths and create the directory if it doesn't exist
$certPath = "C:\temp\certs"
if (-not (Test-Path -Path $certPath)) {
    New-Item -Path $certPath -ItemType Directory | Out-Null
}

$certFile = Join-Path $certPath "cert.pfx"

# Step 2: Generate a random password for the certificate
Add-Type -AssemblyName 'System.Web'
$certPassword = [System.Web.Security.Membership]::GeneratePassword(128, 2)

# Step 3: Output the password to the console
Write-Host "Generated Certificate Password: $certPassword" -ForegroundColor Green

# Step 4: Save the password to a text file in C:\temp
$passwordFilePath = "C:\temp\certPassword.txt"
$certPassword | Out-File -FilePath $passwordFilePath -Encoding UTF8



# Placeholder for certificate generation, export, and thumbprint retrieval
$certThumbprint = ""  # Add the logic for certificate generation and export here

# Example: Use $certPassword in certificate generation/export commands


# Create temp directory if it doesn't exist
if (-not (Test-Path $certPath)) {
    New-Item -Path $certPath -ItemType Directory
}

# Create a self-signed certificate and add it to the personal store
$cert = New-SelfSignedCertificate -CertStoreLocation "Cert:\CurrentUser\My" -Subject "CN=FileEncryptionCert" -KeyLength 2048 -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"
$certThumbprint = $cert.Thumbprint

# Export the certificate to PFX file (contains private key)
Export-PfxCertificate -Cert "Cert:\CurrentUser\My\$($cert.Thumbprint)" -FilePath $certFile -Password (ConvertTo-SecureString $certPassword -AsPlainText -Force)
Write-Host "Certificate generated and exported to: $certFile"

# Step 2: Encrypt the file with AES
# $secretFile = "C:\secret.txt"
$secretFile = "C:\code\secrets\myDatabase.zip"
$encryptedFile = "C:\temp\myDatabase.zip.encrypted"
$aes = [System.Security.Cryptography.AesCryptoServiceProvider]::Create()
$aes.KeySize = 256
$aes.GenerateKey()
$aes.GenerateIV()

# Read the file content and encrypt with AES
$plainTextBytes = [System.IO.File]::ReadAllBytes($secretFile)
$encryptor = $aes.CreateEncryptor($aes.Key, $aes.IV)
$encryptedBytes = $encryptor.TransformFinalBlock($plainTextBytes, 0, $plainTextBytes.Length)
[System.IO.File]::WriteAllBytes($encryptedFile, $encryptedBytes)

Write-Host "File encrypted with AES and saved to: $encryptedFile"

# Step 3: Encrypt the AES key with RSA using the certificate
$rsa = [System.Security.Cryptography.RSACryptoServiceProvider]::new()
$rsa.ImportParameters($cert.PublicKey.Key.ExportParameters($false))
$encryptedAESKey = $rsa.Encrypt($aes.Key, $true) # Encrypt the AES key with RSA

# Save the encrypted AES key and IV to file
$encryptedKeyFile = "C:\temp\secret.key.encrypted"
$encryptedAESPackage = $aes.IV + $encryptedAESKey
[System.IO.File]::WriteAllBytes($encryptedKeyFile, $encryptedAESPackage)

Write-Host "AES key encrypted with RSA and saved to: $encryptedKeyFile"

# Step 4: Display a summary of actions
Write-Host "`nSummary of Actions:"
Write-Host "Certificate stored at: $certFile"
Write-Host "Certificate Password saved to: $passwordFilePath" -ForegroundColor Yellow
Write-Host "Encrypted file saved at: $encryptedFile"
Write-Host "Encrypted AES key and IV saved at: $encryptedKeyFile"

# Step 5: Convert certificate to Base64 for GitHub Secrets
$certBytes = [System.IO.File]::ReadAllBytes($certFile)
$base64Cert = [Convert]::ToBase64String($certBytes)
$base64CertFile = Join-Path $certPath "cert.pfx.base64"
[System.IO.File]::WriteAllText($base64CertFile, $base64Cert)

Write-Host "Certificate Base64 encoded and saved to: $base64CertFile"


# Step 6: Convert Encrypted AES Key and IV (secret.key.encrypted) to Base64 for GitHub Secrets

# Path to the encrypted AES key and IV file
$keyFilePath = "C:\temp\secret.key.encrypted"

# Read the binary contents of the file
$keyBytes = [System.IO.File]::ReadAllBytes($keyFilePath)

# Convert the binary data to Base64
$base64Key = [Convert]::ToBase64String($keyBytes)

# Save the Base64-encoded data to a new file
$base64KeyFile = "C:\temp\certs\secret.key.encrypted.base64"
[System.IO.File]::WriteAllText($base64KeyFile, $base64Key)

# Output a message indicating where the Base64-encoded key was saved
Write-Host "Encrypted AES Key and IV (secret.key.encrypted) Base64 encoded and saved to: $base64KeyFile"