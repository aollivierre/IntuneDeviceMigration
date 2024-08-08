# Example usage
$StartMigrationProcessParams = @{
    MigrationConfigPath = "C:\ProgramData\AADMigration\scripts\MigrationConfig.psd1"
    ImagePath = "C:\ProgramData\AADMigration\Files\MigrationInProgress.bmp"
    RunOnceScriptPath = "C:\ProgramData\AADMigration\Scripts\PostRunOnce2.ps1"
    RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    PowershellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe"
    ExecutionPolicy = "Unrestricted"
    RunOnceName = "NextRun"
}
Start-MigrationProcess @StartMigrationProcessParams