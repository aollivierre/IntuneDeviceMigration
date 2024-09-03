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


# Load the function to be tested
# . "$PSScriptRoot\..\Public\Backup-File.ps1"

# Load the function to be tested
# . "$PSScriptRoot\..\Public\Backup-File.ps1"

Describe "Backup-File" {

    Context "When the source file exists and the backup directory does not exist" {

        BeforeAll {
            # Mock the Test-Path command to simulate file existence
            Mock -CommandName Test-Path -MockWith {
                param ($Path)
                Write-Host "Mocked Test-Path called with Path: $Path" # Log the path being checked
                if ($Path -eq "C:\Temp\TestFile.txt") {
                    return $true  # Simulate that the source file exists
                }
                elseif ($Path -eq "C:\Temp\Backups") {
                    return $false  # Simulate that the backup directory does not exist
                }
                return $false
            }

            # Mock New-Item to simulate directory creation
            Mock -CommandName New-Item -MockWith {
                param ($Path, $ItemType)
                Write-Host "Mocked New-Item called to create: $Path of type $ItemType" # Log directory creation
                return $null  # Simulate successful directory creation
            }

            # Mock Copy-Item to simulate file copying
            Mock -CommandName Copy-Item -MockWith {
                param ($Path, $Destination)
                Write-Host "Mocked Copy-Item called to copy from $Path to $Destination" # Log file copy
                return $null  # Simulate successful file copying
            }
        }

        It "Should create the backup directory and copy the file with a timestamp" {
            $sourceFilePath = "C:\Temp\TestFile.txt"
            $backupDirectory = "C:\Temp\Backups"

            Write-Host "Starting test for Backup-File function" # Log start of the test

            $result = Backup-File -SourceFilePath $sourceFilePath -BackupDirectory $backupDirectory

            # Assert that New-Item was called to create the backup directory
            Assert-MockCalled -CommandName New-Item -Exactly -Times 1 -ParameterFilter {
                $Path -eq $backupDirectory -and $ItemType -eq "Directory"
            }

            # Assert that Copy-Item was called to copy the file to the backup directory
            Assert-MockCalled -CommandName Copy-Item -Exactly -Times 1 -ParameterFilter {
                $Path -eq $sourceFilePath -and $Destination -match "$backupDirectory\\\d{14}_TestFile.txt"
            }

            # Validate that the result is the expected backup file path
            $result | Should -Match "$backupDirectory\\\d{14}_TestFile.txt"
        }
    }
}
