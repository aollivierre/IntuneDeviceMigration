param (
    [SecureString]$SecurePAT
)


$global:mode = $env:EnvironmentMode
# $global:mode = 'dev'

function Write-DecryptionLog {
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
    $logFilePath = [System.IO.Path]::Combine($env:TEMP, 'decryption.log')
    $formattedMessage | Out-File -FilePath $logFilePath -Append -Encoding utf8
}


# Toggle based on the environment mode
switch ($global:mode) {
    'dev' {
        Write-DecryptionLog "Running in development mode" -Level 'Warning'
        # Your development logic here
    }
    'prod' {
        Write-DecryptionLog "Running in production mode" -Level 'INFO'
        # Your production logic here
    }
    default {
        Write-DecryptionLog "Unknown mode. Defaulting to production." -Level 'ERROR'
        # Default to production
    }
}

# Wait-Debugger

#region FIRING UP MODULE STARTER
#################################################################################################
#                                                                                               #
#                                 FIRING UP MODULE STARTER                                      #
#                                                                                               #
#################################################################################################


# Wait-Debugger

# Invoke-Expression (Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Install-EnhancedModuleStarterAO.ps1")

# Wait-Debugger

# Import-Module 'C:\code\ModulesV2\EnhancedModuleStarterAO\EnhancedModuleStarterAO.psm1'

# Define a hashtable for splatting
# $moduleStarterParams = @{
#     Mode                   = $global:mode
#     SkipPSGalleryModules   = $false
#     SkipCheckandElevate    = $false
#     SkipPowerShell7Install = $false
#     SkipEnhancedModules    = $false
#     SkipGitRepos           = $true
# }

# Call the function using the splat
# Invoke-ModuleStarter @moduleStarterParams

#endregion FIRING UP MODULE STARTER


#region Cleaning up Logs
#################################################################################################
#                                                                                               #
#                            Cleaning up Logs                                                   #
#                                                                                               #
#################################################################################################
# if ($Mode -eq "Dev") {
#     Write-EnhancedLog -Message "Removing Logs in Dev Mode " -Level "WARNING"
#     Remove-LogsFolder -LogFolderPath "C:\Logs"
#     Write-EnhancedLog -Message "Migration in progress form displayed" -Level "INFO"
# }
# else {
#     Write-EnhancedLog -Message "Skipping Removing Logs in Prod mode" -Level "WARNING"
# }
#endregion Cleaning up Logs



#region HANDLE PSF MODERN LOGGING
#################################################################################################
#                                                                                               #
#                            HANDLE PSF MODERN LOGGING                                          #
#                                                                                               #
#################################################################################################
Set-PSFConfig -Fullname 'PSFramework.Logging.FileSystem.ModernLog' -Value $true -PassThru | Register-PSFConfig -Scope SystemDefault

# Define the base logs path and job name
$JobName = "secrets_decryption"
$parentScriptName = Get-ParentScriptName
Write-EnhancedLog -Message "Parent Script Name: $parentScriptName"

# Call the Get-PSFCSVLogFilePath function to generate the dynamic log file path
$GetPSFCSVLogFilePathParam = @{
    LogsPath         = 'C:\Logs\PSF'
    JobName          = $jobName
    parentScriptName = $parentScriptName
}

$csvLogFilePath = Get-PSFCSVLogFilePath @GetPSFCSVLogFilePathParam
Write-EnhancedLog -Message "Generated Log File Path: $csvLogFilePath"

$instanceName = "$parentScriptName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# Configure the PSFramework logging provider to use CSV format
$paramSetPSFLoggingProvider = @{
    Name            = 'logfile'
    InstanceName    = $instanceName  # Use a unique instance name
    FilePath        = $csvLogFilePath  # Use the dynamically generated file path
    Enabled         = $true
    FileType        = 'CSV'
    EnableException = $true
}
Set-PSFLoggingProvider @paramSetPSFLoggingProvider



# # Set up the EventLog logging provider with the calling function as the source
# $paramSetPSFLoggingProvider = @{
#     Name         = 'EventLog'
#     # InstanceName = 'DynamicEventLog'
#     InstanceName = $instanceName
#     Enabled      = $true
#     LogName      = $parentScriptName
#     Source       = $callingFunction
# }
# Set-PSFLoggingProvider @paramSetPSFLoggingProvider

# Write-EnhancedLog -Message "This is a test from $parentScriptName via PSF to Event Logs" -Level 'INFO'

# $DBG

#endregion HANDLE PSF MODERN LOGGING


#region HANDLE Transript LOGGING
#################################################################################################
#                                                                                               #
#                            HANDLE Transript LOGGING                                           #
#                                                                                               #
#################################################################################################
# Start the script with error handling
try {
    # Generate the transcript file path
    $GetTranscriptFilePathParams = @{
        TranscriptsPath  = "C:\Logs\Transcript"
        JobName          = $jobName
        parentScriptName = $parentScriptName
    }
    $transcriptPath = Get-TranscriptFilePath @GetTranscriptFilePathParams
    
    # Start the transcript
    Write-EnhancedLog -Message "Starting transcript at: $transcriptPath" -Level 'INFO'
    Start-Transcript -Path $transcriptPath
}
catch {
    Write-EnhancedLog -Message "An error occurred during script execution: $_" -Level 'ERROR'
    if ($transcriptPath) {
        Stop-Transcript
        Write-DecryptionLog "Transcript stopped." -Level 'WARNING'
        # Stop logging in the finally block

    }
    else {
        Write-DecryptionLog "Transcript was not started due to an earlier error." -Level 'ERROR'
    }

    # Stop PSF Logging

    # Ensure the log is written before proceeding
    Wait-PSFMessage

    # Stop logging in the finally block by disabling the provider
    Set-PSFLoggingProvider -Name 'logfile' -InstanceName $instanceName -Enabled $false

    Handle-Error -ErrorRecord $_
    throw $_  # Re-throw the error after logging it
} 
#endregion HANDLE Transript LOGGING

# $DBG

try {

    #region Script Logic
    #################################################################################################
    #                                                                                               #
    #                                    Script Logic                                               #
    #                                                                                               #
    #################################################################################################




    # Step1: 


 
    # # Prompt the user for the PAT securely
    # # $patSecure = Read-Host "Please enter your GitHub Personal Access Token (PAT)" -AsSecureString

    # # Convert the secure string (encrypted) to plain text
    # $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePAT)
    # $pat = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)

    # # Define parameters including the user-provided PAT
    # $params = @{
    #     Token           = $pat  # The PAT entered by the user
    #     RepoOwner       = "aollivierre"
    #     RepoName        = "Vault"
    #     ReleaseTag      = "0.1"
    #     FileName        = "vault.GH.Asset.zip"
    #     DestinationPath = "C:\temp\vault.GH.Asset.zip"
    # }

    # # Call the Download-GitHubReleaseAsset function with splatted parameters
    # Download-GitHubReleaseAsset @params

    # # Clear the PAT variable for security reasons after use
    # $pat = $null

    


    # $params = @{
    #     ZipFilePath          = "C:\temp\vault.GH.Asset.zip"
    #     DestinationDirectory = "C:\temp\vault"
    # }
    # Unzip-Directory @params


    # # Wait-Debugger



    # # Step1: Decrypt using the Hybrid AES + RSA (Cert) mode
  

    # # Define the parameters for the Decrypt-FileWithCert function using splatting
    # $params = @{

    #     # Path to the Base64-encoded certificate file.
    #     # This file should contain the Base64-encoded contents of the .pfx certificate that you want to use for decryption.
    #     CertBase64Path    = "C:\temp\vault\certs\cert.pfx.base64"

    #     # Path to the text file that contains the password for the .pfx certificate.
    #     # This is the password that will be used to unlock the certificate and access the private key.
    #     CertPasswordPath  = "C:\temp\vault\certs\certpassword.txt"

    #     # Path to the Base64-encoded AES key file.
    #     # This file contains the encrypted AES key that will be used to decrypt the target file.
    #     KeyBase64Path     = "C:\temp\vault\certs\secret.key.encrypted.base64"

    #     # Path to the file that is encrypted and needs to be decrypted.
    #     # This is the target file that was encrypted using the AES key, and it will be decrypted using the AES key and IV.
    #     EncryptedFilePath = "C:\temp\vault\vault.zip.encrypted"

    #     # Path where the decrypted file will be saved after decryption.
    #     # This is the output path where the function will store the decrypted version of the file.
    #     DecryptedFilePath = "C:\temp\vault.zip"

    #     # Directory where temporary files such as the certificate and the AES key will be stored during the process.
    #     # This is a working directory where the function can safely write temporary files during the decryption.
    #     CertsDir          = "C:\temp\vault\certs"
    # }

    # # Call the Decrypt-FileWithCert function and pass the parameters via splatting.
    # # This function will use the provided certificate, key, and encrypted file to perform the decryption and save the decrypted file.
    # Decrypt-FileWithCert @params


    # # Wait-Debugger

    # #Step 2: Unzip the directory


    # $params = @{
    #     ZipFilePath          = "C:\temp\vault.zip"
    #     DestinationDirectory = "C:\temp\vault-decrypted"
    # }
    # Unzip-Directory @params


    # $exportAttachmentParams = @{
    #     DatabasePath   = "C:\temp\vault-decrypted\myDatabase.kdbx"
    #     KeyFilePath    = "C:\temp\vault-decrypted\myKeyFile.keyx"
    #     EntryName      = "ICTC-EJ-PPKG"
    #     AttachmentName = "ICTC_Project_2_Aug_29_2024.zip"
    #     ExportPath     = "C:\temp\vault-decrypted\ICTC_Project_2_Aug_29_2024-fromdb.zip"
    # }
    # Export-KeePassAttachment @exportAttachmentParams




    # $params = @{
    #     ZipFilePath          = "C:\temp\vault-decrypted\ICTC_Project_2_Aug_29_2024-fromdb.zip"
    #     DestinationDirectory = "C:\temp\vault-decrypted"
    # }
    # Unzip-Directory @params








    


    #endregion Script Logic
}
catch {
    Write-EnhancedLog -Message "An error occurred during script execution: $_" -Level 'ERROR'
    if ($transcriptPath) {
        Stop-Transcript
        Write-DecryptionLog "Transcript stopped." -Level 'WARNING'
        # Stop logging in the finally block
    }

    # Stop PSF Logging

    # Ensure the log is written before proceeding
    Wait-PSFMessage

    # Stop logging in the finally block by disabling the provider
    Set-PSFLoggingProvider -Name 'logfile' -InstanceName $instanceName -Enabled $false

    Handle-Error -ErrorRecord $_
    throw $_  # Re-throw the error after logging it
} 
finally {
    # Ensure that the transcript is stopped even if an error occurs
    if ($transcriptPath) {
        Stop-Transcript
        Write-DecryptionLog "Transcript stopped." -Level 'WARNING'
        # Stop logging in the finally block

    }
    else {
        Write-DecryptionLog "Transcript was not started due to an earlier error." -Level 'ERROR'
    }
    
    # Ensure the log is written before proceeding
    Wait-PSFMessage

    # Stop logging in the finally block by disabling the provider
    Set-PSFLoggingProvider -Name 'logfile' -InstanceName $instanceName -Enabled $false

}