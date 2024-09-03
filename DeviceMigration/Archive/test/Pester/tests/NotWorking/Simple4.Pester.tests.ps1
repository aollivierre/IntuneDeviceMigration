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


# Import Pester
Import-Module Pester

# Assume Write-Log is a function you would normally import from a module
function Write-Log {
    param (
        [string]$Message,
        [string]$Level
    )
    # Original implementation that you don't want to run in the test
    Write-Host "[$Level] $Message"
}

Describe "Log-Message" {

    Context "With mock in place" {
        BeforeAll {
            # Mock the Write-Log function
            Mock -CommandName Write-Log -MockWith {
                param ($Message, $Level)
                # Simulate logging
            }
        }

        It "Should call Write-Log with the correct parameters" {
            Log-Message -Message "Test message" -Level "DEBUG"

            # Verify that Write-Log was called with the correct parameters
            Assert-MockCalled -CommandName Write-Log -Exactly -Scope It -ParameterFilter {
                $Message -eq "Test message" -and $Level -eq "DEBUG"
            }
        }

        AfterAll {
            # Remove the mock
            Remove-Mock -CommandName Write-Log
        }
    }

    Context "Without mock in place" {
        It "Should call the original Write-Log function" {
            Log-Message -Message "Real log message" -Level "ERROR"

            # No need for assertions; this should execute the real Write-Log
        }
    }
}
