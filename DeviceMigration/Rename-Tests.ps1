# Define the target directory
# $targetDirectory = "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test"
# $targetDirectory = "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test\Pester\functions"
# $targetDirectory = "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test\Cresendo"
# $targetDirectory = "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test\Invoke-CommandAs"
$targetDirectory = "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\Migrate-ToAADJOnly"

# Step 1: List all files in the directory
$files = Get-ChildItem -Path $targetDirectory -File

# Step 2: Filter files that do not have '.test' anywhere in their name
$filesToRename = $files | Where-Object { $_.Name -notlike "*.test*" }

# Step 3: Rename the files by inserting '.test' before the file extension
foreach ($file in $filesToRename) {
    # Get the filename without the extension and the extension separately
    $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $extension = $file.Extension

    # Construct the new file name by appending '.test' before the extension
    $newName = "$fileNameWithoutExtension.test$extension"

    try {
        # Rename the file
        Rename-Item -Path $file.FullName -NewName (Join-Path $file.DirectoryName $newName)
        Write-Host "Renamed file: $($file.FullName) to $newName" -ForegroundColor Green
    } catch {
        Write-Host "Failed to rename file: $($file.FullName)" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
    }
}
