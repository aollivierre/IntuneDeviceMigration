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



# # Define the module name at the top to make it easily accessible throughout the script
# $moduleName = Get-FunctionModule -FunctionName 'Backup-File'

# Log the start of the tests
BeforeAll {
    Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"
}

# 1. Test case: Ensuring the backup directory is checked if it exists
Describe "Test Backup-File - Checks if Backup Directory Exists" {

    It "Should check if the backup directory exists" {
        Mock -CommandName Test-Path -MockWith { param($Path) return $false } -ModuleName $moduleName

        Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

        # Verify that Test-Path was called to check the backup directory
        Assert-MockCalled -CommandName Test-Path -Exactly 1 -Scope It
    }
}

Wait-Debugger

# 2. Test case: Creating the backup directory if it doesn't exist
Describe "Test Backup-File - Creates Backup Directory" {

    It "Should create the backup directory if it doesn't exist" {
        Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName

        Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

        # Verify that New-Item was called to create the directory
        Assert-MockCalled -CommandName New-Item -Exactly 1 -Scope It
    }
}

# 3. Test case: Copying the file to the backup directory with a timestamp
Describe "Test Backup-File - Copies File with Timestamp" {

    It "Should copy the file to the backup directory with a timestamp" {
        Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName

        Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

        # Verify that Copy-Item was called to copy the file
        Assert-MockCalled -CommandName Copy-Item -Exactly 1 -Scope It
    }
}

# 4. Test case: Getting the current date for timestamping the file
Describe "Test Backup-File - Gets Current Date for Timestamp" {

    It "Should get the current date for the timestamp" {
        Mock -CommandName Get-Date -MockWith { return "20240903120000" } -ModuleName $moduleName

        $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
        $expectedPath = "C:\Temp\Backups\20240903120000_TestFile.txt"

        # Sanitize the result by ensuring it's a single string value
        if ($result -is [array]) {
            $result = $result | Where-Object { $_ -ne $null }
        }

        Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"
        $result | Should -Be $expectedPath
    }
}

# 5. Test case: Handling non-existent source file
Describe "Test Backup-File - Handles Non-Existent Source File" {

    It "Should throw an error when the source file does not exist" {
        Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName

        { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
    }
}

# Log the completion of the tests
AfterAll {
    Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
}




# Describe "Unit Tests for Backup-File Function in $moduleName Module" {

#     BeforeAll {
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"
#         $moduleName = Get-FunctionModule -FunctionName 'Backup-File'
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#             Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#             Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName
#             Mock -CommandName Get-Date -MockWith { return "20240903120000" } -ModuleName $moduleName

#             $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

#             # Sanitize the result by ensuring it's a single string value
#             if ($result -is [array]) {
#                 $result = $result | Where-Object { $_ -ne $null }
#             }

#             $expectedPath = "C:\Temp\Backups\20240903120000_TestFile.txt"

#             Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"
#             $result | Should -Be $expectedPath
#         }

#         It "Should throw an error when the source file does not exist" {
#             Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#             { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }