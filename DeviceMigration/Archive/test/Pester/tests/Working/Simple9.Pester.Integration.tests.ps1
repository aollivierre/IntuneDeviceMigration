# Fetch the script content
$scriptContent = Invoke-RestMethod "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1"

# Define replacements in a hashtable
$replacements = @{
    '\$Mode = "dev"'                     = '$Mode = "dev"'
    '\$SkipPSGalleryModules = \$false'   = '$SkipPSGalleryModules = $true'
    '\$SkipCheckandElevate = \$false'    = '$SkipCheckandElevate = $true'
    '\$SkipAdminCheck = \$false'         = '$SkipAdminCheck = $true'
    '\$SkipPowerShell7Install = \$false' = '$SkipPowerShell7Install = $true'
    '\$SkipModuleDownload = \$false'     = '$SkipModuleDownload = $true'
    '\$SkipGitrepos = \$false'           = '$SkipGitrepos = $true'
}

# Apply the replacements
foreach ($pattern in $replacements.Keys) {
    $scriptContent = $scriptContent -replace $pattern, $replacements[$pattern]
}

# Execute the script
Invoke-Expression $scriptContent



Describe "Backup-File - Integration Tests" {

    BeforeAll {
        # Ensure the C:\Temp directory exists
        if (-Not (Test-Path -Path "C:\Temp")) {
            New-Item -Path "C:\Temp" -ItemType Directory | Out-Null
        }

        # Create a test file
        $testSourceFile = "C:\Temp\TestFile.txt"
        Set-Content -Path $testSourceFile -Value "Test content"

        # Ensure the backup directory does not exist
        $testBackupDirectory = "C:\Temp\Backups"
        if (Test-Path -Path $testBackupDirectory) {
            Remove-Item -Path $testBackupDirectory -Recurse -Force | Out-Null
        }
    }

    It "Should create the backup directory if it does not exist" {
        Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
        Test-Path "C:\Temp\Backups" | Should -Be $true
    }

    It "Should copy the file to the backup directory with a timestamp" {
        $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
        $result | Should -Match "C:\\Temp\\Backups\\\d{14}_TestFile\.txt"
        Test-Path $result | Should -Be $true
    }

    AfterAll {
        # Clean up the test environment
        Remove-Item -Path "C:\Temp\Backups" -Recurse -Force | Out-Null
        Remove-Item -Path "C:\Temp\TestFile.txt" -Force | Out-Null
    }
}

