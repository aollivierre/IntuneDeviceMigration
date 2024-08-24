$jobName = "AAD Migration"
# Start the script with error handling
try {
    # Generate the transcript file path
    # $transcriptPath = Get-TranscriptFilePath -Jobname $jobName

    $GetTranscriptFilePathParams = @{
        TranscriptsPath = "C:\Logs\Transcript"
        JobName         = $jobName
    }
    $transcriptPath = Get-TranscriptFilePath @GetTranscriptFilePathParams
    

    # Start the transcript
    Write-Host "Starting transcript at: $transcriptPath" -ForegroundColor Cyan
    Start-Transcript -Path $transcriptPath

    # Example script logic
    Write-Host "This is an example action being logged."

}
catch {
    Write-Host "An error occurred during script execution: $_" -ForegroundColor Red
} 

 
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


Stop-Transcript