#Call Latest Setup.ps1 using GitHub API instead of a webscript


# function Get-GitHubPAT {
#     $secretsFile = Join-Path -Path $PSScriptRoot -ChildPath "secrets.psd1"

#     if (Test-Path $secretsFile) {
#         $secrets = Import-PowerShellDataFile -Path $secretsFile

#         if ($secrets.ContainsKey('GitHubPAT') -and $secrets['GitHubPAT']) {
#             # Decrypt the secure string
#             return (ConvertTo-SecureString $secrets['GitHubPAT'] -AsPlainText -Force)
#         }
#     }

#     # Prompt the user to enter the PAT if not found
#     $PAT = Read-Host -Prompt "Enter your GitHub Personal Access Token (PAT)" -AsSecureString
    
#     # Encrypt and save the PAT to the secrets.psd1 file for future use
#     $securePat = $PAT | ConvertFrom-SecureString
#     $secrets = @{
#         GitHubPAT = $securePat
#     }
#     $secrets | Export-PowerShellDataFile -Path $secretsFile -Force

#     return $PAT
# }




function Authenticate-GitHubAPI {
    <#
    .SYNOPSIS
    Authenticates with GitHub API using a token provided by the user or from a secrets file.

    .DESCRIPTION
    This function allows the user to authenticate with GitHub API by either entering a GitHub token manually or using a token from a secrets file located in the `$PSScriptRoot`.

    .PARAMETER ApiUrl
    The base URL for GitHub API, typically "https://api.github.com".

    .EXAMPLE
    Authenticate-GitHubAPI -ApiUrl "https://api.github.com"
    Prompts the user to choose between entering the GitHub token manually or using the token from the secrets file.

    .NOTES
    This function directly interacts with the GitHub API using the token.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ApiUrl = "https://api.github.com"
    )

    begin {
        Write-Host "Starting Authenticate-GitHubAPI function" -ForegroundColor Cyan
    }

    process {
        try {
            Write-Host "Authenticating with GitHub API..." -ForegroundColor Cyan

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
                Write-Host "GitHub token has been saved securely to $secretsFilePath." -ForegroundColor Green
            }
            else {
                # If the secrets file exists, import it
                $secrets = Import-Clixml -Path $secretsFilePath
                $secureToken = $secrets.GitHubToken | ConvertTo-SecureString

                if (-not $secureToken) {
                    $errorMessage = "GitHub token not found in the secrets file."
                    Write-Host $errorMessage -ForegroundColor Red
                    throw $errorMessage
                }

                Write-Host "Using GitHub token from secrets file for authentication." -ForegroundColor Cyan
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
                Write-Host "Successfully authenticated as $($authResponse.login)" -ForegroundColor Green
            }
            else {
                $errorMessage = "Failed to authenticate with GitHub API. Please check the token and try again."
                Write-Host $errorMessage -ForegroundColor Red
                throw $errorMessage
            }
        }
        catch {
            Write-Host "An error occurred during GitHub API authentication: $($_.Exception.Message)" -ForegroundColor Red
            throw $_
        }
    }

    end {
        Write-Host "Authenticate-GitHubAPI function execution completed." -ForegroundColor Cyan
    }
}


$owner = "aollivierre"
$repo = "IntuneDeviceMigration"
$path = "Setup.ps1"

# Authenticate and retrieve the GitHub token
Authenticate-GitHubAPI -ApiUrl "https://api.github.com"

# Assuming the token is now stored securely and retrieved in the session, we use it
$secretsFilePath = Join-Path -Path $PSScriptRoot -ChildPath "secrets.psd1"
$secrets = Import-Clixml -Path $secretsFilePath
$secureToken = $secrets.GitHubToken | ConvertTo-SecureString

# Convert secure string back to plain text for the API call
$ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
$token = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)

$apiUrl = "https://api.github.com/repos/$owner/$repo/contents/$path"
$headers = @{
    Authorization = "token $token"
    Accept = "application/vnd.github.v3.raw"
    'User-Agent' = 'PowerShell'
}

$scriptContent = Invoke-RestMethod -Uri $apiUrl -Headers $headers
$localScriptPath = "$env:TEMP\Setup.ps1"
[System.IO.File]::WriteAllText($localScriptPath, $scriptContent)

# Now execute the downloaded script
& $localScriptPath

