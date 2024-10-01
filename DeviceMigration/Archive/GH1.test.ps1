#test

$apiUrl = "https://api.github.com/repos/aollivierre/vault/releases/tags/0.1"
$headers = @{
    "Authorization" = "Bearer PAT"
    "Accept" = "application/vnd.github+json"
}

$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers
$response