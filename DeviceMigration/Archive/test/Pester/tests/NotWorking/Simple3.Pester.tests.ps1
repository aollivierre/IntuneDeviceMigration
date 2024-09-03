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

# # Import Pester
# Import-Module Pester

# # Import the module or script containing Add-User
# Import-Module C:\path\to\your\module\ModuleName.psd1

# Define the test block
Describe "Add-User" {

    BeforeAll {
        # Mock the Get-User function to simulate different scenarios
        Mock -CommandName Get-User -MockWith {
            param ($UserName)
            if ($UserName -eq "existingUser") {
                return @{ UserName = $UserName; Role = "User" }
            } else {
                return $null
            }
        }

        # Mock the New-User function to track if it's called
        Mock -CommandName New-User -MockWith {
            param ($UserName, $Role)
            # Simulate creating a user
        }
    }

    Context "When the user already exists" {
        It "Should return 'User already exists'" {
            $result = Add-User -UserName "existingUser" -Role "Admin"
            $result | Should -Be "User already exists"

            # Verify that New-User was not called
            Assert-MockCalled -CommandName New-User -Times 0
        }
    }

    Context "When the user does not exist" {
        It "Should create a new user and return 'User created'" {
            $result = Add-User -UserName "newUser" -Role "Admin"
            $result | Should -Be "User created"

            # Verify that New-User was called once with the correct parameters
            Assert-MockCalled -CommandName New-User -Times 1 -Exactly -Scope It -ParameterFilter {
                $UserName -eq "newUser" -and $Role -eq "Admin"
            }
        }
    }

    Context "Data-driven tests for different roles" {
        $roles = @("Admin", "User", "Guest")
        foreach ($role in $roles) {
            It "Should create a new user with role $role" -TestCases $role {
                param ($role)

                $result = Add-User -UserName "newUserWithRole" -Role $role
                $result | Should -Be "User created"

                # Verify that New-User was called with the correct role
                Assert-MockCalled -CommandName New-User -Times 1 -Exactly -Scope It -ParameterFilter {
                    $UserName -eq "newUserWithRole" -and $Role -eq $role
                }

                # Reset the mock call count between iterations
                Reset-Mock -CommandName New-User
            }
        }
    }

    AfterAll {
        # Cleanup mock states if needed
        Remove-Mock -CommandName Get-User
        Remove-Mock -CommandName New-User
    }
}
