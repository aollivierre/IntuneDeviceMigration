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

# 1. Test case: Ensuring the backup directory is checked if it exists
Describe "Test Backup-File - Checks if Backup Directory Exists" {

    BeforeAll {
        $testSourceFile = "C:\Temp\TestFile.txt"
        $testBackupDirectory = "C:\Temp\Backups"
        Write-EnhancedLog -Message "Starting test for checking if backup directory exists." -Level "INFO"
        Write-EnhancedLog -Message "Test setup: Source file path is '$testSourceFile', Backup directory is '$testBackupDirectory'" -Level "INFO"
    }

    It "Should check if the backup directory exists" {
        try {
            $moduleName = Get-FunctionModule -FunctionName 'Backup-File'  # Define module name right before the mock

            Mock -CommandName Test-Path -MockWith {
                param($Path)
                Write-EnhancedLog -Message "Mocking Test-Path for path '$Path'" -Level "INFO"
                if ($Path -eq $testBackupDirectory) {
                    return $false  # Mock that the backup directory does not exist
                }
                elseif ($Path -eq $testSourceFile) {
                    return $true  # Mock that the source file exists
                }
                throw "Unexpected path passed to Test-Path: $Path"
            } -ModuleName $moduleName

            Backup-File -SourceFilePath $testSourceFile -BackupDirectory $testBackupDirectory

            # Expect Test-Path to be called twice: once for the source file and once for the backup directory
            Assert-MockCalled -CommandName Test-Path -Exactly 2 -ModuleName $moduleName -Scope It
            Write-EnhancedLog -Message "Successfully completed test for checking if backup directory exists." -Level "INFO"

        }
        catch {
            Write-EnhancedLog -Message "Error in Mocked Test-Path: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    AfterAll {
        Write-EnhancedLog -Message "Finished test for checking if backup directory exists." -Level "INFO"
    }
}

# 2. Test case: Creating the backup directory if it doesn't exist
Describe "Test Backup-File - Creates Backup Directory" {

    BeforeAll {
        $testSourceFile = "C:\Temp\TestFile.txt"
        $testBackupDirectory = "C:\Temp\Backups"
        Write-EnhancedLog -Message "Starting test for creating backup directory." -Level "INFO"
        Write-EnhancedLog -Message "Test setup: Source file path is '$testSourceFile', Backup directory is '$testBackupDirectory'" -Level "INFO"
    }

    It "Should create the backup directory if it doesn't exist" {
        try {
            $moduleName = Get-FunctionModule -FunctionName 'Backup-File'  # Define module name right before the mock

            # Mock Test-Path to return true for the source file, so the function proceeds to directory creation
            Mock -CommandName Test-Path -MockWith {
                param($Path)
                Write-EnhancedLog -Message "Mocking Test-Path for path '$Path'" -Level "INFO"
                if ($Path -eq $testSourceFile) {
                    return $true  # Mock that the source file exists
                } elseif ($Path -eq $testBackupDirectory) {
                    return $false  # Mock that the backup directory does not exist
                }
                throw "Unexpected path passed to Test-Path: $Path"
            } -ModuleName $moduleName

            # Mock New-Item to simulate the creation of the backup directory
            Mock -CommandName New-Item -MockWith {
                Write-EnhancedLog -Message "Mocking New-Item to create directory '$testBackupDirectory'" -Level "INFO"
                return $null
            } -ModuleName $moduleName

            Backup-File -SourceFilePath $testSourceFile -BackupDirectory $testBackupDirectory

            # Verify that New-Item was called to create the directory
            Assert-MockCalled -CommandName New-Item -Exactly 1 -ModuleName $moduleName -Scope It
            Write-EnhancedLog -Message "Successfully completed test for creating backup directory." -Level "INFO"

        } catch {
            Write-EnhancedLog -Message "Error in Mocked New-Item: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    AfterAll {
        Write-EnhancedLog -Message "Finished test for creating backup directory." -Level "INFO"
    }
}

# 3. Test case: Copying the file to the backup directory with a timestamp
Describe "Test Backup-File - Copies File with Timestamp" {

    BeforeAll {
        $testSourceFile = "C:\Temp\TestFile.txt"
        $testBackupDirectory = "C:\Temp\Backups"
        $timestamp = "20240903120000"  # Example timestamp
        $backupFilePath = "$testBackupDirectory\$timestamp_TestFile.txt"
        Write-EnhancedLog -Message "Starting test for copying file with timestamp." -Level "INFO"
        Write-EnhancedLog -Message "Test setup: Source file path is '$testSourceFile', Backup file path is '$backupFilePath'" -Level "INFO"
    }

    It "Should copy the file to the backup directory with a timestamp" {
        try {
            $moduleName = Get-FunctionModule -FunctionName 'Backup-File'  # Define module name right before the mock

            # Mock Test-Path to simulate the source file existence and directory creation as in previous tests
            Mock -CommandName Test-Path -MockWith {
                param($Path)
                Write-EnhancedLog -Message "Mocking Test-Path for path '$Path'" -Level "INFO"
                if ($Path -eq $testSourceFile) {
                    return $true  # Mock that the source file exists
                } elseif ($Path -eq $testBackupDirectory) {
                    return $true  # Mock that the backup directory exists
                }
                throw "Unexpected path passed to Test-Path: $Path"
            } -ModuleName $moduleName

            # Directly return the formatted timestamp as a string
            Mock -CommandName Get-Date -MockWith {
                Write-EnhancedLog -Message "Mocking Get-Date to return formatted timestamp '$timestamp'" -Level "INFO"
                return $timestamp
            } -ModuleName $moduleName

            # Mock Copy-Item to simulate copying the file
            Mock -CommandName Copy-Item -MockWith {
                Write-EnhancedLog -Message "Mocking Copy-Item to copy file to '$backupFilePath'" -Level "INFO"
                return $null
            } -ModuleName $moduleName

            Backup-File -SourceFilePath $testSourceFile -BackupDirectory $testBackupDirectory

            # Verify that Copy-Item was called to copy the file
            Assert-MockCalled -CommandName Copy-Item -Exactly 1 -ModuleName $moduleName -Scope It
            Write-EnhancedLog -Message "Successfully completed test for copying file with timestamp." -Level "INFO"

        } catch {
            Write-EnhancedLog -Message "Error in Mocked Copy-Item: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    AfterAll {
        Write-EnhancedLog -Message "Finished test for copying file with timestamp." -Level "INFO"
    }
}

# 4. Test case: Getting the current date for timestamping the file
Describe "Test Backup-File - Gets Current Date for Timestamp" {

    It "Should generate a backup file path with the correct timestamp" {
        try {
            $moduleName = Get-FunctionModule -FunctionName 'Backup-File'  # Define module name right before the mock
            
            # Mock the necessary commands
            Mock -CommandName Test-Path -MockWith {
                param($Path)
                if ($Path -eq "C:\Temp\TestFile.txt") {
                    return $true
                } elseif ($Path -eq "C:\Temp\Backups") {
                    return $true
                }
                throw "Unexpected path: $Path"
            } -ModuleName $moduleName

            Mock -CommandName Get-Date -MockWith { return "09/03/2024 12:00:00" } -ModuleName $moduleName

            # Expected sanitized path
            $expectedPath = "C:\Temp\Backups\09032024120000_TestFile.txt"

            # Invoke the Backup-File function
            $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

            # Sanitize the result by ensuring it's a single string value
            if ($result -is [array]) {
                $result = $result | Where-Object { $_ -ne $null }
            }

            Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"
            $result | Should -BeExactly $expectedPath

        } catch {
            Write-EnhancedLog -Message "Error in test for getting current date: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }
}

# 5. Test case: Handling non-existent source file
Describe "Test Backup-File - Handles Non-Existent Source File" {

    BeforeAll {
        $testSourceFile = "C:\Temp\NonExistentFile.txt"
        $testBackupDirectory = "C:\Temp\Backups"
        Write-EnhancedLog -Message "Starting test for handling non-existent source file." -Level "INFO"
        Write-EnhancedLog -Message "Test setup: Source file path is '$testSourceFile', Backup directory is '$testBackupDirectory'" -Level "INFO"
    }

    It "Should throw an error when the source file does not exist" {
        try {
            # Mock Test-Path to simulate the source file not existing
            Mock -CommandName Test-Path -MockWith {
                param($Path)
                Write-EnhancedLog -Message "Mocking Test-Path for path '$Path' to return false" -Level "INFO"
                return $false  # Mock that the source file does not exist
            } -ModuleName $moduleName

            # Test that Backup-File throws the expected error
            { Backup-File -SourceFilePath $testSourceFile -BackupDirectory $testBackupDirectory } | Should -Throw "Source file does not exist."

            Write-EnhancedLog -Message "Test completed: Error correctly thrown for non-existent source file." -Level "INFO"

        } catch {
            Write-EnhancedLog -Message "Error in test for handling non-existent source file: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw
        }
    }

    AfterAll {
        Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
    }
}



#MASTER Test SUITE


# # Define the module name at the top to make it easily accessible throughout the script
# $moduleName = Get-FunctionModule -FunctionName 'Backup-File'

# # Log the start of the tests
# BeforeAll {
#     Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"
# }

# # 1. Test case: Ensuring the backup directory is checked if it exists
# Describe "Test Backup-File - Checks if Backup Directory Exists" {

#     It "Should check if the backup directory exists" {
#         Mock -CommandName Test-Path -MockWith { param($Path) return $false } -ModuleName $moduleName

#         Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

#         # Verify that Test-Path was called to check the backup directory
#         Assert-MockCalled -CommandName Test-Path -Exactly 1 -Scope It
#     }
# }

# # 2. Test case: Creating the backup directory if it doesn't exist
# Describe "Test Backup-File - Creates Backup Directory" {

#     It "Should create the backup directory if it doesn't exist" {
#         Mock -CommandName New-Item -MockWith { return $null } -ModuleName $moduleName

#         Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

#         # Verify that New-Item was called to create the directory
#         Assert-MockCalled -CommandName New-Item -Exactly 1 -Scope It
#     }
# }

# # 3. Test case: Copying the file to the backup directory with a timestamp
# Describe "Test Backup-File - Copies File with Timestamp" {

#     It "Should copy the file to the backup directory with a timestamp" {
#         Mock -CommandName Copy-Item -MockWith { return $null } -ModuleName $moduleName

#         Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"

#         # Verify that Copy-Item was called to copy the file
#         Assert-MockCalled -CommandName Copy-Item -Exactly 1 -Scope It
#     }
# }

# # 4. Test case: Getting the current date for timestamping the file
# Describe "Test Backup-File - Gets Current Date for Timestamp" {

#     It "Should get the current date for the timestamp" {
#         Mock -CommandName Get-Date -MockWith { return "20240903120000" } -ModuleName $moduleName

#         $result = Backup-File -SourceFilePath "C:\Temp\TestFile.txt" -BackupDirectory "C:\Temp\Backups"
#         $expectedPath = "C:\Temp\Backups\20240903120000_TestFile.txt"

#         # Sanitize the result by ensuring it's a single string value
#         if ($result -is [array]) {
#             $result = $result | Where-Object { $_ -ne $null }
#         }

#         Write-EnhancedLog -Message "Backup-File result: $result, expected path: $expectedPath" -Level "INFO"
#         $result | Should -Be $expectedPath
#     }
# }

# # 5. Test case: Handling non-existent source file
# Describe "Test Backup-File - Handles Non-Existent Source File" {

#     It "Should throw an error when the source file does not exist" {
#         Mock -CommandName Test-Path -MockWith { return $false } -ModuleName $moduleName

#         { Backup-File -SourceFilePath "C:\Temp\NonExistentFile.txt" -BackupDirectory "C:\Temp\Backups" } | Should -Throw "Source file does not exist."
#     }
# }

# # Log the completion of the tests
# AfterAll {
#     Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
# }




# Get the module name for the 'Backup-File' function
# $moduleName = Get-FunctionModule -FunctionName 'Backup-File'

# # Global setup for all tests
# BeforeAll {
#     Write-EnhancedLog -Message "Starting Unit Tests for Backup-File Function" -Level "NOTICE"
#     $moduleName = Get-FunctionModule -FunctionName 'Backup-File'
# }

# # Describe block 1
# Describe "Test Backup-File - Checks if Backup Directory Exists" {

#     # Start logging for this Describe block
#     BeforeAll {
#         $testSourceFile = "C:\Temp\TestFile.txt"
#         $testBackupDirectory = "C:\Temp\Backups"
#         Write-EnhancedLog -Message "Starting test for checking if backup directory exists." -Level "INFO"
#         Write-EnhancedLog -Message "Test setup: Source file path is '$testSourceFile', Backup directory is '$testBackupDirectory'" -Level "INFO"
#     }

#     It "Should check if the backup directory exists" {
#         try {
#             # Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
#             Mock -CommandName Test-Path -MockWith {
#                 param($Path)
#                 Write-EnhancedLog -Message "Mocking Test-Path for path '$Path'" -Level "INFO"
#                 if ($Path -eq $testBackupDirectory) {
#                     return $false  # Mock that the backup directory does not exist
#                 }
#                 elseif ($Path -eq $testSourceFile) {
#                     return $true  # Mock that the source file exists
#                 }
#                 throw "Unexpected path passed to Test-Path: $Path"
#             } -ModuleName $moduleName
            

#             Backup-File -SourceFilePath $testSourceFile -BackupDirectory $testBackupDirectory

#             Assert-MockCalled -CommandName Test-Path -Exactly 1 -Scope It
#             Write-EnhancedLog -Message "Successfully completed test for checking if backup directory exists." -Level "INFO"

#         }
#         catch {
#             Write-EnhancedLog -Message "Error in Mocked Test-Path: $($_.Exception.Message)" -Level "ERROR"
#             Handle-Error -ErrorRecord $_
#             throw
#         }
#     }

#     AfterAll {
#         Write-EnhancedLog -Message "Finished test for checking if backup directory exists." -Level "INFO"
#     }
# }

# # Cleanup after all tests
# AfterAll {
#     Write-EnhancedLog -Message "Finished Unit Tests for Backup-File Function" -Level "NOTICE"
# }
