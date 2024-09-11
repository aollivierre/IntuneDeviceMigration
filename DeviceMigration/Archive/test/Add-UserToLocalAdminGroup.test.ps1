#region FIRING UP MODULE STARTER
#################################################################################################
#                                                                                               #
#                                 FIRING UP MODULE STARTER                                      #
#                                                                                               #
#################################################################################################

# Define a hashtable for splatting
$moduleStarterParams = @{
    Mode                   = "dev"
    SkipPSGalleryModules   = $true
    SkipCheckandElevate    = $true
    SkipPowerShell7Install = $true
    SkipEnhancedModules    = $true
    SkipGitRepos           = $true
}

# Call the function using the splat
Invoke-ModuleStarter @moduleStarterParams




function Add-UserToLocalAdminGroup {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify the username to add to the local admin group.")]
        [string]$Username
    )

    Process {
        # Verify if the user is already in the group using Get-EnhancedLocalGroupMembers
        $isMember = Get-EnhancedLocalGroupMembers -GroupName "Administrators" | Where-Object { $_.Account -eq $Username }

        if ($isMember) {
            Write-Host "User '$Username' is already a member of the Administrators group. No action required." -ForegroundColor Cyan
            return
        }

        # Use Add-LocalGroupMember to add the user to the local administrators group
        if ($PSCmdlet.ShouldProcess("Administrators group", "Adding user '$Username'")) {
            try {
                Add-LocalGroupMember -Group "Administrators" -Member $Username
                Write-Host "Successfully added '$Username' to the local Administrators group." -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to add user '$Username' to the local Administrators group: $($_.Exception.Message)" -ForegroundColor Red
                throw
            }
        }
    }
}


function Create-LocalUserIfNotExists {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify the username to create.")]
        [string]$Username,

        [Parameter(Mandatory = $true, HelpMessage = "Specify the full name for the new user.")]
        [string]$FullName,

        [Parameter(Mandatory = $true, HelpMessage = "Specify the password for the new user.")]
        [string]$Password
    )

    Process {
        Write-Host "Checking if user '$Username' exists..." -ForegroundColor Yellow

        # Check if running in PowerShell 7 or later
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            Write-Host "Running in PowerShell 7. Importing LocalAccounts module using Windows PowerShell..." -ForegroundColor Yellow
            try {
                # Import the LocalAccounts module from Windows PowerShell
                Import-Module -Name Microsoft.PowerShell.LocalAccounts -UseWindowsPowerShell -ErrorAction Stop
            }
            catch {
                Write-Host "Failed to import LocalAccounts module: $($_.Exception.Message)" -ForegroundColor Red
                throw
            }
        }

        try {
            # Check if user exists using Get-LocalUser
            $user = Get-LocalUser -Name $Username -ErrorAction Stop
            Write-Host "User '$Username' already exists. No action required." -ForegroundColor Cyan
            return $true
        }
        catch {
            Write-Host "User '$Username' does not exist. Proceeding with creation..." -ForegroundColor Yellow

            if ($PSCmdlet.ShouldProcess("System", "Create local user '$Username'")) {
                try {
                    # Create the user if they do not exist
                    New-LocalUser -Name $Username -FullName $FullName -Password (ConvertTo-SecureString $Password -AsPlainText -Force)
                    Write-Host "Successfully created user '$Username'." -ForegroundColor Green
                    return $true
                }
                catch {
                    Write-Host "Failed to create user '$Username': $($_.Exception.Message)" -ForegroundColor Red
                    throw
                }
            }
        }

        return $false
    }
}


function Ensure-UserInLocalAdminGroup {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify the username to manage.")]
        [string]$Username,

        [Parameter(Mandatory = $true, HelpMessage = "Specify the full name for the new user.")]
        [string]$FullName,

        [Parameter(Mandatory = $true, HelpMessage = "Specify the password for the new user.")]
        [string]$Password
    )

    Process {
        # Step 1: Check if user exists, if not, create the user
        $userParams = @{
            Username = $Username
            FullName = $FullName
            Password = $Password
        }
        $userCreated = Create-LocalUserIfNotExists @userParams

        if ($userCreated) {
            # Step 2: Verifying user membership before adding to the local admin group using Get-EnhancedLocalGroupMembers
            $beforeMember = Get-EnhancedLocalGroupMembers -GroupName "Administrators" | Where-Object { $_.Account -eq $Username }

            if (-not $beforeMember) {
                Write-Host "User '$Username' is not a member of the local Administrators group." -ForegroundColor Yellow

                # Step 3: Add the user to the local admin group
                Add-UserToLocalAdminGroup -Username $Username
            }

            # Step 4: Verifying user membership after adding to the local admin group using Get-EnhancedLocalGroupMembers
            $afterMember = Get-EnhancedLocalGroupMembers -GroupName "Administrators" | Where-Object { $_.Account -eq $Username }

            if ($afterMember) {
                Write-Host "User '$Username' has been successfully added to the local Administrators group." -ForegroundColor Green
            }
            else {
                Write-Host "User '$Username' was NOT added to the local Administrators group." -ForegroundColor Red
            }
        }
        else {
            Write-Host "User '$Username' could not be created. Exiting process." -ForegroundColor Red
        }
    }
}

$params = @{
    Username = "Tempuser005"
    FullName = "Temporary User 002"
    Password = "SecurePassword123!"
}

Ensure-UserInLocalAdminGroup @params