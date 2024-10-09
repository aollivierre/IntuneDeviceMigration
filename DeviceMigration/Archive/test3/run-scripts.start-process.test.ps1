# Start both scripts as separate processes
$process1 = Start-Process -FilePath "powershell.exe" -ArgumentList "-File C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test3\script1.mutex.Dynamic.test.ps1" -PassThru
$process2 = Start-Process -FilePath "powershell.exe" -ArgumentList "-File C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test3\script2.mutex.Dynamic.test.ps1" -PassThru

# Wait for both processes to finish
$process1.WaitForExit()
$process2.WaitForExit()