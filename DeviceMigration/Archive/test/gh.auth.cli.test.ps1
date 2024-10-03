# Step 1: Prompt the user for the Personal Access Token (PAT) securely
$patSecure = Read-Host "Please enter your GitHub Personal Access Token (PAT)" -AsSecureString

# Step 2: Convert the secure string (encrypted) to plain text
$ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($patSecure)
$pat = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)

# Step 3: Authenticate GitHub CLI with the provided PAT
try {
    # Log in to GitHub CLI using the PAT
    $pat | gh auth login --with-token
    
    # Check authentication status
    gh auth status
    
    Write-Host "Authentication successful." -ForegroundColor Green
}
catch {
    Write-Host "Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Clean up by clearing the variable holding the PAT in plain text
$pat = $null