# Import the module or script containing Remove-MigrationFiles function
# . $PSScriptRoot\Remove-MigrationFiles.ps1


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


Describe "Remove-MigrationFiles Function Tests" {

    BeforeAll {
        # Setup: Variables and Mocking
        $testDirectories = @(
            "C:\Temp\TestFolder1",
            "C:\Temp\TestFolder2",
            "C:\Temp\TestFolder3"
        )
    }

    Context "When Directories exist and are successfully removed" {

        BeforeEach {
            # Ensure test directories exist before each test
            $testDirectories | ForEach-Object { New-Item -ItemType Directory -Force -Path $_ }
        }

        It "should remove each specified directory" {
            # Mock the Remove-EnhancedItem command and ensure it is tracked
            Mock -CommandName Remove-EnhancedItem -MockWith {
                param ($Path)
                Remove-Item -Path $Path -Recurse -Force
                Set-Variable -Name 'RemoveEnhancedItemCalled' -Value $true -Scope Global
            }

            Remove-MigrationFiles -Directories $testDirectories

            $testDirectories | ForEach-Object {
                $_ | Should -Not -Exist -Because "The directory should be removed."
            }

            Assert-MockCalled -CommandName Remove-EnhancedItem -Times ($testDirectories.Count) -Exactly -Scope It
        }

        AfterEach {
            # Clean up any residual directories (in case of failure)
            $testDirectories | ForEach-Object { Remove-Item -Recurse -Force -Path $_ -ErrorAction SilentlyContinue }
        }
    }

    Context "When a directory does not exist" {

        BeforeEach {
            # Ensure that only one directory exists for testing
            New-Item -ItemType Directory -Force -Path $testDirectories[0]
        }

        It "should log a warning and continue removing the others" {
            # Mock Test-Path to return false for non-existent directories
            Mock -CommandName Test-Path -MockWith {
                param ($Path)
                return $Path -eq $testDirectories[0]
            }

            # Mock the Remove-EnhancedItem command
            Mock -CommandName Remove-EnhancedItem

            Remove-MigrationFiles -Directories $testDirectories

            Assert-MockCalled -CommandName Remove-EnhancedItem -Times 1 -Exactly -Scope It
        }

        AfterEach {
            # Clean up any residual directories (in case of failure)
            $testDirectories | ForEach-Object { Remove-Item -Recurse -Force -Path $_ -ErrorAction SilentlyContinue }
        }
    }

    Context "Error Handling" {

        It "should throw an error if Remove-EnhancedItem fails" {
            # Mock the Remove-EnhancedItem command to simulate failure
            Mock -CommandName Remove-EnhancedItem -MockWith {
                throw "Simulated failure"
            }

            { Remove-MigrationFiles -Directories $testDirectories } | Should -Throw -Because "The function should throw when an error occurs."
        }
    }
}

