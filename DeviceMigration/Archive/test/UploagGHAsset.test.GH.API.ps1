# Import-Module 'C:\code\ModulesV2\EnhancedModuleStarterAO\EnhancedModuleStarterAO.psm1'

# Define a hashtable for splatting
# $moduleStarterParams = @{
#     Mode                   = 'dev'
#     SkipPSGalleryModules   = $true
#     SkipCheckandElevate    = $true
#     SkipPowerShell7Install = $true
#     SkipEnhancedModules    = $true
#     SkipGitRepos           = $true
# }

# Call the function using the splat
# Invoke-ModuleStarter @moduleStarterParams



# $params = @{
#     Token      = "PAT"
#     RepoOwner  = "aollivierre"
#     RepoName   = "Vault"
#     ReleaseTag = "0.1"
#     FilePath   = "C:\temp2\vault.GH.Asset.zip"
# }
# Upload-GitHubReleaseAsset @params


# Define GitHub repository details
$token = "PAT"
$repoOwner = "aollivierre"
$repoName = "Vault"
$releaseTag = "0.1"
$filePath = "C:\temp2\vault.GH.Asset.zip"

# Log Start of Script
Write-Host "Starting GitHub Asset Upload Script" -ForegroundColor Cyan

# Check if the file exists
try {
    Write-Host "Checking if file exists: $filePath" -ForegroundColor Yellow
    if (-not (Test-Path -Path $filePath)) {
        throw "File does not exist: $filePath"
    }
    Write-Host "File exists: $filePath" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# Set headers for GitHub authentication
try {
    Write-Host "Setting up headers for GitHub authentication" -ForegroundColor Yellow
    $headers = @{
        Authorization = "token $token"
        Accept        = "application/vnd.github+json"
    }
    Write-Host "Headers set successfully" -ForegroundColor Green
}
catch {
    Write-Host "Error setting headers: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# GitHub API URL to get release details
$releaseUrl = "https://api.github.com/repos/$repoOwner/$repoName/releases"
Write-Host "GitHub release URL: $releaseUrl" -ForegroundColor Yellow

# Fetch the list of releases
try {
    Write-Host "Fetching list of releases..." -ForegroundColor Yellow
    $releases = Invoke-RestMethod -Uri $releaseUrl -Headers $headers
    Write-Host "Successfully fetched releases." -ForegroundColor Green
}
catch {
    Write-Host "Failed to fetch releases: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# Find the release with the specified tag
try {
    Write-Host "Searching for release with tag: $releaseTag" -ForegroundColor Yellow
    $release = $releases | Where-Object { $_.tag_name -eq $releaseTag }
    if (-not $release) {
        throw "Release with tag $releaseTag not found."
    }
    Write-Host "Release with tag $releaseTag found." -ForegroundColor Green
}
catch {
    Write-Host "Error finding release: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# Get the upload URL
try {
    Write-Host "Raw upload_url from GitHub API: $($release.upload_url)" -ForegroundColor Yellow

    # Correctly remove the {?name,label} placeholders
    $uploadUrl = $release.upload_url -replace "\{\?name,label\}", ""

    # Log the URL after the replacement
    Write-Host "Upload URL after removing placeholder: $uploadUrl" -ForegroundColor Yellow

    # Check if the upload URL is valid and not empty
    if ([string]::IsNullOrWhiteSpace($uploadUrl)) {
        throw "Upload URL is empty or invalid."
    }
    Write-Host "Upload URL is valid: $uploadUrl" -ForegroundColor Green
}
catch {
    Write-Host "Error extracting upload URL: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# Get the file name, append a GUID to make it unique, and URL encode it
try {
    Write-Host "Getting and encoding file name..." -ForegroundColor Yellow
    
    # Append a GUID to the file name to ensure uniqueness
    $guid = [guid]::NewGuid().ToString()
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath) + "_$guid" + [System.IO.Path]::GetExtension($filePath)

    # URL encode the file name for the upload URL
    $fileName = [System.Web.HttpUtility]::UrlEncode($fileName)

    Write-Host "Encoded unique file name: $fileName" -ForegroundColor Green
}
catch {
    Write-Host "Error encoding file name: $($_.Exception.Message)" -ForegroundColor Red
    return
}


# Check the Upload URL just before final URL construction
try {
    Write-Host "Checking upload URL before final URL construction: $uploadUrl" -ForegroundColor Yellow
    if ([string]::IsNullOrWhiteSpace($uploadUrl)) {
        throw "Upload URL is empty before constructing the final URL."
    }
    
    # Construct the final URL using string concatenation method
    try {
        Write-Host "Constructing final upload URL..." -ForegroundColor Yellow
    
        # Use [System.String]::Concat to explicitly concatenate the strings
        $finalUrl = [System.String]::Concat($uploadUrl, "?name=", $fileName)
    
        Write-Host "Final upload URL: $finalUrl" -ForegroundColor Yellow

        # Ensure the final URL is valid
        if ($finalUrl -notmatch "^https?:\/\/") {
            throw "Invalid URL format detected: $finalUrl"
        }
        Write-Host "Final upload URL is valid" -ForegroundColor Green
    }
    catch {
        Write-Host "Error constructing final URL: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

}
catch {
    Write-Host "Error constructing final URL: $($_.Exception.Message)" -ForegroundColor Red
    return
}


# Check file size (limit is 2 GB)
$fileSize = (Get-Item $filePath).Length
if ($fileSize -gt 2147483648) {
    Write-Host "File exceeds the maximum allowed size for GitHub release assets." -ForegroundColor Red
    return
}

# List existing assets in the release
$assetsUrl = $release.assets_url
$assets = Invoke-RestMethod -Uri $assetsUrl -Headers $headers
if ($assets | Where-Object { $_.name -eq "vault.GH.Asset.zip" }) {
    Write-Host "Asset already exists in the release. Skipping upload." -ForegroundColor Yellow
    return
}


if ($release.draft -eq $true) {
    Write-Host "Release is a draft. Publish the release first before uploading assets." -ForegroundColor Red
    return
}


# Determine the correct content type based on the file extension
# $contentType = "application/octet-stream"  # Default

# if ($filePath -like "*.zip") {
#     $contentType = "application/zip"
# }

# Upload the file
Write-Host "Preparing to upload asset $fileName to release with tag $releaseTag..." -ForegroundColor Cyan
try {
    $uploadHeaders = @{
        Authorization = "token $token"
        Accept        = "application/vnd.github+json"
        ContentType   = "application/zip"
    }
    

    Write-Host "Starting file upload..." -ForegroundColor Yellow
    Invoke-RestMethod -Uri $finalUrl -Headers $uploadHeaders -Method Post -InFile $filePath
    Write-Host "File uploaded successfully: $fileName" -ForegroundColor Green
}
catch {
    # Capture detailed exception information
    $response = $_.Exception.Response
    $statusCode = $_.Exception.Response.StatusCode
    $statusDescription = $_.Exception.Response.StatusDescription

    # Log all variables to the console
    Write-Host "Response: $response" -ForegroundColor Yellow
    Write-Host "Status Code: $statusCode" -ForegroundColor Yellow
    Write-Host "Status Description: $statusDescription" -ForegroundColor Yellow

    # Reading the response stream
    $reader = New-Object IO.StreamReader($response.GetResponseStream())
    $responseBody = $reader.ReadToEnd()
    $reader.Close()

    # Log intermediate variables for the stream reading process
    Write-Host "Reader Object: $reader" -ForegroundColor Yellow
    Write-Host "Response Body: $responseBody" -ForegroundColor Yellow

    # Output the final error message
    Write-Host "Error during upload: $responseBody" -ForegroundColor Red

    # Trigger a breakpoint to help with debugging
    # Wait-Debugger
}

# Log End of Script
Write-Host "Script finished." -ForegroundColor Cyan