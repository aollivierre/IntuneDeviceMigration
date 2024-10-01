# Define GitHub repository details
$token = "your PAT"
$repoOwner = "aollivierre"
$repoName = "Vault"
$releaseTag = "0.1"
$fileName = "ICTC_Project_2_Aug_29_2024.zip.aes.zip"
$destinationPath = "C:\temp\ICTC_Project_2_Aug_29_2024.zip.aes.zip"

# Set headers for authentication
$headers = @{
    Authorization = "token $token"
    Accept = "application/vnd.github+json"
}

# GitHub API URL to get release details
$releaseUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases"

# Fetch the list of releases
$releases = Invoke-RestMethod -Uri $releaseUrl -Headers $headers

# Find the release with the specified tag
$release = $releases | Where-Object { $_.tag_name -eq $releaseTag }

if ($release) {
    # Find the asset by name
    $asset = $release.assets | Where-Object { $_.name -eq $fileName }

    if ($asset) {
        $downloadUrl = $asset.url  # Get the asset's URL
        Write-Host "Asset found, starting download..."

        # Set the download headers
        $downloadHeaders = @{
            Authorization = "token $token"
            Accept = "application/octet-stream"
        }

        # Download the file
        Invoke-WebRequest -Uri $downloadUrl -Headers $downloadHeaders -OutFile $destinationPath
        Write-Host "File downloaded successfully: $fileName"
    } else {
        Write-Host "Asset $fileName not found in the release."
    }
} else {
    Write-Host "Release with tag $releaseTag not found."
}
