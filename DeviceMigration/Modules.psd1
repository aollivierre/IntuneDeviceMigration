@{
    RequiredModules = @(
        # My Custom Modules
        "EnhancedPSTools",          # Essential custom tools

        # Core PowerShell Modules
        "PSFramework",              # PowerShell framework for modular development
        "Pester",                   # Testing framework
        "PSReadLine",               # Command-line editing and history

        # Data Handling Modules
        "ImportExcel",              # Work with Excel files
        "powershell-yaml",          # YAML support in PowerShell
        "PSWriteHTML",              # HTML report generation

        # Microsoft Graph Modules
        "Microsoft.Graph.Authentication",          # Authentication
        "Microsoft.Graph.Applications",            # Application management
        "Microsoft.Graph.Identity.DirectoryManagement", # Directory management
        "Microsoft.Graph.Groups",                  # Group management
        "Microsoft.Graph.Identity.SignIns",        # Sign-in data

        # Intune Win32 Development Modules
        "IntuneWin32App",           # Intune Win32 app management
        "SvRooij.ContentPrep.Cmdlet", # Content preparation cmdlet

        # Other Utility Modules
        "MSAL.PS",                  # Microsoft Authentication Library
        "PSWindowsUpdate"           # Windows Update management
        # "PSADT"                     # PowerShell App Deployment Toolkit
        "BurntToast"                     # Showing Toast Notifications for key steps in the script
    )
}
