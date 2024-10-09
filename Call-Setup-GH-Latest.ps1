#Call Latest Setup.ps1 using GitHub API instead of a webscript


# function Get-GitHubPAT {
#     $secretsFile = Join-Path -Path $PSScriptRoot -ChildPath "secrets.GitHub.ps1"

#     if (Test-Path $secretsFile) {
#         $secrets = Import-PowerShellDataFile -Path $secretsFile

#         if ($secrets.ContainsKey('GitHubPAT') -and $secrets['GitHubPAT']) {
#             # Decrypt the secure string
#             return (ConvertTo-SecureString $secrets['GitHubPAT'] -AsPlainText -Force)
#         }
#     }

#     # Prompt the user to enter the PAT if not found
#     $PAT = Read-Host -Prompt "Enter your GitHub Personal Access Token (PAT)" -AsSecureString
    
#     # Encrypt and save the PAT to the secrets.GitHub.ps1 file for future use
#     $securePat = $PAT | ConvertFrom-SecureString
#     $secrets = @{
#         GitHubPAT = $securePat
#     }
#     $secrets | Export-PowerShellDataFile -Path $secretsFile -Force

#     return $PAT
# }



function Write-GitHubAPIWebScriptLog {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )

    # Get the PowerShell call stack to determine the actual calling function
    $callStack = Get-PSCallStack
    $callerFunction = if ($callStack.Count -ge 2) { $callStack[1].Command } else { '<Unknown>' }

    # Prepare the formatted message with the actual calling function information
    $formattedMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] [$callerFunction] $Message"

    # Display the log message based on the log level using Write-Host
    switch ($Level.ToUpper()) {
        "DEBUG" { Write-Host $formattedMessage -ForegroundColor DarkGray }
        "INFO" { Write-Host $formattedMessage -ForegroundColor Green }
        "NOTICE" { Write-Host $formattedMessage -ForegroundColor Cyan }
        "WARNING" { Write-Host $formattedMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $formattedMessage -ForegroundColor Red }
        "CRITICAL" { Write-Host $formattedMessage -ForegroundColor Magenta }
        default { Write-Host $formattedMessage -ForegroundColor White }
    }

    # Append to log file
    $logFilePath = [System.IO.Path]::Combine($env:TEMP, 'setupAADMigration.log')
    $formattedMessage | Out-File -FilePath $logFilePath -Append -Encoding utf8
}


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
        Write-GitHubAPIWebScriptLog -Message "Starting Authenticate-GitHubAPI function" -Level 'INFO'
    }

    process {
        try {
            Write-GitHubAPIWebScriptLog -Message "Authenticating with GitHub API..." -Level 'INFO'

            # Define the secrets file path
            $secretsFilePath = Join-Path -Path $PSScriptRoot -ChildPath "secrets.GitHub.ps1"

            if (-not (Test-Path -Path $secretsFilePath)) {
                # If the secrets file does not exist, prompt the user to enter the token
                Write-Warning "Secrets file not found. Please enter your GitHub token."
                $secureToken = Read-Host "Enter your GitHub token" -AsSecureString
                
                # Store the token securely in the secrets.GitHub.ps1 file
                $secretsContent = @{
                    GitHubToken = $secureToken | ConvertFrom-SecureString
                }
                $secretsContent | Export-Clixml -Path $secretsFilePath
                Write-GitHubAPIWebScriptLog -Message "GitHub token has been saved securely to $secretsFilePath." -Level 'INFO'
            }
            else {
                # If the secrets file exists, import it
                $secrets = Import-Clixml -Path $secretsFilePath
                $secureToken = $secrets.GitHubToken | ConvertTo-SecureString

                if (-not $secureToken) {
                    $errorMessage = "GitHub token not found in the secrets file."
                    Write-GitHubAPIWebScriptLog -Message $errorMessage -Level 'ERROR'
                    throw $errorMessage
                }

                Write-GitHubAPIWebScriptLog -Message "Using GitHub token from secrets file for authentication." -Level 'INFO'
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
                Write-GitHubAPIWebScriptLog -Message "Successfully authenticated as $($authResponse.login)" -Level 'INFO'
            }
            else {
                $errorMessage = "Failed to authenticate with GitHub API. Please check the token and try again."
                Write-GitHubAPIWebScriptLog -Message $errorMessage -Level 'ERROR'
                throw $errorMessage
            }
        }
        catch {
            Write-GitHubAPIWebScriptLog -Message "An error occurred during GitHub API authentication: $($_.Exception.Message)" -Level 'ERROR'
            throw $_
        }
    }

    end {
        Write-GitHubAPIWebScriptLog -Message "Authenticate-GitHubAPI function execution completed." -Level 'INFO'
    }
}


$owner = "aollivierre"
$repo = "IntuneDeviceMigration"
$path = "Setup.ps1"

# Authenticate and retrieve the GitHub token
Authenticate-GitHubAPI -ApiUrl "https://api.github.com"

# Assuming the token is now stored securely and retrieved in the session, we use it
$secretsFilePath = Join-Path -Path $PSScriptRoot -ChildPath "secrets.GitHub.ps1"
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