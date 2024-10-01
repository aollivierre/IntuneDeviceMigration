# Define GitHub repository details
$token = "PAT"
$repoOwner = "aollivierre"
$repoName = "Vault"
$releaseId = 177488507  # The release ID you retrieved earlier
$fileName = "ICTC_Project_2_Aug_29_2024.zip.aes.zip"

# Set headers for authentication
$headers = @{
    Authorization = "token $token"
    Accept = "application/vnd.github+json"
}

# GitHub API URL to get release details
$releaseUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases/$releaseId"

# Fetch the release information
$release = Invoke-RestMethod -Uri $releaseUrl -Headers $headers

# Find the asset by its name
$asset = $release.assets | Where-Object { $_.name -eq $fileName }

# If the asset is found, download it
if ($asset) {
    $downloadUrl = $asset.browser_download_url
    $destinationPath = "C:\temp\$fileName"
    
    # Download the file
    Invoke-WebRequest -Uri $downloadUrl -Headers $headers -OutFile $destinationPath
    Write-Host "File downloaded successfully: $fileName"
} else {
    Write-Host "Asset $fileName not found in the release."
}
