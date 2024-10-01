# Define GitHub details
$token = "PAT"
$repoOwner = "aollivierre"
$repoName = "Vault"
$releaseTag = "0.1"

# Set headers for authentication
$headers = @{
    Authorization = "token $token"
    Accept = "application/vnd.github+json"
}

# GitHub API URL to list releases
$releasesUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases"

# Fetch the list of releases
$releases = Invoke-RestMethod -Uri $releasesUrl -Headers $headers

# Find the release with the specified tag
$release = $releases | Where-Object { $_.tag_name -eq $releaseTag }

# Output the release ID
if ($release) {
    $releaseId = $release.id
    Write-Host "Release ID for tag $releaseTag $releaseId"
} else {
    Write-Host "Release with tag $releaseTag not found."
}
