# Define the file URL and destination
$fileUrl = "https://github.com/user-attachments/files/17181466/ICTC_Project_2_Aug_29_2024.zip.aes.zip"
$destinationPath = "C:\temo\ICTC_Project_2_Aug_29_2024.zip.aes.zip"

# Define your GitHub Personal Access Token (PAT)
$token = "PAT"

# Set the headers with the Authorization Bearer token
$headers = @{
    "Authorization" = "Bearer $token"
}


# Define a test URL to confirm the authorization header is working
# $testUrl = "https://api.github.com/repos/aollivierre/vault"

# $response = Invoke-RestMethod -Uri $testUrl -Headers $headers
# $response


# Download the file using Invoke-WebRequest with the Authorization header
# Invoke-WebRequest -Uri $fileUrl -Headers $headers -OutFile $destinationPath




# Test with Invoke-RestMethod
$fileUrl = "https://github.com/user-attachments/files/17181466/ICTC_Project_2_Aug_29_2024.zip.aes.zip"
$token = "PAT"
$headers = @{
    "Authorization" = "Bearer $token"
}

$response = Invoke-RestMethod -Uri $fileUrl -Headers $headers
$response










# Define the URL and the file path to save
$fileUrl = "https://github.com/user-attachments/files/17181466/ICTC_Project_2_Aug_29_2024.zip.aes.zip"
$destinationPath = "C:\temp\ICTC_Project_2_Aug_29_2024.zip.aes.zip"
$token = "PAT"

# Create the HttpClient
$httpClient = New-Object System.Net.Http.HttpClient
$httpClient.DefaultRequestHeaders.Authorization = "Bearer $token"

# Download the file
$fileContent = $httpClient.GetByteArrayAsync($fileUrl).Result
[System.IO.File]::WriteAllBytes($destinationPath, $fileContent)

# Dispose of the HttpClient
$httpClient.Dispose()
