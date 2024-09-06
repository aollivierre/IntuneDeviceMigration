function Add-User {
    param (
        [string]$UserName,
        [string]$Role
    )

    # Check if the user already exists
    if (Get-User -UserName $UserName) {
        return "User already exists"
    }

    # Create the user
    New-User -UserName $UserName -Role $Role

    return "User created"
}

# Mock functions for the sake of this example
function Get-User {
    param (
        [string]$UserName
    )
    # Pretend this gets a user from a system
}

function New-User {
    param (
        [string]$UserName,
        [string]$Role
    )
    # Pretend this creates a user in a system
}
