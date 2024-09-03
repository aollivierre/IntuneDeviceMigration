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




# Function to get the module name dynamically
function Get-FunctionModule {
    param (
        [string]$FunctionName
    )

    # Get all imported modules
    $importedModules = Get-Module

    # Iterate through the modules to find which one exports the function
    foreach ($module in $importedModules) {
        if ($module.ExportedFunctions[$FunctionName]) {
            return $module.Name
        }
    }

    # If the function is not found in any module, return null
    return $null
}

# Get the module name for the 'Backup-File' function
$moduleName = Get-FunctionModule -FunctionName 'Backup-File'


Describe "Unit Tests for Backup-File Function in $moduleName Module" {

    BeforeAll {
        Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"
        $moduleName = Get-FunctionModule -FunctionName 'Backup-File'
    }

    Context "Testing Backup-File in module $moduleName" {

        It "Should create the backup directory if it doesn't exist" {
            Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
            Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
            Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName
            Mock -CommandName Get-Date -MockWith { return "20240903120000" } -ModuleName $moduleName

            $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

            # Sanitize the result by ensuring it's a single string value
            if ($result -is [array]) {
                $result = $result | Where-Object { $_ -ne $null }
            }

            $expectedPath = "C:\Temp\Backups\20240903120000_TestFile.txt"

            Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"
            $result | Should -Be $expectedPath
        }

        It "Should throw an error when the source file does not exist" {
            Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
            { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
        }
    }

    AfterAll {
        Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
    }
}