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


Describe "Mocking in Pester v5" {

    It "Should mock Get-Date within this block" {
        Mock -CommandName Get-Date -MockWith { return [datetime]::Parse("2024-12-31T00:00:00") }

        $result = Get-Date
        $expected = [datetime]::Parse("2024-12-31T00:00:00")

        $result | Should -BeExactly $expected
    }

    It "Should call the real Get-Date function" {
        $actualResult = Get-Date
        Start-Sleep -Milliseconds 100
        $expectedResult = Get-Date

        # Compare using only the date part to avoid precision issues
        $actualResult.Date | Should -Be $expectedResult.Date
    }
}



