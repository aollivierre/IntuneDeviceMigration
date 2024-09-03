# $ppkgPath = "C:\ProgramData\AADMigration\Files\ICTC_EJ_Bulk_Enrollment_v4\ICTC_EJ_Bulk_Enrollment_v5.ppkg"
$ppkgPath = "C:\code\IntuneDeviceMigration\DeviceMigration\Files\ICTC_Project_2_Aug_29_2024\ICTC_Project_2.ppkg"
$logPath = "C:\code\IntuneDeviceMigration\DeviceMigration\Files\ICTC_Project_1_Aug_29_2024\InstallLog.etl"

Install-ProvisioningPackage -PackagePath $ppkgPath -ForceInstall -LogsDirectory $logPath