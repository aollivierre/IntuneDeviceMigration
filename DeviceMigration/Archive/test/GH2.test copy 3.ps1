# Define GitHub repository details
$token = "PAT"
$downloadUrl = "https://github.com/aollivierre/vault/releases/download/0.1/ICTC_Project_2_Aug_29_2024.zip.aes.zip"
$destinationPath = "C:\temp\ICTC_Project_2_Aug_29_2024.zip.aes.zip"

# Set headers for authentication
$headers = @{
    Authorization = "token $token"
    Accept = "application/vnd.github+json"
}

# Try to download the file
try {
    Invoke-WebRequest -Uri $downloadUrl -Headers $headers -OutFile $destinationPath
    Write-Host "File downloaded successfully: $destinationPath"
} catch {
    Write-Host "Error during download: $_"
}
