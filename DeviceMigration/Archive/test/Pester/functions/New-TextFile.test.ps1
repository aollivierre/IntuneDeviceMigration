function New-TextFile {
    param (
        [string]$FilePath,
        [string]$Content
    )

    if (-Not (Test-Path -Path (Split-Path -Path $FilePath -Parent))) {
        throw "The directory does not exist."
    }

    Set-Content -Path $FilePath -Value $Content
    return $FilePath
}
