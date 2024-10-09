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

# Function to retrieve secrets from secrets.bitly.psd1 or prompt user if not present
function Get-Secrets {
    $secretsFilePath = Join-Path -Path $PSScriptRoot -ChildPath "secrets.bitly.psd1"

    if (-not (Test-Path -Path $secretsFilePath)) {
        Write-Warning "Secrets file not found. Please enter your Bitly token."

        # Prompt for Bitly token securely
        $bitlyTokenSecure = Read-Host "Enter your Bitly token" -AsSecureString

        # Store the token securely in the secrets.bitly.psd1 file
        $secretsContent = @{
            BitlyToken = $bitlyTokenSecure | ConvertFrom-SecureString
        }

        # Export to secrets.bitly.psd1 as XML to maintain security
        $secretsContent | Export-Clixml -Path $secretsFilePath
        Write-Host "Bitly token has been saved securely to $secretsFilePath."

        # Return the secrets content
        return $secretsContent
    }
    else {
        # If the secrets file exists, import it
        $secrets = Import-Clixml -Path $secretsFilePath

        if (-not $secrets.BitlyToken) {
            $errorMessage = "Bitly token not found in the secrets file."
            Write-Host $errorMessage
            throw $errorMessage
        }

        Write-Host "Using Bitly token from secrets file."
        return $secrets
    }
}

# Retrieve the secrets
$secrets = Get-Secrets

# Convert the Bitly token back to plain text for use in the script
$bitlyTokenSecure = $secrets.BitlyToken | ConvertTo-SecureString
$bitlyToken = ConvertFrom-SecureStringToPlainText -SecureString $bitlyTokenSecure

# Function to prompt for GitHub raw URL and validate it
function Get-GitHubRawUrl {
    param (
        [string]$PromptMessage = "Enter the GitHub raw URL (format: https://raw.githubusercontent.com/...): "
    )
    
    while ($true) {
        $url = Read-Host -Prompt $PromptMessage
        if ($url -match '^https://raw.githubusercontent.com') {
            return $url
        } else {
            Write-Host "Invalid URL format. Please enter a valid GitHub raw URL." -ForegroundColor Red
        }
    }
}

# Function to build example text
function Build-ExampleText {
    param (
        [string]$longUrl,
        [string]$shortUrl
    )
    
    $shortUrlNoProtocol = $shortUrl -replace '^https://', ''

    return @"
# call using:

# powershell -Command "iex (irm $longUrl)"
# powershell -Command "iex (irm $shortUrl)"
# powershell -Command "iex (irm $shortUrlNoProtocol)"
# or if you are in powershell already call (URL is case sensitive)
# iex (irm $shortUrlNoProtocol)
"@
}

# Prompt the user to enter the GitHub raw URL
$longUrl = Get-GitHubRawUrl

# The Bitly API endpoint for shortening URLs
$bitlyApiUrl = "https://api-ssl.bitly.com/v4/shorten"

# Prepare the request headers
$headers = @{
    "Authorization" = "Bearer $bitlyToken"
    "Content-Type"  = "application/json"
}

# Prepare the request body
$body = @{
    "long_url" = $longUrl
} | ConvertTo-Json

# Make the request to the Bitly API
$response = Invoke-RestMethod -Uri $bitlyApiUrl -Method POST -Headers $headers -Body $body

# Output the shortened URL
$shortUrl = $response.link
Write-Host "Shortened URL: $shortUrl"

# Build and output the example text
$exampleText = Build-ExampleText -longUrl $longUrl -shortUrl $shortUrl
Write-Host $exampleText

# Write the example to Readme.md in the script root
$readmePath = "$PSScriptRoot\Readme.md"
$exampleText | Out-File -FilePath $readmePath -Encoding utf8

# Inform the user
Write-Host "Example output written to Readme.md in the script root."