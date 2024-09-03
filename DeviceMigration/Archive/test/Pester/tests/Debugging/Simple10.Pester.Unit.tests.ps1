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



Describe "Check-FileExists - Unit Test" {

    It "Should return 'File exists' when the file exists" {
        # Mock Test-Path to simulate that the file exists within the module scope
        Mock -CommandName Test-Path -MockWith { return $true } -ModuleName EnhancedLoggingAO

        $result = Check-FileExists -FilePath "C:\Temp\TestFile.txt"

        $result | Should -Be "File exists"
    }

    It "Should return 'File does not exist' when the file does not exist" {
        # Mock Test-Path to simulate that the file does not exist within the module scope
        Mock -CommandName Test-Path -MockWith { return $false } -ModuleName EnhancedLoggingAO

        $result = Check-FileExists -FilePath "C:\Temp\NonExistentFile.txt"

        $result | Should -Be "File does not exist"
    }
}

