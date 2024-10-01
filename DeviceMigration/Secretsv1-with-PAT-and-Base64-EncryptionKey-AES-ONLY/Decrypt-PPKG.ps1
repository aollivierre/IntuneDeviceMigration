# Path to the encrypted file
$encryptedFilePath = "C:\ICTC_Project_2_Aug_29_2024.zip.aes"

# Path to save the decrypted file
$decryptedFilePath = "C:\ICTC_Project_2_Aug_29_2024.zip"

# Base64 encoded encryption key (retrieved from GitHub Secrets or similar)
# $base64Key = "your_base64_key_here"  # Replace this with your actual base64 key
$base64Key = "Yourkey"  # Replace this with your actual base64 key

# Convert the base64 key back to a byte array
$encryptionKey = [Convert]::FromBase64String($base64Key)

# Read the encrypted file content
$encryptedFileContent = [IO.File]::ReadAllBytes($encryptedFilePath)

# Extract the IV from the first 16 bytes of the encrypted file
$iv = $encryptedFileContent[0..15]

# Extract the actual encrypted data
$encryptedData = $encryptedFileContent[16..($encryptedFileContent.Length - 1)]

# Create AES object and configure it
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $encryptionKey
$aes.IV = $iv

# Create a decryptor object
$decryptor = $aes.CreateDecryptor()

# Create a memory stream to store the decrypted content
$decryptedStream = New-Object System.IO.MemoryStream

# Create a crypto stream to perform decryption
$cryptoStream = New-Object System.Security.Cryptography.CryptoStream($decryptedStream, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)

# Write the encrypted data to the crypto stream to decrypt it
$cryptoStream.Write($encryptedData, 0, $encryptedData.Length)
$cryptoStream.FlushFinalBlock()

# Get the decrypted data
$decryptedFileContent = $decryptedStream.ToArray()

# Save the decrypted content to a file
[IO.File]::WriteAllBytes($decryptedFilePath, $decryptedFileContent)

# Clean up
$cryptoStream.Dispose()
$decryptedStream.Dispose()
$aes.Dispose()

Write-Host "File decrypted and saved to: $decryptedFilePath"
