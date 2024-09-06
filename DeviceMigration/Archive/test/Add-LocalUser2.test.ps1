# Parameters
$TempUser = "YourTempUser"
$TempUserPassword = "YourTempUserPassword"
$Description = "account for autologin"
$Group = "Administrators"

# Start of script
Write-Host "Starting user creation process..." -ForegroundColor Cyan

try {
    # Check if the user already exists
    Write-Host "Checking if the user '$TempUser' already exists..." -ForegroundColor White
    $userExists = Get-LocalUser -Name $TempUser -ErrorAction SilentlyContinue

    if (-not $userExists) {
        Write-Host "Creating Local User Account '$TempUser'" -ForegroundColor Green
        $Password = ConvertTo-SecureString -AsPlainText $TempUserPassword -Force
        New-LocalUser -Name $TempUser -Password $Password -Description $Description -AccountNeverExpires
        Write-Host "Local user account '$TempUser' created successfully." -ForegroundColor Green
    } else {
        Write-Host "Local user account '$TempUser' already exists." -ForegroundColor Yellow
    }

    # Fetch and check if the user is already a member of the specified group
    Write-Host "Fetching current members of the '$Group' group..." -ForegroundColor White
    $groupMembers = Get-LocalGroupMember -Group $Group | Select-Object -ExpandProperty Name
    Write-Host "Group members: $($groupMembers -join ', ')" -ForegroundColor White

    if ($groupMembers -contains $TempUser) {
        Write-Host "User '$TempUser' is already a member of the '$Group' group." -ForegroundColor Yellow
    } else {
        Write-Host "Adding user '$TempUser' to the '$Group' group..." -ForegroundColor Green
        Add-LocalGroupMember -Group $Group -Member $TempUser
        Write-Host "User '$TempUser' added to the '$Group' group." -ForegroundColor Green
    }

} catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
}

# End of script
Write-Host "User creation process completed." -ForegroundColor Cyan
