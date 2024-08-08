function Execute-MigrationToolkit {
    <#
    .SYNOPSIS
    Executes the Migration Toolkit.

    .DESCRIPTION
    This function executes the Migration Toolkit. If a user is logged in, it runs the toolkit with ServiceUI to display it to the user. Otherwise, it runs the toolkit in non-interactive mode.

    .PARAMETER ServiceUI
    The path to the ServiceUI executable.

    .PARAMETER ExePath
    The path to the Migration Toolkit executable.

    .EXAMPLE
    $ToolkitPaths = @{
        ServiceUI = "C:\ProgramData\AADMigration\Files\ServiceUI.exe"
        ExePath   = "C:\ProgramData\AADMigration\Toolkit\Deploy-Application.exe"
    }
    Execute-MigrationToolkit @ToolkitPaths
    Executes the Migration Toolkit with the specified paths.

    .NOTES
    This function requires the ServiceUI and Migration Toolkit executables to be available at the specified paths.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServiceUI,

        [Parameter(Mandatory = $true)]
        [string]$ExePath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Execute-MigrationToolkit function" -Level "Notice"
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    Process {
        try {
            $targetProcesses = @(Get-WmiObject -Query "Select * FROM Win32_Process WHERE Name='explorer.exe'" -ErrorAction SilentlyContinue)
            if ($targetProcesses.Count -eq 0) {
                Write-EnhancedLog -Message "No user logged in, running without ServiceUI" -Level "INFO"
                Start-Process -FilePath $ExePath -ArgumentList '-DeployMode "NonInteractive"' -Wait -NoNewWindow
            } else {
                foreach ($targetProcess in $targetProcesses) {
                    $Username = $targetProcess.GetOwner().User
                    Write-EnhancedLog -Message "$Username logged in, running with ServiceUI" -Level "INFO"
                }
                Start-Process -FilePath $ServiceUI -ArgumentList "-Process:explorer.exe $ExePath" -NoNewWindow
            }
        } catch {
            $ErrorMessage = $_.Exception.Message
            Write-EnhancedLog -Message "An error occurred: $ErrorMessage" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Install Exit Code = $LASTEXITCODE" -Level "Notice"
        Write-EnhancedLog -Message "Exiting Execute-MigrationToolkit function" -Level "Notice"
        Exit $LASTEXITCODE
    }
}

# Example usage with splatting
$ToolkitPaths = @{
    ServiceUI = "C:\ProgramData\AADMigration\Files\ServiceUI.exe"
    ExePath   = "C:\ProgramData\AADMigration\Toolkit\Deploy-Application.exe"
}

Execute-MigrationToolkit @ToolkitPaths
