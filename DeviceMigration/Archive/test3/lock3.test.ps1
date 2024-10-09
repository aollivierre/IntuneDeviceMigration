$mutexName = "Global\ModuleInstallLock"
$mutex = [System.Threading.Mutex]::new($false, $mutexName)

try {
    # Wait for the lock with a timeout
    if ($mutex.WaitOne(300000)) { # 5-minute timeout
        Write-Host "Acquired the lock. Proceeding with module installation."
        # Perform module installation or import here

        Start-Sleep -Seconds 10 # Simulate some work
    }
    else {
        Write-Host "Failed to acquire the lock within the timeout period."
    }
}
finally {
    # Release the mutex
    $mutex.ReleaseMutex() | Out-Null
    $mutex.Dispose()
}
