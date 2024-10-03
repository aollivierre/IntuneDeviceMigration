Import-Module 'C:\code\ModulesV2\EnhancedModuleStarterAO\EnhancedModuleStarterAO.psm1'

# Define a hashtable for splatting
$moduleStarterParams = @{
    Mode                   = 'dev'
    SkipPSGalleryModules   = $true
    SkipCheckandElevate    = $true
    SkipPowerShell7Install = $true
    SkipEnhancedModules    = $true
    SkipGitRepos           = $true
}

# Call the function using the splat
Invoke-ModuleStarter @moduleStarterParams


Remove-Item 'C:\temp' -Force -Recurse

# Ensure C:\temp exists
$secureFilePath = "C:\temp\SecurePAT.txt"
if (-not (Test-Path "C:\temp")) {
    New-Item -Path "C:\temp" -ItemType Directory
}

$SecurePAT = Get-GitHubPAT

if ($null -ne $SecurePAT) {
    # Continue with the secure PAT
    Write-EnhancedLog -Message "Using the captured PAT..."
    # Further logic here
}
else {
    Write-EnhancedLog -Message "No PAT was captured."
}


# Convert the SecureString to an encrypted string and store it in a file
$SecurePAT | ConvertFrom-SecureString | Set-Content -Path $secureFilePath

Write-EnhancedLog -Message "Your secure PAT has been saved to $secureFilePath"


# Define the splatted parameters
$params = @{
    SecurePAT                 = $SecurePAT
    RepoOwner                 = "aollivierre"
    RepoName                  = "Vault"
    ReleaseTag                = "0.1"
    FileName                  = "vault.GH.Asset.zip"
    DestinationPath           = "C:\temp\vault.GH.Asset.zip"
    ZipFilePath               = "C:\temp\vault.zip"
    CertBase64Path            = "C:\temp\vault\certs\cert.pfx.base64"
    CertPasswordPath          = "C:\temp\vault\certs\certpassword.txt"
    KeyBase64Path             = "C:\temp\vault\certs\secret.key.encrypted.base64"
    EncryptedFilePath         = "C:\temp\vault\vault.zip.encrypted"
    CertsDir                  = "C:\temp\vault\certs"
    DecryptedFilePath         = "C:\temp\vault.zip"
    KeePassDatabasePath       = "C:\temp\vault-decrypted\myDatabase.kdbx"
    KeyFilePath               = "C:\temp\vault-decrypted\myKeyFile.keyx"
    EntryName                 = "ICTC-EJ-PPKG"
    AttachmentName            = "ICTC_Project_2_Aug_29_2024.zip"
    ExportPath                = "C:\temp\vault-decrypted\ICTC_Project_2_Aug_29_2024-fromdb.zip"
    FinalDestinationDirectory = "C:\temp\vault-decrypted"
}

# Invoke the function using the splatted parameters
Invoke-VaultDecryptionProcess @params