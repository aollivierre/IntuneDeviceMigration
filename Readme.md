<img width="1476" alt="image" src="https://github.com/user-attachments/assets/51272e13-f657-4d25-988e-cacd21e5acee">



---

🚀 **Get Ready for the Launch of the Device Migration Utility (DMU) v1!** 🚀

We’re thrilled to announce that **DMU v1** is launching soon! This powerful tool automates device migration from **On-prem or Hybrid AD** to **Azure AD (now Entra ID)**, guiding devices to **Entra Join** status without requiring a full wipe. Say goodbye to complex manual processes!

👀 **Want early access?** The **Beta version** is now open for testers! Join us to experience DMU firsthand and help shape the final release.

🔧 **What DMU Brings to the Table:**
- Automates **On-prem** to **Entra Join** migrations with minimal user impact
- Requires **automatic enrollment** (needs Entra ID P1) and **Intune enrollment** (requires Intune P1) for smooth device management in Intune
- Optional GitHub integration to securely upload logs or download an encrypted PPKG from a private repo using a Personal Access Token (PAT)
- Streamlined, robust handling of tasks like OneDrive syncing, scheduled task management, and detailed logging

⚠️ **Note:** Each DMU migration step (like using PPKG for Entra Join) is supported by Microsoft, but full migration without a wipe isn’t officially supported due to potential GPO and Intune CSP conflicts.

Curious? Join the **Beta testing** group now and be among the first to explore DMU v1! 🎉

#DMU #DeviceMigrationUtility #AzureAD #EntraID #Intune #ITAutomation #BetaTest #ComingSoon #StayTuned 

--- 


### 1\. **Project Overview**

*   **Title:** _Device Migration Utility (DMU)_
*   **Description:** This utility automates the migration of devices to Azure Active Directory (AAD) and OneDrive with a focus on seamless integration and efficient handling of critical tasks such as module installation, scheduled tasks, and logging. The script supports running in the SYSTEM context to simulate Intune behavior, encrypt sensitive data, and manage scheduled tasks for OneDrive synchronization and migration execution.

---

### Prerequisites

1. **PowerShell Version:**  
   - **PowerShell 5** is required for module installation.
   - Run the script in PowerShell 5 to ensure modules install in Windows PowerShell. Running in PowerShell 7 may cause issues with dependencies.

2. **Provisioning Package (PPKG):**  
   - **WCD Tool:** Use the Windows Configuration Designer (WCD) tool (available on the [Windows Configuration Designer (WCD)](https://learn.microsoft.com/en-us/windows/configuration/provisioning-packages/provisioning-install-icd)
) to create a Provisioning Package (PPKG).
   - **Automatic Account Creation and Entra Configuration:** After applying the PPKG, a specific provisioning package account is created in Entra ID. To prevent errors in Entra joins, exclude this account from **Conditional Access Policies** and **MFA requirements** in Entra.
   - **Supported Components:** While each step used by DMU, such as the PPKG, is supported by Microsoft, the overall process of migrating to Entra Join without a wipe is not officially supported.

3. **System Context:**  
   - The script should be run under the **SYSTEM account** to simulate Intune behavior, especially if you’re deploying the script via Intune.

4. **Automatic Enrollment Requirement:**  
   - Automatic enrollment needs to be enabled in your Intune tenant. Entra ID P1 and Intune P1 licenses are required for automatic enrollment and Intune device management.

5. **Administrative Permissions:**  
   - Ensure you have administrative permissions to execute the script and access the required contexts.

6. **GitHub Personal Access Token (Optional):**  
   - To upload logs or access an encrypted PPKG file stored in a private GitHub repository, you’ll need a **GitHub Personal Access Token (PAT)**.
   - **Usage:** 
     - **Log Uploads:** The script allows logs to be securely zipped and uploaded to your private GitHub repository if desired.
     - **Encrypted PPKG Download:** If the PPKG is stored as an encrypted file in a private GitHub repository, the GitHub PAT enables secure access to download it.

---

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
    iex (irm bit.ly/4h1T0P4)
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
