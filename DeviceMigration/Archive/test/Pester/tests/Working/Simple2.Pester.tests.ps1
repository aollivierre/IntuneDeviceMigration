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


# # Import Pester
# Import-Module Pester

# # Import the module or source the script containing New-TextFile
# Import-Module C:\path\to\your\module\ModuleName.psd1

# Define the test block
Describe "New-TextFile" {

    # Test for successful file creation
    It "Should create a new text file with the specified content" {
        $filePath = "C:\Temp\TestFile.txt"
        $content = "Hello, Pester!"

        New-TextFile -FilePath $filePath -Content $content | Should -Be $filePath
        Test-Path $filePath | Should -Be $true
        Get-Content $filePath | Should -Be $content

        # Clean up
        Remove-Item $filePath
    }

    # Test for handling non-existent directory
    It "Should throw an error if the directory does not exist" {
        $filePath = "C:\NonExistentDirectory\TestFile.txt"
        $content = "This should fail"

        { New-TextFile -FilePath $filePath -Content $content } | Should -Throw "The directory does not exist."
    }

    # Test for overwriting an existing file
    It "Should overwrite an existing file" {
        $filePath = "C:\Temp\TestFile.txt"
        $content1 = "First content"
        $content2 = "Second content"

        New-TextFile -FilePath $filePath -Content $content1
        New-TextFile -FilePath $filePath -Content $content2

        Get-Content $filePath | Should -Be $content2

        # Clean up
        Remove-Item $filePath
    }
}
