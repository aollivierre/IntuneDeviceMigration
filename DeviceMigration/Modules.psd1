@{
    RequiredModules = @(
        "Microsoft.Graph.Authentication",
        "Microsoft.Graph.Applications",
        "Microsoft.Graph.Identity.DirectoryManagement",
        "Microsoft.Graph.Users"
    )
    ImportedModules = @(
        "Microsoft.Graph.Identity.DirectoryManagement",
        "Microsoft.Graph.Authentication",
        "Microsoft.Graph.Applications",
        "Microsoft.Graph.Users"
    )
    MyModules = @(
        "EnhancedAO.Graph.SignInLogs",
        # "EnhancedBoilerPlateAO",
        "EnhancedDeviceMigrationAO",
        "EnhancedFileManagerAO",
        "EnhancedGraphAO",
        "EnhancedHyperVAO",
        "EnhancedLoggingAO",
        "EnhancedPSADTAO",
        "EnhancedSchedTaskAO",
        "EnhancedSPOAO",
        "EnhancedVPNAO",
        "EnhancedWin32DeployerAO"
    )
}
