#ToDo I have not tested this script and found it on reddit here https://www.reddit.com/r/PowerShell/comments/1f7x9is/monitor_entra_id_break_glass_account_exclusions/ and yes this for Break the glass accounts but we can also use it for the PPKG_GUID account




# Docs https://github.com/thetolkienblackguy/EntraIdManagement/blob/main/Confirm-BreakGlassConditionalAccessExclusions/Confirm-BreakGlassConditionalAccessExclusions.ps1

# Dependcies https://github.com/thetolkienblackguy/Microsoft.Graph.Extensions/tree/main
# This scrip relies on the Microsoft.Graph.Extensions module for sending email and this module is not currently on the PS Gallery but it can be obtained from GitHub. So you can skip the email functionality or just bring the email functionality from that module over here

<##########################################################################################################################
    .DESCRIPTION
    This script is used to confirm that the break glass account(s) have the conditional access policy exclusions applied.

    .PARAMETER Break_Glass_Account
    The break glass account(s) to confirm the conditional access policy exclusions for.

    .PARAMETER Outfile
    The path to the output file.

    .PARAMETER Select
    The properties to select from the output.   

    .PARAMETER To
    The email address(es) to send the report to.

    .PARAMETER From
    The email address to send the report from.

    .PARAMETER Cc
    The email address(es) to Cc.

    .PARAMETER Subject
    The subject of the email.

    .PARAMETER Body
    The body of the email.

    .PARAMETER Scope
    Micorosoft Graph scopes to use for the script.

    .PARAMETER ManagedIdentity
    Switch to use managed identity to connect to Microsoft Graph.

    .PARAMETER Client_Id
    The client id of the app registration.

    .PARAMETER Tenant_Id
    The tenant id of the app registration.

    .PARAMETER Certificate_Thumbpint
    The certificate thumbpint of the app registration.

    .PARAMETER Client_Secret
    The client secret of the app registration.  

    .EXAMPLE
    .\Confirm-BreakGlassConditionalAccessExclusions.ps1 -Break_Glass_Account "user1@contoso.com","user2@contoso.com" -To "user1@contoso.com","user2@contoso.com" -ManagedIdentity

    .EXAMPLE
    .\Confirm-BreakGlassConditionalAccessExclusions.ps1 -Break_Glass_Account "user1@contoso.com","user2@contoso.com" -To "user1@contoso.com","user2@contoso.com" -Client_Id "12345678-1234-1234-1234-123456789012" -Tenant_Id "12345678-1234-1234-1234-123456789012" -Client_Secret "1234567890123456789012345678901234567890"

    .EXAMPLE
    .\Confirm-BreakGlassConditionalAccessExclusions.ps1 -Break_Glass_Account "user1@contoso.com","user2@contoso.com" -To "user1@contoso.com","user2@contoso.com" -Client_Id "12345678-1234-1234-1234-123456789012" -Tenant_Id "12345678-1234-1234-1234-123456789012" -Certificate_Thumbpint "1234567890123456789012345678901234567890"

    .NOTES
    Author: Gabriel Delaney
    Date: 09/01/2024
    Version: 1.0
    Name: Confirm-BreakGlassConditionalAccessExclusions
    Version History:
    1.0 - Initial release - Gabriel Delaney - 08/31/2024

    .LINK
    https://github.com/thetolkienblackguy/EntraIdManagement/Readme.md
##########################################################################################################################>
[CmdletBinding(DefaultParameterSetName="Delegated")]
param (
    [Parameter(Mandatory=$true,Position=0)]
    [string[]]$Break_Glass_Account,
    [Parameter(Mandatory=$false)]
    [string]$Outfile = "Break_Glass_Conditional_Access_Report_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').csv",
    [Parameter(Mandatory=$false)]
    [string[]]$Select = @("Id","DisplayName","Description","State","BreakGlassAccount","ExcludedFromPolicy"),
    [Parameter(Mandatory=$false)]
    [string[]]$To,
    [Parameter(Mandatory=$false)]
    [string]$From,
    [Parameter(Mandatory=$false)]
    [string]$Cc,
    [Parameter(Mandatory=$false)]
    [string]$Subject = "Entra ID Break Glass Account Conditional Access Policy Review",
    [Parameter(Mandatory=$false)]
    [string]$Body = "Please review the attached report and take appropriate action.",
    [Parameter(DontShow=$true)]
    [string[]]$Scope = @(
        "Policy.Read.All","User.Read.All","Mail.Send"
        
    ),
    [Parameter(Mandatory=$true, ParameterSetName="ManagedIdentity")]
    [switch]$ManagedIdentity,
    [Parameter(Mandatory=$true, ParameterSetName="ClientSecret")]
    [Parameter(Mandatory=$true, ParameterSetName="Certificate")]
    [string]$Client_Id,
    [Parameter(Mandatory=$true, ParameterSetName="ClientSecret")]
    [Parameter(Mandatory=$true, ParameterSetName="Certificate")]
    [string]$Tenant_Id,
    [Parameter(Mandatory=$true, ParameterSetName="Certificate")]
    [string]$Certificate_Thumbpint,
    [Parameter(Mandatory=$true, ParameterSetName="ClientSecret")]
    [string]$Client_Secret

)
#region Prep

#Setting error handling to stop on error
$ErrorActionPreference = "Stop"

#Setting default parameter values
$PSDefaultParameterValues = @{}
$PSDefaultParameterValues["Write-Host:BackgroundColor"] = "Black"
$PSDefaultParameterValues["Write-Host:ForegroundColor"] = "Yellow"
$PSDefaultParameterValues["Export-Csv:NoTypeInformation"] = $true
$PSDefaultParameterValues["Add-Member:MemberType"] = "NoteProperty"
$PSDefaultParameterValues["Add-Member:Force"] = $true
$PSDefaultParameterValues["ConvertTo-SecureString:AsPlainText"] = $true
$PSDefaultParameterValues["ConvertTo-SecureString:Force"] = $true

#Creating a list to store the output
$output_obj = [System.Collections.Generic.List[PSObject]]::new()

#endregion

#region splatting
# Get-GraphApplication parameters
$get_application_params = @{}
$get_application_params["All"] = $true
$get_application_params["Select"] = "id"

# Send-GraphMailMessage parameters
$send_mail_params = @{}
$send_mail_params["To"] = $to
$send_mail_params["From"] = $from
$send_mail_params["Subject"] = $subject
$send_mail_params["Body"] = $body
If ($cc) {
    $send_mail_params["Cc"] = $Cc

}
$send_mail_params["Attachments"] = $outfile

# Connect-MgGraph parameters
$connect_mg_params = @{}
$connect_mg_params["NoWelcome"] = $true

#If the parameter set is not managed identity, then we need to set the tenant id
If ($PSCmdlet.ParameterSetName -notin ("ManagedIdentity","Delegated")) {
    $connect_mg_params["TenantId"] = $tenant_id
    #If the parameter set is client secret, then we need to create a client secret credential object
    If ($PSCmdlet.ParameterSetName -eq "ClientSecret") {
        $connect_mg_params["ClientSecretCredential"] = New-Object System.Management.Automation.PSCredential($client_id, $($client_secret | ConvertTo-SecureString))

    # If the parameter set is certificate, then we need to set the certificate thumbpintd    
    } ElseIf ($PSCmdlet.ParameterSetName -eq "Certificate") {
        $connect_mg_params["ClientId"] = $client_id
        $connect_mg_params["CertificateThumbprint"] = $certificate_thumbpint

    }
# If the parameter set is delegated, then we need to set the scope
} ElseIf ($PSCmdlet.ParameterSetName -eq "Delegated") {
    $connect_mg_params["Scope"] = $scope

}
#endregion

#region Graph Call
Try { 
    Write-Host "Connecting to Graph" 
    # Connecting to Microsoft Graph
    Connect-MgGraph @connect_mg_params
    Write-Host "Connected to Graph successfully" -ForegroundColor Green

} Catch {
    Write-Error "Failed to connect to Graph: $_"
    Exit 1

}
#endregion

#region Main
# Getting the conditional access policies
Write-Host "Getting conditional access policies for tenant $($tenant_id)"
$policies =  Get-MgIdentityConditionalAccessPolicy

# Adding the break glass account and excluded from policy to the policy object
$policies | Add-Member -Name "BreakGlassAccount" -Value ""
$policies | Add-Member -Name "ExcludedFromPolicy" -Value $false

Try {
    # Looping through each break glass account
    foreach ($account in $break_glass_account) {
        # Getting the user object for the break glass account
        Write-Host "Verifying user object for $($account)"
        $user = Get-MgUser -Filter "id eq '$account'"

        # Getting the user's group memberships
        Write-Host "Retrieving user's $($account) group transitive memberships for $($user.id)"
        $member_of = Get-MgUserTransitiveMemberOf -UserId $user.id 

        # Creating an array of the user's group memberships and the user's id
        $inclusion_dir_objs = @($user.id) + @($member_of.id) 

        # Looping through each conditional access policy
        Write-Host "Checking if $($account) is excluded from the conditional access policies"
        Foreach ($policy in $policies) {
            # Creating a new policy object
            $policy_obj = $policy | Select-Object $select
            $policy_obj.BreakGlassAccount = $account

            # Getting the group exclusions for the conditional access policy
            $group_exclusions = $policy.Conditions.Users.ExcludeGroups

            # Getting the user exclusions for the conditional access policy
            $user_exclusions = $policy.Conditions.Users.ExcludeUsers

            # Creating an array of the group exclusions and the user exclusions
            $exclusion_dir_objs = @($group_exclusions) + @($user_exclusions)

            # Looping through each exclusion object
            Foreach ($obj in $inclusion_dir_objs) {
                # If the inclusion object is in the exclusion object array, then we set ExcludedFromPolicy to true and break the loop
                If ($obj -in $exclusion_dir_objs) {
                    $policy_obj.ExcludedFromPolicy = $true
                    Break

                # If the inclusion object is not in the exclusion object array, then we set ExcludedFromPolicy to false
                } Else {
                    $policy_obj.ExcludedFromPolicy = $false
                
                }
            }
            # Adding the policy to the output object
            If (!$policy_obj.ExcludedFromPolicy) {
                $output_obj.Add($policy_obj)
            
            }
        }
    }
} Catch {
    # If there is an error, we write an error message and exit
    Write-Error "Failed to get policies: $($_)"

}

#endregion #Send Mail

#region Send Mail
Try {
    # If there are policies applied to the break glass account, then we send an email
    If ($output_obj.Count -gt 0) {
        # Exporting the output object to a csv
        $output_obj | Export-Csv -Path $outfile

        # If there are email addresses to send the email to, then we send the email
        If ($to -and $from) {   
            If ($PSCmdlet.ParameterSetName -eq "Delegated") {
                Write-Warning "Sending messages as another user is not supported with delegated permissions. Please use a managed identity or app registration to send the email."
        
            } Else {
                # Sending the email
                Send-GraphMailMessage @send_mail_params
            
            }
        } 
    }
} Catch {
    # If there is an error, we write an error message and exit
    Write-Error "Failed to send email: $($_)"
    Exit 1

}

#endregion
