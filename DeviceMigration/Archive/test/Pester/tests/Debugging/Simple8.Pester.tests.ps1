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
            New-Item -Path $testSourceFile -ItemType File | Out-Null
        }

        # Ensure the backup directory does not exist
        if (Test-Path -Path $testBackupDirectory) {
            Remove-Item -Path $testBackupDirectory -Recurse -Force | Out-Null
        }

        # Mock Get-Date to return a fixed timestamp
        Mock -CommandName Get-Date -MockWith {
            Write-EnhancedLog -Message "Mocked Get-Date called, returning fixed timestamp: $mockTimestamp" -Level "INFO"
            return [datetime]::ParseExact($mockTimestamp, "yyyyMMddHHmmss", $null)
        }
    }

    Context "When the source file exists" {

        It "Should create the backup directory if it doesn't exist" {
            Write-EnhancedLog -Message "Starting test: Should create the backup directory if it doesn't exist" -Level "NOTICE"
            try {
                if (-not (Test-Path -Path $testSourceFile)) {
                    Write-EnhancedLog -Message "Test validation failed: Source file '$testSourceFile' does not exist before calling Backup-File" -Level "ERROR"
                    throw "Source file '$testSourceFile' was expected to exist, but Test-Path returned false."
                }

                Backup-File -SourceFilePath $testSourceFile -BackupDirectory $testBackupDirectory

                if (-not (Test-Path -Path $testBackupDirectory)) {
                    Write-EnhancedLog -Message "Backup directory was not created as expected." -Level "ERROR"
                    throw "Backup directory was not created."
                }
            }
            catch {
                Write-EnhancedLog -Message "Test failed during backup directory creation: $($_.Exception.Message)" -Level "ERROR"
                Handle-Error -ErrorRecord $_
                throw $_
            }
            Write-EnhancedLog -Message "Finished test: Should create the backup directory if it doesn't exist" -Level "NOTICE"
        }

        It "Should copy the file to the backup directory with a timestamp" {
            Write-EnhancedLog -Message "Starting test: Should copy the file to the backup directory with a timestamp" -Level "NOTICE"
            try {
                if (-not (Test-Path -Path $testSourceFile)) {
                    Write-EnhancedLog -Message "Test validation failed: Source file '$testSourceFile' does not exist before calling Backup-File" -Level "ERROR"
                    throw "Source file '$testSourceFile' was expected to exist, but Test-Path returned false."
                }
        
                Wait-Debugger # Breakpoint here before calling Backup-File
                $result = Backup-File -SourceFilePath $testSourceFile -BackupDirectory $testBackupDirectory
        
                # Update the expected path pattern to include timestamp and filename
                $expectedBackupFilePattern = [regex]::Escape($testBackupDirectory) + "\\\d{14}_TestFile\.txt"
                
                Write-EnhancedLog -Message "Expected backup file path pattern: $expectedBackupFilePattern, Actual result: $result" -Level "INFO"
        
                if (-not ($result -match $expectedBackupFilePattern)) {
                    Write-EnhancedLog -Message "Backup file was not copied as expected." -Level "ERROR"
                    throw "Backup file name format incorrect."
                }
        
                $result | Should -Match $expectedBackupFilePattern
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
            Write-EnhancedLog -Message "Starting test: Should throw an error when the source file does not exist" -Level "NOTICE"
            try {
                { Backup-File -SourceFilePath "C:\NonExistentFile.txt" -BackupDirectory $testBackupDirectory } | Should -Throw "Source file does not exist."
            }
            catch {
                Write-EnhancedLog -Message "Expected error was not thrown: $($_.Exception.Message)" -Level "ERROR"
                Handle-Error -ErrorRecord $_
                throw $_
            }
            Write-EnhancedLog -Message "Finished test: Should throw an error when the source file does not exist" -Level "NOTICE"
        }
    }
}