function Add-LocalUser {
    [CmdletBinding()]
    param (
        [string]$TempUser,
        [string]$TempUserPassword
    )

    Begin {
        Write-EnhancedLog -Message "Starting Add-LocalUser function" -Level "INFO"
        Log-Params -Params @{ TempUser = $TempUser; TempUserPassword = $TempUserPassword }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Creating Local User Account" -Level "INFO"
            $Password = ConvertTo-SecureString -AsPlainText $TempUserPassword -Force
            New-LocalUser -Name $TempUser -Password $Password -Description "account for autologin" -AccountNeverExpires
            Add-LocalGroupMember -Group "Administrators" -Member $TempUser
        } catch {
            Write-EnhancedLog -Message "An error occurred while adding local user: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Add-LocalUser function" -Level "INFO"
    }
}

# Example usage
# Add-LocalUser -TempUser "YourTempUser" -TempUserPassword "YourTempUserPassword"
