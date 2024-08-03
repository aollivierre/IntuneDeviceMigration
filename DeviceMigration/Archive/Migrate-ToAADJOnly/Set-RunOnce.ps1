function Set-RunOnce {
    [CmdletBinding()]
    param (
        [string]$ScriptPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Set-RunOnce function" -Level "INFO"
        Log-Params -Params @{ ScriptPath = $ScriptPath }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Setting RunOnce script" -Level "INFO"
            $RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
            Set-ItemProperty -Path $RunOnceKey -Name "NextRun" -Value ("C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe -executionPolicy Unrestricted -File " + $ScriptPath) -Verbose
        } catch {
            Write-EnhancedLog -Message "An error occurred while setting RunOnce script: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Set-RunOnce function" -Level "INFO"
    }
}

# Example usage
# Set-RunOnce -ScriptPath "C:\ProgramData\AADMigration\Scripts\PostRunOnce.ps1"
