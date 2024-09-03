function Check-FileExists {
    param (
        [string]$FilePath
    )

    if (Test-Path -Path $FilePath) {
        return "File exists"
    } else {
        return "File does not exist"
    }
}
