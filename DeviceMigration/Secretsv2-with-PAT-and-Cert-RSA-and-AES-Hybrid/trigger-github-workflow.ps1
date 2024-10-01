# Replace these variables with your GitHub repository information
$owner = "aollivierre"  # GitHub repository owner
$repo = "vault"        # Repository name
$workflowFileName = "decrypt.yml"   # Workflow file name (this is the name of your GitHub workflow file)
$pat = "PAT"    # GitHub Personal Access Token (PAT)

# GitHub API URL for triggering workflows
$workflowDispatchUrl = "https://api.github.com/repos/$owner/$repo/actions/workflows/$workflowFileName/dispatches"

# The payload to send (this can be empty or can specify a branch/ref to run on)
$payload = @{
    ref = "main"  # The branch to run the workflow on
} | ConvertTo-Json

# Set up headers for the GitHub API request
$headers = @{
    Authorization = "token $pat"
    "Content-Type" = "application/json"
    "User-Agent" = "PowerShell"
}

# Trigger the workflow via GitHub API
$response = Invoke-RestMethod -Uri $workflowDispatchUrl -Method Post -Headers $headers -Body $payload

if ($response) {
    Write-Host "Workflow triggered successfully."
} else {
    Write-Host "Failed to trigger the workflow."
}
