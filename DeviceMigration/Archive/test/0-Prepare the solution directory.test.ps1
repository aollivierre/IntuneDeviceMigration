# Variables for URLs
$MigrationToolURL = "https://github.com/managedBlog/Managed_Blog/tree/main/AD%20to%20AAD%20Only%20Migration%20Tool/Beta%20-%20PS1%20Script%20based"
$PSAppDeployToolkitURL = "https://github.com/PSAppDeployToolkit/PSAppDeployToolkit/releases/download/v3.8.4/PSAppDeployToolkit_v3.8.4.zip"
$MDTURL = "https://download.microsoft.com/download/9/e/1/9e1e94ec-5463-46b7-9f3c-b225034c3a70/MDT_KB4564442.exe"
$OneDriveLibURL = "https://github.com/rodneyviana/ODSyncService/raw/main/OneDriveLib.dll"

# Paths
$ToolkitFolder = "C:\code\CB\Entra\DeviceMigration\Toolkit"
$FilesFolder = "C:\code\CB\Entra\DeviceMigration\Files"
$ScriptsFolder = "C:\code\CB\Entra\DeviceMigration\Scripts"
$BannerImageSource = "C:\code\CB\Entra\DeviceMigration\YourBannerImage.png"
$DeployApplicationSource = "$ScriptsFolder\Deploy-Application.ps1"
$DeployApplicationDestination = "$ToolkitFolder\Deploy-Application.ps1"
$BannerImageDestination = "$ToolkitFolder\AppDeployToolkit\AppDeployToolkitBanner.png"

# Create necessary directories
New-Item -ItemType Directory -Path $ToolkitFolder -Force
New-Item -ItemType Directory -Path $FilesFolder -Force

# Function to download files
function Download-File {
    param (
        [string]$url,
        [string]$destination
    )
    Invoke-WebRequest -Uri $url -OutFile $destination
}

# Download Migration Tool
Download-File -url $MigrationToolURL -destination "$FilesFolder\MigrationTool.zip"

# Download and extract PSAppDeployToolkit
Download-File -url $PSAppDeployToolkitURL -destination "$FilesFolder\PSAppDeployToolkit.zip"
Expand-Archive -Path "$FilesFolder\PSAppDeployToolkit.zip" -DestinationPath $ToolkitFolder -Force

# Download and install Microsoft Deployment Toolkit
Download-File -url $MDTURL -destination "$FilesFolder\MDT.exe"
Start-Process -FilePath "$FilesFolder\MDT.exe" -ArgumentList "/quiet" -Wait

# Copy ServiceUI.exe to Files folder
Copy-Item -Path "C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\ServiceUI.exe" -Destination $FilesFolder

# Download OneDriveLib.dll
Download-File -url $OneDriveLibURL -destination "$FilesFolder\OneDriveLib.dll"

# Create a provisioning package for AAD bulk enrollment (placeholder as the actual creation depends on your environment)
# Assuming you have a script or method to create it
# Copy the provisioning package to the Files folder
# Example: Copy-Item -Path "C:\Path\To\Your\ProvisioningPackage.ppkg" -Destination "$FilesFolder\ProvisioningPackage.ppkg"

# Replace Deploy-Application.ps1 in the toolkit folder
Copy-Item -Path $DeployApplicationSource -Destination $DeployApplicationDestination -Force

# Replace the banner image in the toolkit folder
Copy-Item -Path $BannerImageSource -Destination $BannerImageDestination -Force

Write-Output "All tasks completed successfully."
