# Path to your secrets file
$secretsPath = "$PSScriptRoot\secrets.psd1"

# Import the secrets file
$secrets = Import-PowerShellDataFile -Path $secretsPath

# Retrieve the Bitly API token from the secrets file
$bitlyToken = $secrets.BitlyToken

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
