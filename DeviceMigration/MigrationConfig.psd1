@{

	MigrationPath    = "C:\ProgramData\AADMigration"
	UseOneDriveKFM   = $True
	InstallOneDrive  = $True
	TenantID         = "b5dae566-ad8f-44e1-9929-5669f1dbb343" #ICTC Tenant ID
	DeferDeadline    = "07/12/2024 18:00:00" #July 09 2024
	DeferTimes       = ""
	# StartBoundary = "2024-07-11T00:00:00"
	TempUser         = "MigrationInProgress"
	TempPass         = "Default1234"
	# DomainLeaveUser = ""
	# DomainLeavePass = ""
	# ProvisioningPack = "AAD Join.ppkg"
	ProvisioningPack = "C:\ProgramData\AADMigration\Files\ICTC_EJ_Bulk_Enrollment_v4\ICTC_EJ_Bulk_Enrollment_v5.ppkg"
}