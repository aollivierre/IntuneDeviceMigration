$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import("C:\temp2\certs\cert.pfx", "Absurd0-Acting-Fetal-Relapsing-Sanctuary-Bulb-Startup-Cottage-Helper-Detached-Tumble-Exponent-Earmuff-Resume-Purging-Scoured-Wharf-Nicotine-Smudgy-Storm", [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet)

if ($cert.HasPrivateKey) {
    Write-Host "The certificate contains a private key."
} else {
    Write-Host "The certificate does not contain a private key."
}
