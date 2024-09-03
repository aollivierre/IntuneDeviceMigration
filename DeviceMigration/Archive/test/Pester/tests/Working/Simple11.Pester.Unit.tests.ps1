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




# Function to dynamically retrieve the module name
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

Describe "Unit Tests for Check-FileExists Function in EnhancedLoggingAO Module" {

    BeforeAll {
        # Log starting message
        Write-EnhancedLog -Message "Starting Unit Tests for Check-FileExists Function" -Level "NOTICE"

        # Use Get-FunctionModule to dynamically determine the module name
        $moduleName = Get-FunctionModule -FunctionName 'Check-FileExists'
        
        if (-not $moduleName) {
            throw "Module for function 'Check-FileExists' not found."
        }
    }

    Context "Testing Check-FileExists in module $moduleName" {

        It "Should return 'File exists' when the file exists" {
            try {
                Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Check-FileExists' in module '$moduleName'" -Level "DEBUG"
                Mock -CommandName Test-Path -MockWith { return $true } -ModuleName $moduleName

                $result = Check-FileExists -FilePath "C:\Temp\TestFile.txt"
                Write-EnhancedLog -Message "Check-FileExists result: $result" -Level "INFO"

                $result | Should -Be "File exists"
            }
            catch {
                Write-EnhancedLog -Message "Test failed for 'Check-FileExists': $($_.Exception.Message)" -Level "ERROR"
                throw
            }
        }

        It "Should return 'File does not exist' when the file does not exist" {
            try {
                Write-EnhancedLog -Message "Mocking 'Test-Path' for 'Check-FileExists' in module '$moduleName'" -Level "DEBUG"
                Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName

                $result = Check-FileExists -FilePath "C:\Temp\NonExistentFile.txt"
                Write-EnhancedLog -Message "Check-FileExists result: $result" -Level "INFO"

                $result | Should -Be "File does not exist"
            }
            catch {
                Write-EnhancedLog -Message "Test failed for 'Check-FileExists': $($_.Exception.Message)" -Level "ERROR"
                throw
            }
        }
    }

    AfterAll {
        Write-EnhancedLog -Message "Finished Unit Tests for Check-FileExists Function" -Level "NOTICE"
    }
}



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

