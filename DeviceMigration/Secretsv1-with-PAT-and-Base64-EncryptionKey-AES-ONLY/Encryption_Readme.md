To encrypt and decrypt the PPKG file using PowerShell, you can use **AES (Advanced Encryption Standard)** encryption, which is a secure and commonly used method for encrypting files. In PowerShell, you can use the `System.Security.Cryptography` classes to perform encryption and decryption. Here's a step-by-step guide to encrypt and decrypt your PPKG file.

### Step 1: Encrypt the PPKG file

Let's start with encrypting the file using AES encryption. In this example, the file is located at `C:\ICTC_Project_2.ppkg`.

#### Encryption Script

```powershell
# Path to the PPKG file
$filePath = "C:\ICTC_Project_2.ppkg"

# Path to save the encrypted file
$encryptedFilePath = "C:\ICTC_Project_2.ppkg.aes"

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
```

#### What happens:
- This script encrypts the PPKG file using **AES-256**.
- It generates a random encryption key and initialization vector (IV). You will need both to decrypt the file.
- The **base64 encoded encryption key** is printed, which you can later store securely (e.g., in GitHub Secrets).
- The encrypted file is saved as `ICTC_Project_2.ppkg.aes`.

### Step 2: Decrypt the PPKG file

When you need to decrypt the file (for example, during a CI/CD pipeline), use the encryption key and the IV stored in the encrypted file.

#### Decryption Script

```powershell
# Path to the encrypted file
$encryptedFilePath = "C:\ICTC_Project_2.ppkg.aes"

# Path to save the decrypted file
$decryptedFilePath = "C:\ICTC_Project_2_decrypted.ppkg"

# Base64 encoded encryption key (retrieved from GitHub Secrets or similar)
$base64Key = "your_base64_key_here"  # Replace this with your actual base64 key

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
```

#### What happens:
- This script uses the **encryption key** (retrieved from GitHub Secrets or a similar vault) to decrypt the file.
- It extracts the **IV** from the beginning of the encrypted file.
- The decrypted file is saved as `ICTC_Project_2_decrypted.ppkg`.

### Summary of Steps:
1. **Encrypt the PPKG file** with AES encryption:
   - Generate a random key and IV.
   - Encrypt the file and store it as `.aes` (or any other preferred extension).
   - Save the encryption key in a secure location, like GitHub Secrets.

2. **Decrypt the PPKG file**:
   - Retrieve the encryption key from GitHub Secrets.
   - Decrypt the file using the key and the IV stored in the encrypted file.

### Security Considerations:
- **Encryption Key**: Store the key securely (in GitHub Secrets, Azure Key Vault, etc.). Never hardcode it in scripts or commit it to your repository.
- **Encryption Strength**: AES-256 is a strong encryption algorithm and widely used in practice.
- **IV Handling**: The IV is not secret and can be safely stored alongside the encrypted file, but it’s necessary for decryption.

This method ensures that your sensitive PPKG file is **securely encrypted** before uploading it to cloud storage and can be **decrypted** only with the key during your automated processes.

















The **Initialization Vector (IV)** is not stored in a separate file; instead, it's embedded as part of the **encrypted file itself**. Here's how the process works:

- **IV**: A 16-byte random value generated for each encryption operation, which is required for decryption. It is not secret, but it's needed to decrypt the file correctly.

### How the IV is Handled in the Encryption and Decryption Process:

#### In the Encryption Script:
- The **IV** is generated randomly and then prepended to the encrypted file.
- The encrypted file consists of two parts:
  1. **IV (first 16 bytes)**.
  2. **Encrypted data** (the remaining part of the file).

In the encryption script, you see this part:
```powershell
# Combine IV and encrypted content (IV is needed for decryption)
$encryptedFileContent = $iv + $encryptedStream.ToArray()

# Save the encrypted content (including IV) to a file
[IO.File]::WriteAllBytes($encryptedFilePath, $encryptedFileContent)
```

So, the resulting encrypted file (`ICTC_Project_2.ppkg.aes`) contains both the IV and the encrypted data, with the IV in the first 16 bytes.

#### In the Decryption Script:
- When decrypting, the first 16 bytes of the encrypted file are extracted as the **IV**.
- The rest of the file (after the first 16 bytes) is the actual encrypted data.

In the decryption script, you see this part:
```powershell
# Extract the IV from the first 16 bytes of the encrypted file
$iv = $encryptedFileContent[0..15]

# Extract the actual encrypted data (starting from byte 16 onwards)
$encryptedData = $encryptedFileContent[16..($encryptedFileContent.Length - 1)]
```

So, the **IV is included in the same file** as the encrypted data, and the decryption process retrieves the IV from the first 16 bytes.

### Why Embed the IV?
- This approach simplifies the process because you don’t need to manage a separate file for the IV.
- The IV is not secret, but it’s needed for decryption, and keeping it in the same file ensures it’s always available when decrypting.

### To Summarize:
- The **IV is embedded in the encrypted file** as the first 16 bytes.
- During decryption, the IV is extracted from those 16 bytes to decrypt the rest of the file.

You won’t need a separate file to store the IV — it’s handled automatically in the encrypted file itself!