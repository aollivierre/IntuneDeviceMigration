function Execute-MigrationToolkit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServiceUI,

        [Parameter(Mandatory = $true)]
        [string]$ExePath
    )

    Begin {
        Write-Host "Starting Execute-MigrationToolkit function"
        # Log-Params -Params @{
        #     ServiceUI = $ServiceUI
        #     ExePath   = $ExePath
        # }
    }

    Process {
        try {
            $targetProcesses = @(Get-WmiObject -Query "Select * FROM Win32_Process WHERE Name='explorer.exe'" -ErrorAction SilentlyContinue)
            if ($targetProcesses.Count -eq 0) {
                Write-Host "No user logged in, running without ServiceUI"
                Start-Process -FilePath $ExePath -ArgumentList '-DeployMode "NonInteractive"' -Wait -NoNewWindow
            } else {
                foreach ($targetProcess in $targetProcesses) {
                    $Username = $targetProcess.GetOwner().User
                    Write-Host "$Username logged in, running with ServiceUI"
                }
                Start-Process -FilePath $ServiceUI -ArgumentList "-Process:explorer.exe $ExePath" -NoNewWindow
            }
        } catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "An error occurred: $ErrorMessage" -Level "ERROR"
            # Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-Host "Install Exit Code = $LASTEXITCODE"
        Write-Host "Exiting Execute-MigrationToolkit function"
        Exit $LASTEXITCODE
    }
}

# Define paths
$ToolkitPaths = @{
    ServiceUI = "C:\ProgramData\AADMigration\Files\ServiceUI.exe"
    ExePath   = "C:\ProgramData\AADMigration\Toolkit\Deploy-Application.exe"
}

# Example usage with splatting
Execute-MigrationToolkit @ToolkitPaths
