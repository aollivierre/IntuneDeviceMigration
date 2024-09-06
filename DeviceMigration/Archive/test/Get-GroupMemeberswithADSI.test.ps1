# # Access the local "Administrators" group using ADSI
# $group = [ADSI]"WinNT://./Administrators,group"

# # Retrieve the members of the group
# $members = $group.psbase.Invoke("Members")

# # Iterate through each member of the group
# foreach ($member in $members) {
#     try {
#         # Try to resolve the member (if this works, the member is valid)
#         $memberPath = $member.GetType().InvokeMember('AdsPath', 'GetProperty', $null, $member, $null)

#         # Check if the member is an orphaned SID by checking the format of the AdsPath
#         if ($memberPath -like "*S-1-*") {
#             Write-Host "Orphaned SID detected: $memberPath" -ForegroundColor Yellow

#             # Extract just the SID from the path and remove it
#             $orphanedSID = $memberPath -replace "^.*?S-1-", "S-1-"
#             try {
#                 $group.Remove("WinNT://$orphanedSID")
#                 Write-Host "Successfully removed orphaned SID: $orphanedSID" -ForegroundColor Green
#             } catch {
#                 Write-Host "Failed to remove orphaned SID: $($_.Exception.Message)" -ForegroundColor Red
#             }
#         } else {
#             Write-Host "Valid member: $memberPath"
#         }
#     } catch {
#         # If we cannot resolve the member, it is an orphaned SID
#         Write-Host "Failed to resolve member, skipping." -ForegroundColor Red
#     }
# }



function Remove-OrphanedSIDsFromAdministratorsGroup {
    <#
    .SYNOPSIS
    Removes orphaned SIDs from the local "Administrators" group.

    .DESCRIPTION
    This function iterates through the members of the local "Administrators" group and removes any orphaned SIDs, which are typically leftover accounts no longer associated with a user.

    .EXAMPLE
    Remove-OrphanedSIDsFromAdministratorsGroup

    This will check the local "Administrators" group for any orphaned SIDs and remove them.

    .NOTES
    Author: Abdullah Ollivierre
    Date: 2024-09-06

    #>

    # Access the local "Administrators" group using ADSI
    $group = [ADSI]"WinNT://./Administrators,group"

    # Retrieve the members of the group
    $members = $group.psbase.Invoke("Members")

    # Iterate through each member of the group
    foreach ($member in $members) {
        try {
            # Try to resolve the member (if this works, the member is valid)
            $memberPath = $member.GetType().InvokeMember('AdsPath', 'GetProperty', $null, $member, $null)

            # Check if the member is an orphaned SID by checking the format of the AdsPath
            if ($memberPath -like "*S-1-*") {
                Write-Host "Orphaned SID detected: $memberPath" -ForegroundColor Yellow

                # Extract just the SID from the path and remove it
                $orphanedSID = $memberPath -replace "^.*?S-1-", "S-1-"
                try {
                    $group.Remove("WinNT://$orphanedSID")
                    Write-Host "Successfully removed orphaned SID: $orphanedSID" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to remove orphaned SID: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            else {
                Write-Host "Valid member: $memberPath"
            }
        }
        catch {
            # If we cannot resolve the member, it is an orphaned SID
            Write-Host "Failed to resolve member, skipping." -ForegroundColor Red
        }
    }
}


Remove-OrphanedSIDsFromAdministratorsGroup