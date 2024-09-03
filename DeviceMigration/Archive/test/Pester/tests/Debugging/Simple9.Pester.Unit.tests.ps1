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



Describe "Backup-File - Unit Tests" {
    
    # Set up the necessary mocks
    BeforeAll {
        Mock -CommandName Test-Path -MockWith {
            param ($Path)
            if ($Path -eq "C:\Temp\TestFile.txt") { return $true }
            if ($Path -eq "C:\Temp\Backups") { return $false }
            return $false
        }

        Mock -CommandName New-Item -MockWith {
            param ($Path, $ItemType)
            return $null
        }

        Mock -CommandName Copy-Item -MockWith {
            param ($Path, $Destination)
            return $null
        }

        Mock -CommandName Get-Date -MockWith {
            return [datetime]::ParseExact("20240101010101", "yyyyMMddHHmmss", $null)
        }
    }

    It "Should create the backup directory if it does not exist" {
        Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

        Assert-MockCalled -CommandName New-Item -Exactly -Times 1 -ParameterFilter {
            $Path -eq "C:\Temp\Backups" -and $ItemType -eq "Directory"
        }
    }

    It "Should copy the file to the backup directory with a timestamp" {
        $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
        $expectedBackupFilePath = "C:\Temp\Backups\20240101010101_TestFile.txt"

        $result | Should -Be $expectedBackupFilePath
        Assert-MockCalled -CommandName Copy-Item -Exactly -Times 1 -ParameterFilter {
            $Path -eq "C:\Temp\TestFile.txt" -and $Destination -eq $expectedBackupFilePath
        }
    }
}
