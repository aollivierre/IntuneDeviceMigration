iex ((irm "https://raw.githubusercontent.com/aollivierre/module-starter/main/Module-Starter.ps1") -replace '\$Mode = "dev"', '$Mode = "dev"' -replace 'SkipPSGalleryModules\s*=\s*false', 'SkipPSGalleryModules = false')

function Add-LocalUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TempUser,

        [Parameter(Mandatory = $true)]
        [string]$TempUserPassword,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [string]$Group
    )

    Begin {
        Write-EnhancedLog -Message "Starting Add-LocalUser function" -Level "NOTICE"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            # Check if the user already exists
            $userExists = Get-LocalUser -Name $TempUser -ErrorAction SilentlyContinue

            if (-not $userExists) {
                Write-EnhancedLog -Message "Creating Local User Account '$TempUser'" -Level "INFO"
                $Password = ConvertTo-SecureString -AsPlainText $TempUserPassword -Force
                New-LocalUser -Name $TempUser -Password $Password -Description $Description -AccountNeverExpires
                Write-EnhancedLog -Message "Local user account '$TempUser' created successfully." -Level "INFO"
            } else {
                Write-EnhancedLog -Message "Local user account '$TempUser' already exists." -Level "WARNING"
            }

            # Check if the user is already a member of the specified group
            $group = Get-LocalGroup -Name $Group
            $memberExists = $group | Get-LocalGroupMember | Where-Object { $_.Name -eq $TempUser }

            if (-not $memberExists) {
                # Add the user to the specified group
                $groupParams = @{
                    Group  = $Group
                    Member = $TempUser
                }
                try {
                    Add-LocalGroupMember @groupParams
                    Write-EnhancedLog -Message "User '$TempUser' added to the '$Group' group." -Level "INFO"
                } catch [Microsoft.PowerShell.Commands.AddLocalGroupMemberCommand+MemberExistsException] {
                    Write-EnhancedLog -Message "User '$TempUser' is already a member of the '$Group' group." -Level 'WARNING'
                }
            } else {
                Write-EnhancedLog -Message "User '$TempUser' is already a member of the '$Group' group." -Level 'WARNING'
            }

        } catch {
            Write-EnhancedLog -Message "An error occurred while adding local user or adding to group: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Add-LocalUser function" -Level "NOTICE"
    }
}

# # Define parameters
$AddLocalUserParams = @{
    TempUser         = "YourTempUser"
    TempUserPassword = "YourTempUserPassword"
    Description      = "account for autologin"
    Group            = "Administrators"
}

# Example usage with splatting
Add-LocalUser @AddLocalUserParams