# Start both scripts as background jobs
$job1 = Start-Job -ScriptBlock { & "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test3\script1.mutex.Dynamic.test.ps1" }
$job2 = Start-Job -ScriptBlock { & "C:\code\IntuneDeviceMigration\DeviceMigration\Archive\test3\script2.mutex.Dynamic.test.ps1" }

# Wait for both jobs to complete
Wait-Job -Job $job1, $job2

# Get the results
$job1 | Receive-Job
$job2 | Receive-Job

# Clean up
Remove-Job -Job $job1, $job2