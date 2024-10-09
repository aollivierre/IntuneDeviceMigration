# Backup the current PSModulePath
$backupPSModulePath = $env:PSModulePath

# Define the default PSModulePath values based on the standard paths for Windows PowerShell
$defaultPaths = @(
    'C:\Program Files\WindowsPowerShell\Modules',
    'C:\Windows\system32\WindowsPowerShell\v1.0\Modules',
    'C:\Users\Admin-Abdullah\Documents\WindowsPowerShell\Modules',
    'C:\Users\Admin-Abdullah\.vscode\extensions\ms-vscode.powershell-2024.2.2\modules'
)

# Rebuild the PSModulePath with only the default paths
$env:PSModulePath = [string]::Join(';', $defaultPaths)

Write-Host "PSModulePath cleaned up and reset to default paths:"
Write-Host $env:PSModulePath

# Optional: Save the backup of the old PSModulePath in case you want to restore it
Write-Host "The original PSModulePath has been backed up."
Write-Host $backupPSModulePath






# Define the default PSModulePath values
$defaultPaths = @(
    'C:\Program Files\WindowsPowerShell\Modules',
    'C:\Windows\system32\WindowsPowerShell\v1.0\Modules',
    'C:\Users\Admin-Abdullah\Documents\WindowsPowerShell\Modules',
    'C:\Users\Admin-Abdullah\.vscode\extensions\ms-vscode.powershell-2024.2.2\modules'
)

# Define the backup of the original PSModulePath
$backupPaths = @(
    'C:\Users\ADMIN-~1\AppData\Local\Temp\ab1f996e-0678-4a06-90fc-f549e7f3f242_20241008_151653',
    'C:\Program Files\WindowsPowerShell\Modules',
    'C:\Users\Admin-Abdullah\Documents\WindowsPowerShell\Modules',
    'C:\Windows\System32\WindowsPowerShell\v1.0\Modules',
    'C:\Program Files\WindowsPowerShell\Modules',
    'C:\Windows\system32\WindowsPowerShell\v1.0\Modules',
    'c:\Users\Admin-Abdullah\.vscode\extensions\ms-vscode.powershell-2024.2.2\modules'
)

# Combine both arrays into a table for display
$combinedPaths = foreach ($index in 0..([math]::Max($defaultPaths.Count, $backupPaths.Count) - 1)) {
    [PSCustomObject]@{
        "Final PSModulePath (Default)" = $defaultPaths[$index]
        "Backup PSModulePath (Original)" = if ($index -lt $backupPaths.Count) { $backupPaths[$index] } else { "" }
    }
}

# Display the results as a formatted table
$combinedPaths | Format-Table -AutoSize
