# Path to the PPKG file
# $filePath = "C:\ICTC_Project_2.ppkg"
$filePath = "C:\ICTC_Project_2_Aug_29_2024.zip"

# Path to save the encrypted file
$encryptedFilePath = "C:\ICTC_Project_2_Aug_29_2024.zip.aes"

# Generate a random AES encryption key (32 bytes for AES-256)
$encryptionKey = [byte[]](1..32 | ForEach-Object { Get-Random -Maximum 256 })

# Convert the encryption key to a base64 string (you can store this in GitHub Secrets later)
$base64Key = [Convert]::ToBase64String($encryptionKey)
Write-Host "Encryption Key (Base64): $base64Key"

# Generate a random initialization vector (IV) (16 bytes for AES)
$iv = [byte[]](1..16 | ForEach-Object { Get-Random -Maximum 256 })

# Open the original file and read its content
$fileContent = [IO.File]::ReadAllBytes($filePath)

# Create AES object and configure it
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $encryptionKey
$aes.IV = $iv

# Create an encryptor object
$encryptor = $aes.CreateEncryptor()

# Create a memory stream to store the encrypted content
$encryptedStream = New-Object System.IO.MemoryStream

# Create a crypto stream to perform encryption
$cryptoStream = New-Object System.Security.Cryptography.CryptoStream($encryptedStream, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)

# Write the file content to the crypto stream to encrypt it
$cryptoStream.Write($fileContent, 0, $fileContent.Length)
$cryptoStream.FlushFinalBlock()

# Combine IV and encrypted content (IV is needed for decryption)
$encryptedFileContent = $iv + $encryptedStream.ToArray()

# Save the encrypted content to a file
[IO.File]::WriteAllBytes($encryptedFilePath, $encryptedFileContent)

# Clean up
$cryptoStream.Dispose()
$encryptedStream.Dispose()
$aes.Dispose()

Write-Host "File encrypted and saved to: $encryptedFilePath"
