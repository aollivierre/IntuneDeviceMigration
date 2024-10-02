# Function to filter and log interactive user sessions
function Get-InteractiveUsers {
    try {
        # Log the start of the function
        Write-EnhancedLog -Message "Starting Get-InteractiveUsers function" -Level "NOTICE"

        # Run the 'query user' command to get logged-in user sessions
        $sessions = query user | Select-Object -Skip 1 | ForEach-Object {
            # Parse each line to extract session information, skip invalid lines
            # Split on 2 or more spaces to handle spacing variations
            $fields = $_ -split '\s{2,}'

            # Some lines may not have all fields, skip them
            if ($fields.Count -ge 4) {
                [PSCustomObject]@{
                    UserName    = $fields[0]
                    SessionName = $fields[1]
                    ID          = $fields[2]
                    State       = $fields[3]
                }
            }
        }

        # Filter out system accounts and background service accounts
        $interactiveUsers = $sessions | Where-Object {
            $_.UserName -notmatch "^(DWM-|UMFD-|SYSTEM|LOCAL SERVICE|NETWORK SERVICE)"
        }

        # Log the users found
        Write-EnhancedLog -Message "Found $($interactiveUsers.Count) interactive users" -Level "INFO"

        return $interactiveUsers

    } catch {
        Handle-Error -ErrorRecord $_
    } finally {
        Write-EnhancedLog -Message "Exiting Get-InteractiveUsers function" -Level "NOTICE"
    }
}

# Function to handle the interactive user session logic
function Manage-UserSessions {
    try {
        Write-EnhancedLog -Message "Starting Manage-UserSessions function" -Level "NOTICE"
        
        $interactiveUsers = Get-InteractiveUsers

        if ($interactiveUsers.Count -gt 1) {
            # Log multiple users and throw an error
            Write-EnhancedLog -Message "Multiple interactive users logged in" -Level "WARNING"
            $interactiveUsers | ForEach-Object {
                Write-EnhancedLog -Message "User: $($_.UserName)" -Level "WARNING"
            }
            throw "Error: More than one interactive user is logged in. Please log off all other user sessions except the currently logged-in one."
        }
        elseif ($interactiveUsers.Count -eq 1) {
            # Log the single user and success message
            Write-EnhancedLog -Message "Interactive user logged in: $($interactiveUsers[0].UserName)" -Level "INFO"
            Write-EnhancedLog -Message "Success: Only one interactive user is logged in." -Level "NOTICE"
        }
        else {
            # Log no users
            Write-EnhancedLog -Message "No interactive users are currently logged in." -Level "ERROR"
        }

    } catch {
        Handle-Error -ErrorRecord $_
    } finally {
        Write-EnhancedLog -Message "Exiting Manage-UserSessions function" -Level "NOTICE"
    }
}

# Main execution
try {
    Write-EnhancedLog -Message "Script execution started" -Level "NOTICE"
    Manage-UserSessions
} catch {
    Handle-Error -ErrorRecord $_
} finally {
    Write-EnhancedLog -Message "Script execution finished" -Level "NOTICE"
}
