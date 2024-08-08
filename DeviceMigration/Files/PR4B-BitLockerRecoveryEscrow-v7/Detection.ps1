#Unique Tracking ID: a3ee7941-97fb-492b-9d51-c1728b806d17, Timestamp: 2024-03-08 16:09:29

$clientId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# $tenantName = "bellwoodscentres.onmicrosoft.com"
$tenantID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# $RedirectUri = "https://login.microsoftonline.com/common/oauth2/nativeclient"

$refreshToken ='0.Axxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'


# Token endpoint
$tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# Prepare the request body. Exclude 'client_secret' if your app is a public client.
$body = @{
    client_id     = $clientId
    grant_type    = "refresh_token"
    refresh_token = $refreshToken
    # Uncomment the next line if your application is a confidential client
    scope         = "https://graph.microsoft.com/.default"  # Adjust this scope according to your needs
}

# Make the POST request
$response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"

# Output the new access token and refresh token
# Write-Host "New Access Token: $($response.access_token)" #uncomment for debugging
# Some authorization servers might not return a new refresh token every time you refresh an access token
if ($response.refresh_token) {
    # Write-Host "New Refresh Token: $($response.refresh_token)" #uncomment for debugging
}



$AccessToken= $response.access_token

# Assuming your access token is stored in a variable named $accessTokenString

# Convert the plain string token to a SecureString
# $AccessToken = $accessTokenString | ConvertTo-SecureString -AsPlainText -Force


# Set up headers for API requests
$headers = @{
    "Authorization" = "Bearer $($accessToken)"
    "Content-Type"  = "application/json"
}


# Run dsregcmd /status and capture the output
$dsregcmdOutput = & dsregcmd /status

# Convert the output to a string to ensure consistent handling
$dsregcmdOutputString = $dsregcmdOutput -join "`n"

# Use a regular expression to find the DeviceId more reliably
if ($dsregcmdOutputString -match "DeviceId\s*:\s*([-\w]+)") {
    $DeviceId = $matches[1]
} else {
    # Write-Host "Device ID not found. Ensure the device is Azure AD joined."
    # exit 1
}

if (-not [string]::IsNullOrWhiteSpace($DeviceId)) {
    # Write-Host "Device ID: $DeviceId"

    # Continue with your script...
} else {
    # Write-Host "Device ID not found. Ensure the device is Azure AD joined."
    # exit 1
}


if (-not $DeviceId) {
    # Write-Host "Device ID not found. Ensure the device is Azure AD joined."
    # exit 1
} else {
    # Write-Host "Device ID: $DeviceId"

    # Ensure DeviceId is set
    # $DeviceId = '6d298358-fa28-438c-9139-e4b75ccac34c'

    # Construct the Graph API URI with the filter query
    $FilterQuery = "`$filter=deviceId eq '$DeviceId'"
    $GraphUri = "https://graph.microsoft.com/v1.0/informationProtection/bitlocker/recoveryKeys?$FilterQuery"

    # Display the constructed URI for debugging
    # Write-Host "Constructed URI: $GraphUri"

    $Headers = @{
        Authorization = "Bearer $AccessToken"
    }

    try {
        $BitlockerKeysResponse = Invoke-RestMethod -Uri $GraphUri -Headers $Headers -Method Get

        if ($null -ne $BitlockerKeysResponse.value -and $BitlockerKeysResponse.value.Count -gt 0) {
            # Write-Host "Filtered Bitlocker key(s) found escrowed in Azure AD for Device ID: $DeviceId"
            foreach ($key in $BitlockerKeysResponse.value) {
                # Write-Host "Key ID: $($key.id) - Created: $($key.createdDateTime) - Volume Type: $($key.volumeType) - Device ID: $($key.deviceId)" 
                #No remediation needed
            }
            exit 0 
        } else {
            # Write-Host "No Bitlocker keys found escrowed in Azure AD for Device ID: $DeviceId" 
            #Remediation needed
            exit 1 
        }
    } catch {
        # Write-Error "Failed to query Bitlocker keys from Azure AD: $_"
        exit 2
    }
}
