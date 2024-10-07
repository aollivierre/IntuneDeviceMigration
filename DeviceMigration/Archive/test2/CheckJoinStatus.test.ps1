
Import-Module 'C:\code\ModulesV2\EnhancedModuleStarterAO\EnhancedModuleStarterAO.psm1'

# Define a hashtable for splatting
$moduleStarterParams = @{
    Mode                   = 'dev'
    SkipPSGalleryModules   = $true
    SkipCheckandElevate    = $true
    SkipPowerShell7Install = $true
    SkipEnhancedModules    = $true
    SkipGitRepos           = $true
}

# Call the function using the splat
Invoke-ModuleStarter @moduleStarterParams


Test-DeviceStatusAndEnrollment -ScriptPath $PSScriptRoot

Wait-Debugger



# # Example usage to print out the values
# $dsregStatus = Get-DSRegStatus

# # Output to the console
# Write-Host "Device Join Status:"
# Write-Host "-------------------"
# Write-Host "Is Workgroup: " $dsregStatus.IsWorkgroup
# Write-Host "Is Azure AD Joined: " $dsregStatus.IsAzureADJoined
# Write-Host "Is Hybrid Joined: " $dsregStatus.IsHybridJoined
# Write-Host "Is On-prem Joined: " $dsregStatus.IsOnPremJoined

# # Output MDM Enrollment Status using an if-else statement
# if ($dsregStatus.IsMDMEnrolled) {
#     Write-Host "MDM Enrollment: Yes"
# } else {
#     Write-Host "MDM Enrollment: No"
# }

# # If the MDM URL exists, display it
# if ($dsregStatus.MDMUrl) {
#     Write-Host "MDM URL: " $dsregStatus.MDMUrl
# }


# Wait-Debugger











# # Main script execution block
# $dsregStatus = Get-DSRegStatus

# # Determine and output the join status
# if ($dsregStatus.IsWorkgroup) {
#     Write-EnhancedLog -Message "Device is Workgroup joined (not Azure AD, Hybrid, or On-prem Joined)."
# }
# elseif ($dsregStatus.IsAzureADJoined -and -not $dsregStatus.IsHybridJoined) {
#     Write-EnhancedLog -Message "Device is Azure AD Joined."
# }
# elseif ($dsregStatus.IsHybridJoined) {
#     Write-EnhancedLog -Message "Device is Hybrid Joined (both On-prem and Azure AD Joined)."
# }
# elseif ($dsregStatus.IsOnPremJoined) {
#     Write-EnhancedLog -Message "Device is On-prem Joined only."
# }

# # Determine and output the MDM enrollment status
# if ($dsregStatus.IsMDMEnrolled) {
#     Write-EnhancedLog -Message "Device is Intune Enrolled."
# }
# else {
#     Write-EnhancedLog -Message "Device is NOT Intune Enrolled."
# }

# # Exit code based on Azure AD and MDM status
# if ($dsregStatus.IsAzureADJoined -and -not $dsregStatus.IsHybridJoined -and $dsregStatus.IsMDMEnrolled) {
#     Write-EnhancedLog -Message "Device is Azure AD Joined and Intune Enrolled. No migration needed. Here is the output from: dsregcmd /status" -Level 'WARNING'

#     # Output to the console
#     Write-Host "Device Join Status:"
#     Write-Host "-------------------"
#     Write-Host "Is Workgroup: " $dsregStatus.IsWorkgroup
#     Write-Host "Is Azure AD Joined: " $dsregStatus.IsAzureADJoined
#     Write-Host "Is Hybrid Joined: " $dsregStatus.IsHybridJoined
#     Write-Host "Is On-prem Joined: " $dsregStatus.IsOnPremJoined

#     # Output MDM Enrollment Status using an if-else statement
#     if ($dsregStatus.IsMDMEnrolled) {
#         Write-Host "MDM Enrollment: Yes"
#     }
#     else {
#         Write-Host "MDM Enrollment: No"
#     }

#     # If the MDM URL exists, display it
#     if ($dsregStatus.MDMUrl) {
#         Write-Host "MDM URL: " $dsregStatus.MDMUrl
#     }

#     # Wait-Debugger

#     Show-DeviceStatusForm
#     exit 0 # Do not migrate: Device is Azure AD Joined and Intune Enrolled
# }
# else {

#     Write-EnhancedLog -Message "Device is not 100% Azure AD joined or is hybrid/on-prem joined. Here is the output from: dsregcmd /status"

#     # Output to the console
#     Write-Host "Device Join Status:"
#     Write-Host "-------------------"
#     Write-Host "Is Workgroup: " $dsregStatus.IsWorkgroup
#     Write-Host "Is Azure AD Joined: " $dsregStatus.IsAzureADJoined
#     Write-Host "Is Hybrid Joined: " $dsregStatus.IsHybridJoined
#     Write-Host "Is On-prem Joined: " $dsregStatus.IsOnPremJoined
 
#     # Output MDM Enrollment Status using an if-else statement
#     if ($dsregStatus.IsMDMEnrolled) {
#         Write-Host "MDM Enrollment: Yes"
#     }
#     else {
#         Write-Host "MDM Enrollment: No"
#     }
 
#     # If the MDM URL exists, display it
#     if ($dsregStatus.MDMUrl) {
#         Write-Host "MDM URL: " $dsregStatus.MDMUrl
#     }

     
#     Show-DeviceStatusForm
#     # Migrate: All other cases where the device is not 100% Azure AD joined or is hybrid/on-prem joined
#     # exit 1
# }

# # Wait-Debugger
































#    # Main script execution block
#    $dsregStatus = Get-DSRegStatus

#    # Determine and output the join status
#    if ($dsregStatus.IsWorkgroup) {
#        Write-EnhancedLog -Message "Device is Workgroup joined (not Azure AD, Hybrid, or On-prem Joined)."
#    }
#    elseif ($dsregStatus.IsAzureADJoined -and -not $dsregStatus.IsHybridJoined) {
#        Write-EnhancedLog -Message "Device is Azure AD Joined."
#    }
#    elseif ($dsregStatus.IsHybridJoined) {
#        Write-EnhancedLog -Message "Device is Hybrid Joined (both On-prem and Azure AD Joined)."
#    }
#    elseif ($dsregStatus.IsOnPremJoined) {
#        Write-EnhancedLog -Message "Device is On-prem Joined only."
#    }

#    # Determine and output the MDM enrollment status
#    if ($dsregStatus.IsMDMEnrolled) {
#        Write-EnhancedLog -Message "Device is Intune Enrolled."
#    }
#    else {
#        Write-EnhancedLog -Message "Device is NOT Intune Enrolled."
#    }

#    # Exit code based on Azure AD and MDM status
#    if ($dsregStatus.IsAzureADJoined -and -not $dsregStatus.IsHybridJoined -and $dsregStatus.IsMDMEnrolled) {
#        Write-EnhancedLog -Message "Device is Azure AD Joined and Intune Enrolled. No migration needed. Here is the output from: dsregcmd /status" -Level 'WARNING'



#        # Output device join status using Write-EnhancedLog with levels
#        Write-EnhancedLog -Message "Device Join Status:" -Level "INFO"
#        Write-EnhancedLog -Message "-------------------" -Level "INFO"
#        Write-EnhancedLog -Message "Is Workgroup: $($dsregStatus.IsWorkgroup)" -Level "INFO"
#        Write-EnhancedLog -Message "Is Azure AD Joined: $($dsregStatus.IsAzureADJoined)" -Level "INFO"
#        Write-EnhancedLog -Message "Is Hybrid Joined: $($dsregStatus.IsHybridJoined)" -Level "INFO"
#        Write-EnhancedLog -Message "Is On-prem Joined: $($dsregStatus.IsOnPremJoined)" -Level "INFO"

#        # Output MDM Enrollment Status using Write-EnhancedLog
#        if ($dsregStatus.IsMDMEnrolled) {
#            Write-EnhancedLog -Message "MDM Enrollment: Yes" -Level "INFO"
#        }
#        else {
#            Write-EnhancedLog -Message "MDM Enrollment: No" -Level "WARNING"
#        }

#        # If the MDM URL exists, display it using Write-EnhancedLog
#        if ($dsregStatus.MDMUrl) {
#            Write-EnhancedLog -Message "MDM URL: $($dsregStatus.MDMUrl)" -Level "INFO"
#        }
#        else {
#            Write-EnhancedLog -Message "MDM URL not available" -Level "WARNING"
#        }




#        # Output to the console with color coding
#        Write-Host "Device Join Status:" -ForegroundColor White
#        Write-Host "-------------------" -ForegroundColor White

#        # Workgroup status
#        if ($dsregStatus.IsWorkgroup) {
#            Write-Host "Is Workgroup: Yes" -ForegroundColor Red
#        }
#        else {
#            Write-Host "Is Workgroup: No" -ForegroundColor Green
#        }

#        # Azure AD Joined status
#        if ($dsregStatus.IsAzureADJoined) {
#            Write-Host "Is Azure AD Joined: Yes" -ForegroundColor Green
#        }
#        else {
#            Write-Host "Is Azure AD Joined: No" -ForegroundColor Red
#        }

#        # Hybrid Joined status
#        if ($dsregStatus.IsHybridJoined) {
#            Write-Host "Is Hybrid Joined: Yes" -ForegroundColor Yellow
#        }
#        else {
#            Write-Host "Is Hybrid Joined: No" -ForegroundColor Green
#        }

#        # On-prem Joined status
#        if ($dsregStatus.IsOnPremJoined) {
#            Write-Host "Is On-prem Joined: Yes" -ForegroundColor Yellow
#        }
#        else {
#            Write-Host "Is On-prem Joined: No" -ForegroundColor Green
#        }

#        # Output MDM Enrollment Status using color coding
#        if ($dsregStatus.IsMDMEnrolled) {
#            Write-Host "MDM Enrollment: Yes" -ForegroundColor Green
#        }
#        else {
#            Write-Host "MDM Enrollment: No" -ForegroundColor Red
#        }

#        # If the MDM URL exists, display it in Green, otherwise show a warning
#        if ($dsregStatus.MDMUrl) {
#            Write-Host "MDM URL: $($dsregStatus.MDMUrl)" -ForegroundColor Green
#        }
#        else {
#            Write-Host "MDM URL: Not Available" -ForegroundColor Red
#        }





#        # Wait-Debugger

#        Show-DeviceStatusForm
#        exit 0 # Do not migrate: Device is Azure AD Joined and Intune Enrolled
#    }
#    else {

#        Write-EnhancedLog -Message "Device is not 100% Azure AD joined or is hybrid/on-prem joined. Here is the output from: dsregcmd /status"



       
#        # Output device join status using Write-EnhancedLog with levels
#        Write-EnhancedLog -Message "Device Join Status:" -Level "INFO"
#        Write-EnhancedLog -Message "-------------------" -Level "INFO"
#        Write-EnhancedLog -Message "Is Workgroup: $($dsregStatus.IsWorkgroup)" -Level "INFO"
#        Write-EnhancedLog -Message "Is Azure AD Joined: $($dsregStatus.IsAzureADJoined)" -Level "INFO"
#        Write-EnhancedLog -Message "Is Hybrid Joined: $($dsregStatus.IsHybridJoined)" -Level "INFO"
#        Write-EnhancedLog -Message "Is On-prem Joined: $($dsregStatus.IsOnPremJoined)" -Level "INFO"

#        # Output MDM Enrollment Status using Write-EnhancedLog
#        if ($dsregStatus.IsMDMEnrolled) {
#            Write-EnhancedLog -Message "MDM Enrollment: Yes" -Level "INFO"
#        }
#        else {
#            Write-EnhancedLog -Message "MDM Enrollment: No" -Level "WARNING"
#        }

#        # If the MDM URL exists, display it using Write-EnhancedLog
#        if ($dsregStatus.MDMUrl) {
#            Write-EnhancedLog -Message "MDM URL: $($dsregStatus.MDMUrl)" -Level "INFO"
#        }
#        else {
#            Write-EnhancedLog -Message "MDM URL not available" -Level "WARNING"
#        }


#        # Output to the console with color coding
#        Write-Host "Device Join Status:" -ForegroundColor White
#        Write-Host "-------------------" -ForegroundColor White

#        # Workgroup status
#        if ($dsregStatus.IsWorkgroup) {
#            Write-Host "Is Workgroup: Yes" -ForegroundColor Red
#        }
#        else {
#            Write-Host "Is Workgroup: No" -ForegroundColor Green
#        }

#        # Azure AD Joined status
#        if ($dsregStatus.IsAzureADJoined) {
#            Write-Host "Is Azure AD Joined: Yes" -ForegroundColor Green
#        }
#        else {
#            Write-Host "Is Azure AD Joined: No" -ForegroundColor Red
#        }

#        # Hybrid Joined status
#        if ($dsregStatus.IsHybridJoined) {
#            Write-Host "Is Hybrid Joined: Yes" -ForegroundColor Yellow
#        }
#        else {
#            Write-Host "Is Hybrid Joined: No" -ForegroundColor Green
#        }

#        # On-prem Joined status
#        if ($dsregStatus.IsOnPremJoined) {
#            Write-Host "Is On-prem Joined: Yes" -ForegroundColor Yellow
#        }
#        else {
#            Write-Host "Is On-prem Joined: No" -ForegroundColor Green
#        }

#        # Output MDM Enrollment Status using color coding
#        if ($dsregStatus.IsMDMEnrolled) {
#            Write-Host "MDM Enrollment: Yes" -ForegroundColor Green
#        }
#        else {
#            Write-Host "MDM Enrollment: No" -ForegroundColor Red
#        }

#        # If the MDM URL exists, display it in Green, otherwise show a warning
#        if ($dsregStatus.MDMUrl) {
#            Write-Host "MDM URL: $($dsregStatus.MDMUrl)" -ForegroundColor Green
#        }
#        else {
#            Write-Host "MDM URL: Not Available" -ForegroundColor Red
#        }


    
#        Show-DeviceStatusForm
#        # Migrate: All other cases where the device is not 100% Azure AD joined or is hybrid/on-prem joined
#        # exit 1
#    }