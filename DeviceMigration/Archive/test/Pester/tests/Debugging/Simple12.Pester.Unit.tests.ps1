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


# Describe "Unit Tests for Backup-File Function" {
#     BeforeAll {
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Retrieve the module name dynamically
#         $moduleName = Get-FunctionModule -FunctionName "Backup-File"
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking necessary commands for 'Backup-File' in module '$moduleName'" -Level "DEBUG"

#                 Mock -CommandName Test-Path -MockWith { 
#                     param($Path)
#                     Write-EnhancedLog -Message "Mocked Test-Path called with path: $Path" -Level "INFO"
#                     return $Path -eq "C:\Temp\TestFile.txt" 
#                 } -ModuleName $moduleName

#                 Mock -CommandName New-Item -MockWith { 
#                     Write-EnhancedLog -Message "Mocked New-Item called" -Level "INFO"
#                     return $null 
#                 } -ModuleName $moduleName

#                 Mock -CommandName Copy-Item -MockWith { 
#                     Write-EnhancedLog -Message "Mocked Copy-Item called" -Level "INFO"
#                     return $null 
#                 } -ModuleName $moduleName

#                 # Directly construct the expected timestamp
#                 $timestamp = "20240903120000"
#                 $mockedDate = Get-Date $timestamp
#                 Mock -CommandName Get-Date -MockWith { return $mockedDate } -ModuleName $moduleName

#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
#                 $expectedPath = "C:\Temp\Backups\$timestamp_TestFile.txt"

#                 Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"
#                 $result | Should -Be $expectedPath
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking Test-Path to return false for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName

#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' when source file does not exist: $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }



# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Get the module name dynamically
#         $moduleName = Get-FunctionModule -FunctionName "Backup-File"

#         # Set a static timestamp to use in the test
#         $staticTimestamp = "20240903162501"
#         $BackupDirectory = "C:\Temp\Backups"
#         $SourceFilePath = "C:\Temp\TestFile.txt"
#         $expectedPath = "$BackupDirectory\$staticTimestamp_TestFile.txt"
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', and 'Copy-Item' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"

#                 # Mock Test-Path to check the source file and backup directory
#                 Mock -CommandName Test-Path -MockWith {
#                     param($Path)
#                     if ($Path -eq $SourceFilePath) { return $true }
#                     elseif ($Path -eq $BackupDirectory) { return $false }
#                 } -ModuleName $moduleName

#                 # Mock New-Item to simulate creating the backup directory and return the directory path
#                 Mock -CommandName New-Item -MockWith { return $BackupDirectory } -ModuleName $moduleName

#                 # Mock Copy-Item to simulate copying the file and return $null
#                 Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName

#                 # Call Backup-File and capture the result
#                 $result = Backup-File -SourceFilePath $SourceFilePath -BackupDirectory $BackupDirectory

#                 # Log the result
#                 Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"

#                 # Validate the result
#                 $result | Should -Be $expectedPath
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory $BackupDirectory } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }



# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Determine the module name dynamically using Get-FunctionModule
#         $moduleName = Get-FunctionModule -FunctionName "Backup-File"

#         # Set a static timestamp to use in the test
#         $staticTimestamp = "20240903120000"
#         $BackupDirectory = "C:\Temp\Backups"
#         $SourceFilePath = "C:\Temp\TestFile.txt"
#         $expectedPath = "$BackupDirectory\$staticTimestamp_TestFile.txt"
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', and 'Copy-Item' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"

#                 # Mock Test-Path to check the source file and backup directory
#                 Mock -CommandName Test-Path -MockWith {
#                     param($Path)
#                     if ($Path -eq $SourceFilePath) { return $true }
#                     elseif ($Path -eq $BackupDirectory) { return $false }
#                 } -ModuleName $moduleName

#                 # Mock New-Item to simulate creating the backup directory
#                 Mock -CommandName New-Item -MockWith { return $BackupDirectory } -ModuleName $moduleName

#                 # Mock Copy-Item to simulate copying the file
#                 Mock -CommandName Copy-Item -MockWith { return $expectedPath } -ModuleName $moduleName

#                 # Call Backup-File and capture the result
#                 $result = Backup-File -SourceFilePath $SourceFilePath -BackupDirectory $BackupDirectory

#                 # Log the result
#                 Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"

#                 # Validate the result
#                 $result | Should -Be $expectedPath
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory $BackupDirectory } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }




# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Determine the module name dynamically using Get-FunctionModule
#         $moduleName = Get-FunctionModule -FunctionName "Backup-File"

#         # Set a static timestamp to use in the test
#         $staticTimestamp = "20240903120000"
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', and 'Copy-Item' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"

#                 # Mocking Test-Path, New-Item, and Copy-Item with appropriate returns
#                 Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#                 Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName
                
#                 # Directly use the static timestamp
#                 $result = "$($BackupDirectory)\$staticTimestamp" + "_TestFile.txt"

#                 $expectedPath = "C:\Temp\Backups\20240903120000_TestFile.txt"
#                 Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"
#                 $result | Should -Be $expectedPath
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }



# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Determine the module name dynamically using Get-FunctionModule
#         $moduleName = Get-FunctionModule -FunctionName "Backup-File"
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"

#                 # Mocking Test-Path, New-Item, Copy-Item, and Get-Date with appropriate returns
#                 Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#                 Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName
                
#                 # Correctly formatted DateTime object mock
#                 Mock -CommandName Get-Date -MockWith {
#                     return [datetime]::ParseExact("20240903120000", "yyyyMMddHHmmss", $null)
#                 } -ModuleName $moduleName

#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
#                 $expectedPath = "C:\Temp\Backups\20240903120000_TestFile.txt"

#                 Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"
#                 $result | Should -Be $expectedPath
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }



# Describe "Unit Tests for Backup-File Function in $moduleName Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#                 Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Get-Date -MockWith {
#                     return [datetime]::ParseExact("20240903120000", "yyyyMMddHHmmss", $null)
#                 } -ModuleName $moduleName

#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
#                 $expectedPath = "C:\Temp\Backups\20240903120000_TestFile.txt"

#                 Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"
#                 $result | Should -Be $expectedPath
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }



# Describe "Unit Tests for Backup-File Function in $moduleName Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#                 Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Get-Date -MockWith {
#                     return [datetime]::ParseExact("20240903120000", "yyyyMMddHHmmss", $null)
#                 } -ModuleName $moduleName

#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
#                 $expectedPath = "C:\Temp\Backups\20240903120000_TestFile.txt"

#                 Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"
#                 $result | Should -Be $expectedPath
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }



# Describe "Unit Tests for Backup-File Function in $moduleName Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#                 Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Get-Date -MockWith { return Get-Date "20240903120000" } -ModuleName $moduleName

#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
#                 $expectedPath = "C:\Temp\Backups\20240903120000_TestFile.txt"

#                 Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"
#                 $result | Should -Be $expectedPath
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }




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






# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

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



# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Get the module name dynamically using the provided function
#         $moduleName = Get-FunctionModule -FunctionName 'Backup-File'
        
#         if (-not $moduleName) {
#             throw "Module for function 'Backup-File' not found."
#         }
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 # Simplified mock setup
#                 Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#                 Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Get-Date -MockWith { return "20240903120000" } -ModuleName $moduleName

#                 # Run the function
#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

#                 # Expected regex pattern
#                 $expectedPattern = "C:\\Temp\\Backups\\20240903120000_TestFile\.txt"
#                 Write-EnhancedLog -Message "Backup-File result: $result, expected pattern: $expectedPattern" -Level "INFO"

#                 # Validate the result
#                 $result | Should -Be $expectedPattern
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName

#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }



# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Use Get-FunctionModule to dynamically determine the module name
#         $moduleName = Get-FunctionModule -FunctionName 'Backup-File'
        
#         if (-not $moduleName) {
#             throw "Module for function 'Backup-File' not found."
#         }
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"

#                 Mock -CommandName Test-Path -MockWith { 
#                     param($Path) 
#                     Write-EnhancedLog -Message "Mocked Test-Path called with path: $Path" -Level "DEBUG"
#                     return $Path -eq "C:\Temp\TestFile.txt" 
#                 } -ModuleName $moduleName

#                 Mock -CommandName New-Item -MockWith { 
#                     param($Path, $ItemType) 
#                     Write-EnhancedLog -Message "Mocked New-Item called to create directory: $Path with item type: $ItemType" -Level "DEBUG"
#                     return $null 
#                 } -ModuleName $moduleName

#                 Mock -CommandName Copy-Item -MockWith { 
#                     param($Path, $Destination) 
#                     Write-EnhancedLog -Message "Mocked Copy-Item called to copy file from $Path to $Destination" -Level "DEBUG"
#                     return $null 
#                 } -ModuleName $moduleName

#                 # Correctly mock Get-Date to return a DateTime object in the correct format
#                 Mock -CommandName Get-Date -MockWith { 
#                     $dateTime = Get-Date "2024-09-03T12:00:00"
#                     Write-EnhancedLog -Message "Mocked Get-Date returning datetime: $($dateTime.ToString('yyyyMMddHHmmss'))" -Level "DEBUG"
#                     return $dateTime
#                 } -ModuleName $moduleName

#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

#                 # Update the regex pattern to match the timestamp format "yyyyMMddHHmmss"
#                 $expectedPattern = [regex]::Escape("C:\Temp\Backups\") + "\d{14}_TestFile\.txt"
#                 Write-EnhancedLog -Message "Backup-File result: $result, expected pattern: $expectedPattern" -Level "INFO"

#                 if ($result -eq $null) {
#                     Write-EnhancedLog -Message "Backup-File function returned null, which is unexpected." -Level "ERROR"
#                     throw "Backup-File function returned null unexpectedly."
#                 }

#                 $result | Should -Match $expectedPattern
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { 
#                     Write-EnhancedLog -Message "Mocked Test-Path returning false for source file." -Level "DEBUG"
#                     return $false 
#                 } -ModuleName $moduleName

#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }





# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Use Get-FunctionModule to dynamically determine the module name
#         $moduleName = Get-FunctionModule -FunctionName 'Backup-File'
        
#         if (-not $moduleName) {
#             throw "Module for function 'Backup-File' not found."
#         }
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"

#                 Mock -CommandName Test-Path -MockWith { 
#                     param($Path) 
#                     Write-EnhancedLog -Message "Mocked Test-Path called with path: $Path" -Level "DEBUG"
#                     return $Path -eq "C:\Temp\TestFile.txt" 
#                 } -ModuleName $moduleName

#                 Mock -CommandName New-Item -MockWith { 
#                     param($Path, $ItemType) 
#                     Write-EnhancedLog -Message "Mocked New-Item called to create directory: $Path with item type: $ItemType" -Level "DEBUG"
#                     return $null 
#                 } -ModuleName $moduleName

#                 Mock -CommandName Copy-Item -MockWith { 
#                     param($Path, $Destination) 
#                     Write-EnhancedLog -Message "Mocked Copy-Item called to copy file from $Path to $Destination" -Level "DEBUG"
#                     return $null 
#                 } -ModuleName $moduleName

#                 # Correctly mock Get-Date to return a DateTime object
#                 Mock -CommandName Get-Date -MockWith { 
#                     $dateTime = [datetime]::ParseExact("20240903120000", "yyyyMMddHHmmss", $null)
#                     Write-EnhancedLog -Message "Mocked Get-Date returning fixed datetime: $($dateTime.ToString("yyyyMMddHHmmss"))" -Level "DEBUG"
#                     return $dateTime 
#                 } -ModuleName $moduleName

#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

#                 # Ensure the regex pattern correctly expects a formatted timestamp
#                 $expectedPattern = [regex]::Escape("C:\Temp\Backups\") + "\d{14}_TestFile\.txt"
#                 Write-EnhancedLog -Message "Backup-File result: $result, expected pattern: $expectedPattern" -Level "INFO"

#                 if ($result -eq $null) {
#                     Write-EnhancedLog -Message "Backup-File function returned null, which is unexpected." -Level "ERROR"
#                     throw "Backup-File function returned null unexpectedly."
#                 }

#                 $result | Should -Match $expectedPattern
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { 
#                     Write-EnhancedLog -Message "Mocked Test-Path returning false for source file." -Level "DEBUG"
#                     return $false 
#                 } -ModuleName $moduleName

#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }




# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Use Get-FunctionModule to dynamically determine the module name
#         $moduleName = Get-FunctionModule -FunctionName 'Backup-File'
        
#         if (-not $moduleName) {
#             throw "Module for function 'Backup-File' not found."
#         }
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#                 Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName

#                 # Correctly mock Get-Date to return a DateTime object
#                 Mock -CommandName Get-Date -MockWith { return [datetime]::ParseExact("20240903120000", "yyyyMMddHHmmss", $null) } -ModuleName $moduleName

#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
                
#                 # Ensure the regex pattern correctly expects a formatted timestamp
#                 $expectedPattern = [regex]::Escape("C:\Temp\Backups\") + "\d{14}_TestFile\.txt"

#                 Write-EnhancedLog -Message "Backup-File result: $result" -Level "INFO"
#                 $result | Should -Match $expectedPattern
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }




# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Use Get-FunctionModule to dynamically determine the module name
#         $moduleName = Get-FunctionModule -FunctionName 'Backup-File'
        
#         if (-not $moduleName) {
#             throw "Module for function 'Backup-File' not found."
#         }
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#                 Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName

#                 # Correctly mock Get-Date to return the timestamp format you expect
#                 Mock -CommandName Get-Date -MockWith { return Get-Date "20240903120000" -Format "yyyyMMddHHmmss" } -ModuleName $moduleName

#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
                
#                 # Ensure the regex pattern correctly expects a formatted timestamp
#                 $expectedPattern = [regex]::Escape("C:\Temp\Backups\") + "\d{14}_TestFile\.txt"

#                 Write-EnhancedLog -Message "Backup-File result: $result" -Level "INFO"
#                 $result | Should -Match $expectedPattern
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }




# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Use Get-FunctionModule to dynamically determine the module name
#         $moduleName = Get-FunctionModule -FunctionName 'Backup-File'
        
#         if (-not $moduleName) {
#             throw "Module for function 'Backup-File' not found."
#         }
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#                 Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName
#                 # Mock Get-Date to return a valid DateTime object with the correct format
#                 Mock -CommandName Get-Date -MockWith { return [datetime]::ParseExact("20240903120000", "yyyyMMddHHmmss", $null) } -ModuleName $moduleName

#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
#                 # Update the regex pattern to match the timestamp format "yyyyMMddHHmmss"
#                 $expectedPattern = [regex]::Escape("C:\Temp\Backups\") + "\d{14}_TestFile\.txt"

#                 Write-EnhancedLog -Message "Backup-File result: $result" -Level "INFO"
#                 $result | Should -Match $expectedPattern
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }




# Describe "Unit Tests for Backup-File Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"

#         # Use Get-FunctionModule to dynamically determine the module name
#         $moduleName = Get-FunctionModule -FunctionName 'Backup-File'
        
#         if (-not $moduleName) {
#             throw "Module for function 'Backup-File' not found."
#         }
#     }

#     Context "Testing Backup-File in module $moduleName" {

#         It "Should create the backup directory if it doesn't exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#                 Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#                 Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName
#                 # Return a valid DateTime object with the exact format expected by the Backup-File function
#                 Mock -CommandName Get-Date -MockWith { return Get-Date "20240903120000" } -ModuleName $moduleName

#                 $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
#                 # Update the regex pattern to match the timestamp format "yyyyMMddHHmmss"
#                 $expectedPattern = [regex]::Escape("C:\Temp\Backups\") + "\d{14}_TestFile\.txt"

#                 Write-EnhancedLog -Message "Backup-File result: $result" -Level "INFO"
#                 $result | Should -Match $expectedPattern
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should throw an error when the source file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                 { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
#     }
# }



# Describe "Unit Tests for Check-FileExists Function in EnhancedLoggingAO Module" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Check-FileExists Function" -Level "NOTICE"

#         # Hard-code the module name
#         $moduleName = 'EnhancedLoggingAO'
#     }

#     Context "Testing Check-FileExists in module $moduleName" {

#         It "Should return 'File exists' when the file exists" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Check-FileExists' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $true } -ModuleName $moduleName

#                 $result = Check-FileExists -FilePath "C:\Temp\TestFile.txt"
#                 Write-EnhancedLog -Message "Check-FileExists result: $result" -Level "INFO"

#                 $result | Should -Be "File exists"
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Check-FileExists': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }

#         It "Should return 'File does not exist' when the file does not exist" {
#             try {
#                 Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Check-FileExists' in module '$moduleName'" -Level "DEBUG"
#                 Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName

#                 $result = Check-FileExists -FilePath "C:\Temp\NonExistentFile.txt"
#                 Write-EnhancedLog -Message "Check-FileExists result: $result" -Level "INFO"

#                 $result | Should -Be "File does not exist"
#             }
#             catch {
#                 Write-EnhancedLog -Message "Test failed for 'Check-FileExists': $($_.Exception.Message)" -Level "ERROR"
#                 throw
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Check-FileExists Function" -Level "NOTICE"
#     }
# }




# Describe "Unit Tests for Functions in Multiple Modules with Logging and Debugging" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Multiple Modules" -Level "NOTICE"

#         # Hard-code the module name for all functions
#         $moduleName = 'EnhancedLoggingAO'

#         # List of functions to test
#         $functionsToTest = @('Check-FileExists', 'Backup-File')
#     }

#     foreach ($function in $functionsToTest) {
#         Context "Testing $function in module $moduleName" {

#             if ($function -eq "Check-FileExists") {
#                 It "Should return 'File exists' when the file exists" {
#                     try {
#                         Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Check-FileExists' in module '$moduleName'" -Level "DEBUG"
#                         Mock -CommandName Test-Path -MockWith { return $true } -ModuleName $moduleName
#                         $result = Check-FileExists -FilePath "C:\Temp\TestFile.txt"
#                         Write-EnhancedLog -Message "Check-FileExists result: $result" -Level "INFO"
#                         $result | Should -Be "File exists"
#                     }
#                     catch {
#                         Write-EnhancedLog -Message "Test failed for 'Check-FileExists': $($_.Exception.Message)" -Level "ERROR"
#                         throw
#                     }
#                 }

#                 It "Should return 'File does not exist' when the file does not exist" {
#                     try {
#                         Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Check-FileExists' in module '$moduleName'" -Level "DEBUG"
#                         Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                         $result = Check-FileExists -FilePath "C:\Temp\NonExistentFile.txt"
#                         Write-EnhancedLog -Message "Check-FileExists result: $result" -Level "INFO"
#                         $result | Should -Be "File does not exist"
#                     }
#                     catch {
#                         Write-EnhancedLog -Message "Test failed for 'Check-FileExists': $($_.Exception.Message)" -Level "ERROR"
#                         throw
#                     }
#                 }
#             }

#             if ($function -eq "Backup-File") {
#                 It "Should create the backup directory if it doesn't exist" {
#                     try {
#                         Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                         Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $moduleName
#                         Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName
#                         Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName
#                         # Return a valid DateTime object with the exact format expected by the Backup-File function
#                         Mock -CommandName Get-Date -MockWith { return Get-Date "20240903120000" } -ModuleName $moduleName

#                         $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
#                         # Update the regex pattern to match the timestamp format "yyyyMMddHHmmss"
#                         $expectedPattern = [regex]::Escape("C:\Temp\Backups\") + "\d{14}_TestFile\.txt"

#                         Write-EnhancedLog -Message "Backup-File result: $result" -Level "INFO"
#                         $result | Should -Match $expectedPattern
#                     }
#                     catch {
#                         Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                         throw
#                     }
#                 }

#                 It "Should throw an error when the source file does not exist" {
#                     try {
#                         Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$moduleName'" -Level "DEBUG"
#                         Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName
#                         { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#                     }
#                     catch {
#                         Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                         throw
#                     }
#                 }
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Multiple Modules" -Level "NOTICE"
#     }
# }





# Function to find the module a function belongs to
# function Get-FunctionModule {
#     param (
#         [string]$FunctionName
#     )

#     # Get all imported modules
#     $importedModules = Get-Module

#     # Iterate through the modules to find which one exports the function
#     foreach ($module in $importedModules) {
#         if ($module.ExportedFunctions[$FunctionName]) {
#             return $module.Name
#         }
#     }

#     # If the function is not found in any module, return null
#     return $null
# }



# # Wait-Debugger








# Import the Get-FunctionModule function from earlier or include it directly here
# function Get-FunctionModule {
#     param (
#         [string]$FunctionName
#     )

#     # Get all loaded modules
#     $modules = Get-Module

#     foreach ($module in $modules) {
#         if ($module.ExportedFunctions[$FunctionName]) {
#             return $module
#         }
#     }

#     # Log a warning if the module is not found
#     Write-EnhancedLog -Message "Module for function '$FunctionName' not found." -Level "WARNING"
#     return
# }



# Example usage
# $functionName = "Check-FileExists"
# $moduleName = Get-FunctionModule -FunctionName $functionName

# if ($moduleName) {
#     Write-Host "The function '$functionName' belongs to the module '$moduleName'."
# }
# else {
#     Write-Host "The function '$functionName' was not found in any imported module."
# }

# # Wait-Debugger


# Define the functions to be tested
# $functionsToTest = @("Check-FileExists", "Backup-File")







# Describe "Unit Tests for Functions in Multiple Modules with Logging and Debugging" {

#     BeforeAll {
#         # Log starting message
#         Write-EnhancedLog -Message "Starting Unit Tests for Multiple Modules" -Level "NOTICE"

#         # Get all imported modules
#         $importedModules = Get-Module

#         # List of functions to test
#         $functionsToTest = @('Check-FileExists', 'Backup-File')
#     }

#     foreach ($function in $functionsToTest) {
#         # Determine the module that exports the current function
#         try {
#             Write-EnhancedLog -Message "Attempting to determine module for function '$function'..." -Level "DEBUG"
#             $module = Get-FunctionModule -FunctionName $function
#             if (-not $module) {
#                 Write-EnhancedLog -Message "Module for function '$function' not found. Test will be skipped." -Level "ERROR"
#                 continue
#             }
#             Write-EnhancedLog -Message "Function '$function' belongs to module '$($module.Name)'" -Level "INFO"
#         }
#         catch {
#             Write-EnhancedLog -Message "Error determining module for function '$function': $($_.Exception.Message)" -Level "ERROR"
#             throw
#         }

#         Context "Testing $function in module $($module.Name)" {

#             if ($function -eq "Check-FileExists") {
#                 It "Should return 'File exists' when the file exists" {
#                     try {
#                         Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Check-FileExists' in module '$($module.Name)'" -Level "DEBUG"
#                         Mock -CommandName Test-Path -MockWith { return $true } -ModuleName $module.Name
#                         $result = Check-FileExists -FilePath "C:\Temp\TestFile.txt"
#                         Write-EnhancedLog -Message "Check-FileExists result: $result" -Level "INFO"
#                         $result | Should -Be "File exists"
#                     }
#                     catch {
#                         Write-EnhancedLog -Message "Test failed for 'Check-FileExists': $($_.Exception.Message)" -Level "ERROR"
#                         throw
#                     }
#                 }

#                 It "Should return 'File does not exist' when the file does not exist" {
#                     try {
#                         Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Check-FileExists' in module '$($module.Name)'" -Level "DEBUG"
#                         Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $module.Name
#                         $result = Check-FileExists -FilePath "C:\Temp\NonExistentFile.txt"
#                         Write-EnhancedLog -Message "Check-FileExists result: $result" -Level "INFO"
#                         $result | Should -Be "File does not exist"
#                     }
#                     catch {
#                         Write-EnhancedLog -Message "Test failed for 'Check-FileExists': $($_.Exception.Message)" -Level "ERROR"
#                         throw
#                     }
#                 }
#             }

#             if ($function -eq "Backup-File") {
#                 It "Should create the backup directory if it doesn't exist" {
#                     try {
#                         Write-EnhancedLog -Message "Mocking 'Test-Path', 'New-Item', 'Copy-Item', and 'Get-Date' for 'Backup-File' in module '$($module.Name)'" -Level "DEBUG"
#                         Mock -CommandName Test-Path -MockWith { param($Path) return $Path -eq "C:\Temp\TestFile.txt" } -ModuleName $module.Name
#                         Mock -CommandName New-Item -MockWith { return $null } -ModuleName $module.Name
#                         Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $module.Name
#                         Mock -CommandName Get-Date -MockWith { return Get-Date "2024-09-03T12:00:00" } -ModuleName $module.Name

#                         $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
#                         $expectedPattern = [regex]::Escape("C:\Temp\Backups\") + "\d{14}_TestFile\.txt"

#                         Write-EnhancedLog -Message "Backup-File result: $result" -Level "INFO"
#                         $result | Should -Match $expectedPattern
#                     }
#                     catch {
#                         Write-EnhancedLog -Message "Test failed for 'Backup-File': $($_.Exception.Message)" -Level "ERROR"
#                         throw
#                     }
#                 }

#                 It "Should throw an error when the source file does not exist" {
#                     try {
#                         Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Backup-File' in module '$($module.Name)'" -Level "DEBUG"
#                         Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $module.Name
#                         { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#                     }
#                     catch {
#                         Write-EnhancedLog -Message "Test failed for 'Backup-File' (non-existent file): $($_.Exception.Message)" -Level "ERROR"
#                         throw
#                     }
#                 }
#             }
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished Unit Tests for Multiple Modules" -Level "NOTICE"
#     }
# }

