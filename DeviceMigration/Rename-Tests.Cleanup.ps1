# Define the target directory
$targetDirectory = "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test"

# Step 1: List all files in the directory
$files = Get-ChildItem -Path $targetDirectory -File

# Step 2: Filter files that have '.test' appended after their actual extension
$filesToClean = $files | Where-Object { $_.Name -like "*.test" }

# Step 3: Remove the '.test' from the file name
foreach ($file in $filesToClean) {
    # Construct the original file name by removing the '.test' at the end
    $newName = $file.Name -replace "\.test$", ""

    try {
        # Rename the file to remove '.test'
        Rename-Item -Path $file.FullName -NewName (Join-Path $file.DirectoryName $newName)
        Write-Host "Renamed file: $($file.FullName) to $newName" -ForegroundColor Green
    } catch {
        Write-Host "Failed to rename file: $($file.FullName)" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
    }
}
