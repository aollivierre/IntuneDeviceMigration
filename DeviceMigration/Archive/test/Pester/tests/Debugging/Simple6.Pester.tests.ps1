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



Describe "Backup-File" {

    BeforeAll {
        Wait-Debugger # Breakpoint here for BeforeAll

        # Define some test paths
        $testSourceFile = "C:\Temp\TestFile.txt"
        $testBackupDirectory = "C:\Temp\Backups"
        $mockTimestamp = "20240101010101"

        # Log the paths being used
        Write-EnhancedLog -Message "Test setup: Source file path is '$testSourceFile', Backup directory is '$testBackupDirectory'" -Level "INFO"

        # Ensure the C:\Temp directory exists
        if (-Not (Test-Path -Path "C:\Temp")) {
            New-Item -Path "C:\Temp" -ItemType Directory | Out-Null
        }

        # Create the source file
        if (-Not (Test-Path -Path $testSourceFile)) {
            # Use $testSourceFile instead of $sourceFilePath
            New-Item -Path $testSourceFile -ItemType File | Out-Null
        }

        # Ensure the backup directory does not exist
        if (Test-Path -Path $testBackupDirectory) {
            # Use $testBackupDirectory instead of $backupDirectory
            Remove-Item -Path $testBackupDirectory -Recurse -Force | Out-Null
        }



        # Mock Get-Date to return a fixed timestamp
        Mock -CommandName Get-Date -MockWith {
            Wait-Debugger # Breakpoint here for Mocking Get-Date
            Write-EnhancedLog -Message "Mocked Get-Date called, returning fixed timestamp: $mockTimestamp" -Level "INFO"
            return [datetime]::ParseExact($mockTimestamp, "yyyyMMddHHmmss", $null)
        }
        # Mock Test-Path to simulate file existence checks with error handling
        Mock -CommandName Test-Path -MockWith {
            param ($Path)
            Wait-Debugger # Breakpoint here for Mocking Test-Path
            Write-EnhancedLog -Message "Mocked Test-Path called with path: $Path" -Level "INFO"

            try {
                if ($Path -eq $testSourceFile) {
                    Write-EnhancedLog -Message "Simulating existence of source file: $Path" -Level "INFO"
                    return $true  # Simulate that the source file exists
                }
                elseif ($Path -eq $testBackupDirectory) {
                    Write-EnhancedLog -Message "Returning false for backup directory path: $Path" -Level "INFO"
                    return $false  # Simulate that the backup directory does not exist
                }
                else {
                    Write-EnhancedLog -Message "Returning null for path: $Path" -Level "INFO"
                    return $null
                }
            }
            catch {
                Write-EnhancedLog -Message "Error in Mocked Test-Path: $($_.Exception.Message)" -Level "ERROR"
                Handle-Error -ErrorRecord $_
                throw
            }
        }
        
        # Mock New-Item to simulate directory creation
        Mock -CommandName New-Item -MockWith {
            param ($Path, $ItemType)
            Wait-Debugger # Breakpoint here for Mocking New-Item
            Write-EnhancedLog -Message "Mocked New-Item called to create directory: $Path" -Level "INFO"
            return $null
        }

        # Mock Copy-Item to simulate file copying
        Mock -CommandName Copy-Item -MockWith {
            param ($Path, $Destination)
            Wait-Debugger # Breakpoint here for Mocking Copy-Item
            Write-EnhancedLog -Message "Mocked Copy-Item called to copy file from $Path to $Destination" -Level "INFO"
            return $null
        }
    }

    Context "When the source file exists" {

        It "Should create the backup directory if it doesn't exist" {
            Wait-Debugger # Breakpoint here at the start of this test
            Write-EnhancedLog -Message "Starting test: Should create the backup directory if it doesn't exist" -Level "NOTICE"
            try {
                if (-not (Test-Path -Path $testSourceFile)) {
                    Write-EnhancedLog -Message "Test validation failed: Source file '$testSourceFile' does not exist before calling Backup-File" -Level "ERROR"
                    throw "Source file '$testSourceFile' was expected to exist, but Test-Path returned false."
                }

                Wait-Debugger # Breakpoint here before calling Backup-File
                Backup-File -SourceFilePath $testSourceFile -BackupDirectory $testBackupDirectory

                Assert-MockCalled -CommandName New-Item -Exactly -Times 1 -Scope It -ParameterFilter {
                    $Path -eq $testBackupDirectory -and $ItemType -eq "Directory"
                }
            }
            catch {
                Wait-Debugger # Breakpoint here in the catch block
                Write-EnhancedLog -Message "Test failed during backup directory creation: $($_.Exception.Message)" -Level "ERROR"
                Handle-Error -ErrorRecord $_
                throw $_
            }
            Write-EnhancedLog -Message "Finished test: Should create the backup directory if it doesn't exist" -Level "NOTICE"
        }

        It "Should copy the file to the backup directory with a timestamp" {
            Wait-Debugger # Breakpoint here at the start of this test
            Write-EnhancedLog -Message "Starting test: Should copy the file to the backup directory with a timestamp" -Level "NOTICE"
            try {
                if (-not (Test-Path -Path $testSourceFile)) {
                    Write-EnhancedLog -Message "Test validation failed: Source file '$testSourceFile' does not exist before calling Backup-File" -Level "ERROR"
                    throw "Source file '$testSourceFile' was expected to exist, but Test-Path returned false."
                }

                Wait-Debugger # Breakpoint here before calling Backup-File
                $result = Backup-File -SourceFilePath $testSourceFile -BackupDirectory $testBackupDirectory
                $expectedBackupFilePath = Join-Path -Path $testBackupDirectory -ChildPath "$mockTimestamp_TestFile.txt"
                
                Write-EnhancedLog -Message "Expected backup file path: $expectedBackupFilePath, Actual result: $result" -Level "INFO"

                if (-not $result) {
                    Write-EnhancedLog -Message "Backup-File function did not return a valid result. Expected: $expectedBackupFilePath" -Level "ERROR"
                    throw "Backup-File function returned null instead of expected path."
                }

                $result | Should -Be $expectedBackupFilePath

                Assert-MockCalled -CommandName Copy-Item -Exactly -Times 1 -Scope It -ParameterFilter {
                    $Path -eq $testSourceFile -and $Destination -eq $expectedBackupFilePath
                }
            }
            catch {
                Wait-Debugger # Breakpoint here in the catch block
                Write-EnhancedLog -Message "Test failed during file copy: $($_.Exception.Message)" -Level "ERROR"
                Handle-Error -ErrorRecord $_
                throw $_
            }
            Write-EnhancedLog -Message "Finished test: Should copy the file to the backup directory with a timestamp" -Level "NOTICE"
        }
    }

    Context "When the source file does not exist" {

        It "Should throw an error" {
            Wait-Debugger # Breakpoint here at the start of this test
            Write-EnhancedLog -Message "Starting test: Should throw an error when the source file does not exist" -Level "NOTICE"
            try {
                # Mock Test-Path to return false for the source file
                Mock -CommandName Test-Path -MockWith {
                    Wait-Debugger # Breakpoint here for Mocking Test-Path inside this test
                    Write-EnhancedLog -Message "Mocked Test-Path called, returning false for source file." -Level "INFO"
                    return $false
                }

                { Backup-File -SourceFilePath "C:\NonExistentFile.txt" -BackupDirectory $testBackupDirectory } | Should -Throw "Source file does not exist."
            }
            catch {
                Wait-Debugger # Breakpoint here in the catch block
                Write-EnhancedLog -Message "Expected error was not thrown: $($_.Exception.Message)" -Level "ERROR"
                Handle-Error -ErrorRecord $_
                throw $_
            }
            Write-EnhancedLog -Message "Finished test: Should throw an error when the source file does not exist" -Level "NOTICE"
        }
    }
}