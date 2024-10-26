<img width="1476" alt="image" src="https://github.com/user-attachments/assets/51272e13-f657-4d25-988e-cacd21e5acee">



---

🚀 **Coming Soon: The Device Migration Utility (DMU) v1!** 🚀

Get ready to simplify your **On-prem AD** and **Hybrid AD joins** into **Azure AD (now Entra ID) joins** with the upcoming **DMU tool v1**! This powerhouse script is built to automate the move to **Entra Joined** status while managing device state, user profiles, OneDrive, and more.

**Beta Testers Wanted!** You can experience DMU early, and your insights will help shape the official release. 🚀

🔧 **What DMU Does:**
- Smoothly transitions devices to **Entra Joined**—no full device wipe required!
- Enables automatic **Intune enrollment** (with proper licensing, such as Entra ID P1 for auto-enrollment and Intune P1 for device management).
- Uses supported Microsoft methods, like the PPKG for Entra ID joins, but note: **this isn’t an officially supported method by Microsoft**—a clean wipe is still recommended to avoid GPO and Intune CSP conflicts. Yet, for many environments, DMU handles each step seamlessly!

🔍 **Highlights for Early Users:**
- Device migration with minimal user impact
- Entra ID and Intune integration made easy
- Automated tasks, logging, and security-first data handling

Curious? Ready to streamline migrations? Become a **Beta tester** today, and help bring DMU v1 to life!

#DMU #DeviceMigrationUtility #EntraID #IntuneEnrollment #AzureAD #BetaTest #ComingSoon #ITAutomation

--- 


### 1\. **Project Overview**

*   **Title:** _Device Migration Utility (DMU)_
*   **Description:** This utility automates the migration of devices to Azure Active Directory (AAD) and OneDrive with a focus on seamless integration and efficient handling of critical tasks such as module installation, scheduled tasks, and logging. The script supports running in the SYSTEM context to simulate Intune behavior, encrypt sensitive data, and manage scheduled tasks for OneDrive synchronization and migration execution.

Here’s the revised **Prerequisites** section with the details on the provisioning package (PPKG) and conditional access exclusions:

* * *

### 2\. **Prerequisites**

1.  **PowerShell Version:**
    
    *   **PowerShell 5** (required for module installation).
    *   The script must be run using PowerShell 5 to ensure proper module installation in Windows PowerShell. Running it in PowerShell 7 could cause issues with module dependencies.
2.  **Provisioning Package (PPKG):**
    
    *   **WCD Tool:** Create a Provisioning Package (PPKG) using the Windows Configuration Designer (WCD) tool, which can be downloaded from the Microsoft website.
    *   **Automatic Account Creation:** When the PPKG is created and applied, it will automatically create a specific provisioning package account in Entra ID.
    *   **Conditional Access and MFA Exclusions:**
        *   To avoid issues with the Entra join process using the PPKG, ensure the PPKG account GUID is excluded from **Conditional Access Policies** and **MFA requirements**.
        *   After the account is created, go to Entra and configure these exclusions.
3.  **System Context:**
    
    *   The script should be run under the **SYSTEM account** to simulate Intune behavior and allow full device access when necessary. This is critical when deploying the script via Intune.
4.  **Automated Git and GitHub Installation:**
    
    *   The script automates the installation of **Git** and the **GitHub CLI** if they are not already present on the system.
5.  **Administrative Permissions:**
    
    *   Ensure you have administrative permissions to execute the script, especially when running under the SYSTEM account or handling device-level changes.

* * *

### 3\. **Installation**

*   **Easy Installation Command:** To simplify the process, the script can be run using an `iex` command that will handle downloading the entire GitHub repository, unzipping it, and initiating the required modules and setup:
    
    ```powershell
    iex (irm bit.ly/4h1T0P4)
    ```
    
    This command will:
    *   Download the entire repository.
    *   Install the PSFramework and other necessary modules (including `PSFFramework`, `Install-EnhancedModuleStarterAO`, and custom scripts on the PowerShell Gallery).
    *   Start the script for the user automatically.

### 4\. **Usage Instructions**

*   **Running the Script:** Run the following command to initiate the DMU setup:
    
    ```powershell
    iex (irm bit.ly/4h1T0P4)
    ```
    
    *   This will execute the necessary setup automatically, so no manual downloading or unzipping is required.
*   **Logs:**
    *   Logs are stored locally at `C:\logs`.
    *   **Optional:** Users can choose to upload logs to GitHub by zipping the logs and submitting them.

### 5\. **Features**

*   **Automatic Module Installation:** The script uses the `Install-EnhancedModuleStarterAO` to install essential modules such as `PSFramework` and `Enhanced PS Tools`.
*   **Mutex for Critical Sections:** Mutex locks are used to prevent simultaneous execution of critical sections, such as module installation, ensuring a smooth execution process.
*   **Scheduled Tasks:** Five scheduled tasks are created to manage key migration actions:
    1.  OneDrive sync status.
    2.  Backing up user files to OneDrive.
    3.  Initiating migration via the PowerShell Application Deployment Toolkit (PSADT) v3 (with plans to upgrade to V4 when officially released https://patchmypc.com/psadt-v4)
    4.  Clearing OneDrive cache.
    5.  Post-migration cleanup.
*   **Encryption:** The script encrypts sensitive information if the user opts to upload logs to GitHub. This includes encrypting secrets for secure upload.
*   **Status Pop-up:** A Windows form provides the device’s Azure AD and Intune enrollment status. If the device is already Azure AD joined and Intune enrolled, the script exits gracefully.

### 6\. **Logging**

*   **Local Logs:** All logs are stored in `C:\logs` with detailed information on script execution.
*   **Optional GitHub Upload:** Logs can optionally be zipped and uploaded to a designated GitHub repository for further analysis. This feature is controlled by the script and is not mandatory.

### 7\. **Encryption and Decryption (Optional)**

*   **Purpose:** Encrypts sensitive information only when logs are being uploaded to GitHub.
*   **No Encryption Needed for Local Logs:** If logs are kept local, encryption and decryption are not triggered.

### 8\. **Example Workflow**

*   **Initial Setup and Execution:**
    
    ```powershell
    iex (irm 'URL-to-script')
    ```
    
    *   This command will automatically:
        1.  Download the repository.
        2.  Unzip the files.
        3.  Install the required modules (PSFramework, Install-EnhancedModuleStarterAO, and others).
        4.  Execute the script to handle Azure AD migration tasks.
*   **Azure AD and Intune Status:** If the device is already Azure AD joined and enrolled in Intune, a graphical status pop-up will appear, and the script will exit.

### 9\. **Contributing**

*   **Reporting Issues:** You can report issues by submitting them on GitHub.
*   **Pull Requests:** Contributions are welcome through pull requests for enhancements or bug fixes.

### 10\. **Known Issues and Troubleshooting**

*   **PowerShell 7 Incompatibility:** Ensure you are using PowerShell 5, as module installations will fail in PowerShell 7.
*   **Simulating Intune Behavior:** When simulating Intune, ensure the script is run under the SYSTEM account to mimic the expected behavior.
*   **Module Installation:** The script automates module installation, but if any issues arise, check the logs stored in `C:\logs\psf`.

* * *

### Final Considerations:

*   **Remove Dev/Prod References:** Since the utility is primarily for production use, remove references to development modes from the public-facing documentation.
*   **Simplified Execution:** Emphasize the use of the `iex` command for easy script execution, avoiding manual downloads.
*   **GitHub Integration:** Highlight that uploading logs to GitHub is optional but available for advanced users.

Does this revised structure align with your expectations, or would you like to adjust anything further?







 
 
 # Setup Instructions

### Call using PowerShell:

- Using full URL:
    ```powershell
    powershell -Command "iex (irm https://raw.githubusercontent.com/aollivierre/IntuneDeviceMigration/refs/heads/main/Setup.ps1)"
    ```

- Using shortened URLs:
    ```powershell
    powershell -Command "iex (irm https://bit.ly/4h1T0P4)"
    ```
    
    ```powershell
    powershell -Command "iex (irm bit.ly/4h1T0P4)"
    ```

### If you are already in PowerShell (URL is case sensitive):

  ```powershell
  iex (irm bit.ly/4h1T0P4)
  ```
