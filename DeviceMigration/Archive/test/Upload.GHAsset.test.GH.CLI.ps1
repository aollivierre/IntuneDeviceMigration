function Upload-GitHubReleaseAsset {
    <#
    .SYNOPSIS
    Uploads an asset to a GitHub release using the GitHub CLI.

    .PARAMETER repoOwner
    The owner of the GitHub repository.

    .PARAMETER repoName
    The name of the GitHub repository.

    .PARAMETER releaseTag
    The tag of the release where the asset will be uploaded.

    .PARAMETER filePath
    The path of the file to be uploaded as an asset.

    .EXAMPLE
    $params = @{
        repoOwner  = "aollivierre"
        repoName   = "Vault"
        releaseTag = "0.1"
        filePath   = "C:\temp2\vault.GH.Asset.zip"
    }
    Upload-GitHubReleaseAsset @params
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "The owner of the GitHub repository.")]
        [ValidateNotNullOrEmpty()]
        [string]$repoOwner,

        [Parameter(Mandatory = $true, HelpMessage = "The name of the GitHub repository.")]
        [ValidateNotNullOrEmpty()]
        [string]$repoName,

        [Parameter(Mandatory = $true, HelpMessage = "The tag of the release where the asset will be uploaded.")]
        [ValidateNotNullOrEmpty()]
        [string]$releaseTag,

        [Parameter(Mandatory = $true, HelpMessage = "The path of the file to be uploaded as an asset.")]
        [ValidateNotNullOrEmpty()]
        [string]$filePath
    )

    Begin {
        Write-EnhancedLog -Message "Starting GitHub Asset Upload Script" -Level "NOTICE"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            # Check if the file exists
            Write-EnhancedLog -Message "Checking if file exists: $filePath" -Level "INFO"
            if (-not (Test-Path -Path $filePath)) {
                Write-EnhancedLog -Message "File does not exist: $filePath" -Level "ERROR"
                throw "File does not exist: $filePath"
            }
            Write-EnhancedLog -Message "File exists: $filePath" -Level "INFO"

            # Upload the file using GitHub CLI
            Write-EnhancedLog -Message "Uploading asset $filePath to release $releaseTag..." -Level "INFO"
            $command = "gh release upload $releaseTag $filePath --repo $repoOwner/$repoName"
            Invoke-Expression $command

            Write-EnhancedLog -Message "File uploaded successfully: $filePath" -Level "INFO"
        }
        catch {
            Handle-Error -Message "Error during upload: $($_.Exception.Message)" -ErrorRecord $_
            throw
        }
    }

    End {
        Write-EnhancedLog -Message "Script finished." -Level "NOTICE"
    }
}



# Define a hash table (splatting) to hold the parameters for the function
$params = @{
    # GitHub repository owner (in this case, the user or organization)
    repoOwner  = "aollivierre"   # Set the owner of the repository
    
    # GitHub repository name where the release is located
    repoName   = "Vault"         # The name of the GitHub repository
    
    # The specific release tag to which the asset will be uploaded
    releaseTag = "0.1"           # The tag for the release, like "v1.0" or "0.1"
    
    # The path of the file to be uploaded as an asset
    filePath   = "C:\temp2\vault.GH.Asset.zip"  # Path to the asset file on the local system
}

# Pass the parameters using splatting to the Upload-GitHubReleaseAsset function
Upload-GitHubReleaseAsset @params