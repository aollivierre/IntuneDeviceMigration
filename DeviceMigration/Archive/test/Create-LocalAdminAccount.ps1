iex ((irm "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1") -replace '\$Mode = "dev"', '$Mode = "dev"')

function Create-LocalAdminAccount {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Username,

        [Parameter(Mandatory = $true)]
        [string]$Password
    )

    begin {
        Write-EnhancedLog -Message 'Starting Create-LocalAdminAccount function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            # Check if the user already exists
            $userExists = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue

            if (-not $userExists) {
                # Create the user account
                $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
                $userParams = @{
                    Name                 = $Username
                    Password             = $securePassword
                    FullName             = "FC Remove Account"
                    Description          = "Account used for FC removal process"
                    PasswordNeverExpires = $true
                    AccountNeverExpires  = $true
                }
                New-LocalUser @userParams
                Write-EnhancedLog -Message "Local administrator account '$Username' created." -Level 'INFO'
            } else {
                Write-EnhancedLog -Message "Local administrator account '$Username' already exists." -Level 'WARNING'
            }

            # Check if the user is already a member of the local Administrators group
            $group = Get-LocalGroup -Name "Administrators"
            $memberExists = $null
            try {
                $memberExists = $group | Get-LocalGroupMember | Where-Object { $_.Name -eq $Username }
            } catch {
                Write-EnhancedLog -Message "Failed to retrieve group members: $_" -Level 'ERROR'
            }

            if (-not $memberExists) {
                # Add the user to the local Administrators group
                $groupParams = @{
                    Group  = "Administrators"
                    Member = $Username
                }
                try {
                    Add-LocalGroupMember @groupParams
                    Write-EnhancedLog -Message "User '$Username' added to the Administrators group." -Level 'INFO'
                } catch [Microsoft.PowerShell.Commands.AddLocalGroupMemberCommand+MemberExistsException] {
                    Write-EnhancedLog -Message "User '$Username' is already a member of the Administrators group." -Level 'WARNING'
                }
            } else {
                Write-EnhancedLog -Message "User '$Username' is already a member of the Administrators group." -Level 'WARNING'
            }

        } catch {
            Write-EnhancedLog -Message "An error occurred while creating the local admin account or adding to Administrators group: $_" -Level 'ERROR'
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'Create-LocalAdminAccount function completed' -Level 'INFO'
    }
}

# Define parameters for creating the local admin account
$localAdminParams = @{
    Username = "fcremove"
    Password = "fcremove"
}

# Create the local admin account
Create-LocalAdminAccount @localAdminParams
