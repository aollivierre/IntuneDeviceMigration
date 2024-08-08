@{

    #Global
    PackageName             = 'PR4B_PostReboot-FortiClientVPNInstaller'
    PackageUniqueGUID       = 'a9b10f27-0fca-4ed8-ac27-79e3428e27e4'
    Version                 = '1.0'

    #Script Mode:
    ScriptMode              = 'Remediation'

    # PackageExecutionContext = 'SYSTEM'
    PackageExecutionContext = 'USER'


    RepetitionInterval      = 'PT15M'
    DataFolder              = 'Data'


    UsePSADT                = $true

    # TriggerType
    # TriggerType             = 'Daily'

    TriggerType             = 'Logon'
    LogonUserId             = 'administrator'

    RunOnDemand             = $false  # Main option that controls execution
    # Additional options can be added here


    ScheduleOnly             = $true
}
