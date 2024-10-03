function Authenticate-GitHubAPI {
    param (
        [string]$ApiUrl = "https://api.github.com"
    )

    begin {
        Write-Host "Starting Authenticate-GitHubAPI function"
    }

    process {
        # Define the secrets file path
        $secretsFilePath = Join-Path -Path $PSScriptRoot -ChildPath "secrets.psd1"

        if (-not (Test-Path -Path $secretsFilePath)) {
            # If the secrets file does not exist, prompt the user to enter the token
            Write-Warning "Secrets file not found. Please enter your GitHub token."
            $secureToken = Read-Host "Enter your GitHub token" -AsSecureString

            # Store the token securely in the secrets.psd1 file
            $secretsContent = @{
                GitHubToken = $secureToken | ConvertFrom-SecureString
            }
            $secretsContent | Export-Clixml -Path $secretsFilePath
            Write-Host "GitHub token has been saved securely to $secretsFilePath."
        }
        else {
            # If the secrets file exists, import it
            $secrets = Import-Clixml -Path $secretsFilePath
            $secureToken = $secrets.GitHubToken | ConvertTo-SecureString

            if (-not $secureToken) {
                $errorMessage = "GitHub token not found in the secrets file."
                Write-Host $errorMessage
                throw $errorMessage
            }

            Write-Host "Using GitHub token from secrets file for authentication."
        }

        # Convert secure string back to plain text for GitHub API authentication
        $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
        $token = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)

        # Check authentication by calling GitHub API
        $headers = @{
            Authorization = "token $token"
            Accept = "application/vnd.github.v3+json"
            'User-Agent' = 'PowerShell'
        }

        $authResponse = Invoke-RestMethod -Uri "$ApiUrl/user" -Headers $headers -Method Get

        if ($authResponse -and $authResponse.login) {
            Write-Host "Successfully authenticated as $($authResponse.login)"
        }
        else {
            $errorMessage = "Failed to authenticate with GitHub API. Please check the token and try again."
            Write-Host $errorMessage
            throw $errorMessage
        }
    }

    end {
        Write-Host "Authenticate-GitHubAPI function execution completed."
    }
}

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

# GitHub API URL to get the release body
$apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases/tags/$releaseTag"

# Headers for GitHub API request
$headers = @{
    Authorization = "token $pat"
    Accept        = "application/vnd.github.v3+json"
    UserAgent     = "PowerShell"
}

# Fetch the release details
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers

# Extract the download URL from the release body
$downloadUrl = $response.body -match '\(https://.*\.zip\)' | Out-Null
$downloadUrl = $Matches[0].Trim('()')  # Extract URL from the match

Write-Host "Download URL: $downloadUrl"

if (-not $downloadUrl) {
    Write-Error "Download URL not found in the release body."
    exit 1
}

# Download the file using Invoke-WebRequest instead of curl
$localEncryptedZipPath = "C:\Temp\ICTC_Project_2_Aug_29_2024.zip.aes.zip"

# Use Invoke-WebRequest for downloading the file
Invoke-WebRequest -Uri $downloadUrl -Headers $headers -OutFile $localEncryptedZipPath

# Check if the file exists after the download
if (-not (Test-Path $localEncryptedZipPath)) {
    Write-Error "File download failed or the file does not exist."
    exit 1
}


Write-Host "Downloaded encrypted ZIP file to $localEncryptedZipPath"

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
$encryptionKey = [Convert]::FromBase64String($base64Key)

$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Key = $encryptionKey
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


