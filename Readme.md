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

### 2\. **Prerequisites**

1. **Operating System Requirements:**
   - This tool is designed for **Windows 10** and **Windows 11** devices.
   - **Note:** The DMU tool is not intended for use on Windows Server environments.

2. **Internet Connection:**  
   - An active internet connection is required for installing necessary modules and dependencies.

3. **PowerShell Version:**  
   - **PowerShell 5** is required for module installation.
   - Run the script in PowerShell 5 to ensure modules install in Windows PowerShell. Running in PowerShell 7 may cause issues with dependencies.

4. **Provisioning Package (PPKG):**  
   - **WCD Tool:** Use the Windows Configuration Designer (WCD) tool (available on the [Windows Configuration Designer (WCD)](https://learn.microsoft.com/en-us/windows/configuration/provisioning-packages/provisioning-install-icd)
) to create a Provisioning Package (PPKG).
   - **Automatic Account Creation and Entra Configuration:** After applying the PPKG, a specific provisioning package account is created in Entra ID. To prevent errors in Entra joins, exclude this account from **Conditional Access Policies** and **MFA requirements** in Entra.
   - **Supported Components:** While each step used by DMU, such as the PPKG, is supported by Microsoft, the overall process of migrating to Entra Join without a wipe is not officially supported.

5. **Automatic Enrollment Requirement:**  
   - Automatic enrollment needs to be enabled in your Intune tenant. Entra ID P1 and Intune P1 licenses are required for automatic enrollment and Intune device management.

6. **Administrative Permissions:**  
   - Ensure you have local administrative permissions on the device running Windows 10/11 to execute the script and access the required contexts.
  
7. **System Context (Optional):**
   - For testing or deployment through **Intune**, the script can be run under the **SYSTEM account** to simulate Intune behavior. This is especially useful if you plan to make the tool available through the **Company Portal** or push it as a required app.
   - The main script includes a switch to enable **Intune simulation mode**, which will automatically run the script in the SYSTEM context if set to `True`. This mode uses `PsExec64.exe` in the background to simulate the Intune SYSTEM context.
   - **Note:** During the **Beta phase**, it is recommended to thoroughly test the tool in various scenarios before deploying it silently across devices.

8. **GitHub Personal Access Token (Optional):**  
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

---

### OneDrive and User Profile Preparation

This tool includes automated steps to ensure **OneDrive Known Folder Move (KFM)** is enabled and **OneDrive is fully synced** before starting the migration process. Additionally, the DMU tool will:

- Backup **Outlook signatures**, **Google Chrome Profile** and the **Downloads folder** to the logged-in user’s designated OneDrive folder.
  
#### Important Note on User Login:
To avoid sync errors during migration, please ensure that **all other user accounts are logged off**, leaving only the current user (under which OneDrive is running) logged in. Having multiple active user sessions can interfere with the OneDrive sync verification process, causing it to fail.

---

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


Below is the reformatted list of known issues using proper Markdown for your GitHub page:

---

## Known Issues

1. **LAPS Policy Requirement**  
   A Local Administrator Password Solution (LAPS) policy from Intune is required for local admin accounts. This is because a VPN connection is necessary to reach the domain controller, allowing the domain admin credentials to function properly. The script should connect to Intune and create a configuration profile under Endpoint Security to configure Windows LAPS manual or automatic which requires Windows 11 24 H2

2. **Device Removal from Intune**  
   The script needs the capability to remove the device from Intune during the preparation step before re-enrollment.

3. **Execution Policy Setting**  
   The `setup.ps1` script needs to explicitly set the execution policy at the beginning to ensure the script can run without policy-related errors.

4. **Access Denied for Windows Forms in Elevated Context**  
   When elevating the PowerShell console to admin, Windows Forms fail due to "Access Denied" errors. This occurs because the forms run under a different context than the user context being migrated.  
   - **Workaround:** Add the user to the local admin group after connecting to the VPN and elevating with the domain user (`lusrmgr.msc`). However, this is not ideal.  
   - **Alternative Solution:** Suppress the GUI if the local user is not an admin and instead fall back to console mode.

5. **Access Issues for Temporary Folder in Elevated Context**  
   The script encounters access issues when attempting to open the temporary folder under a different elevated context. This should be suppressed to avoid errors or service UI can be integrated to launch it under the SYSTEM context (requires testing)

6. **KeePassXC CLI Installation**  
   The script needs to install the KeePassXC CLI utility, as it is currently not found during execution.

7. **OneDrive Sync Utility Status Check on Windows 10**  
   The OneDrive Sync Utility status check is not working on Windows 10 version 22H2. Consider either fixing this issue or skipping the check altogether and logging a warning.

8. **Repository Re-download on Every Execution**  
   The script currently re-downloads the entire repository every time it runs.  
   - **Suggestion:** Implement a caching mechanism to use a previously downloaded copy and prompt the user to choose between using the cached version or re-downloading from scratch.

9. **Workgroup Join After Domain Disjoin**  
   The script should join the computer to the `MSHOME` workgroup after disjoining it from the domain.

10. **Primary User Update After Migration**  
    The script should update the primary user assignment after the migration is completed. This could potentially be extended to update all users based on the logic from the T-Bone script.


---

### Credits / Inspirations:
- [Migrating AD Domain Joined Computer to Azure AD Cloud-only Join – Modern Endpoint](https://www.modernendpoint.com/managed/Migrating-AD-Domain-Joined-Computer-to-Azure-AD-Cloud-only-join/)
- [Active Directory Join to Azure AD Join – Mauvtek](https://mauvtek.com/home/active-directory-join-to-azure-ad-join)

---

### Contributing

Thank you for your interest in contributing to this project! Contributions help make open source a vibrant place for learning, inspiration, and collaboration. Whether you’re submitting pull requests, opening issues, or sharing ideas, your contributions are appreciated and benefit everyone. 

If you’re interested in contributing, please:
- **Open an Issue:** If you spot a bug or have suggestions, please create an issue to discuss.
- **Submit a Pull Request:** Feel free to make improvements and submit them for review.

For detailed guidelines, please refer to the [CONTRIBUTING]() file.

#### Bug Report Guidelines
When reporting a bug, please ensure that it is:
- **Reproducible:** Share the steps needed to replicate the issue.
- **Detailed:** Include specifics like version, environment, and relevant settings.
- **Unique:** Check for similar issues to avoid duplicates.
- **Focused:** Limit each report to a single bug.

I'm open to collaborating with contributors and welcome those interested in direct maintenance. Let’s work together to make DMU the best it can be!

---

### Support

This project is open source, developed in my spare time, and designed to help the community. While I’m unable to provide dedicated support, I encourage users to collaborate and share insights via GitHub discussions.

For commercial support inquiries, please reach out through my LinkedIn profile. https://www.linkedin.com/in/aollivierre/ 

#### Sponsorship
If this project benefits your commercial work, please consider supporting it through sponsorship.

---

### Contact

You can reach out to the maintainer through:
- **[GitHub Discussions](https://github.com/aollivierre/IntuneDeviceMigration/discussions)**
- **Email** (listed in the GitHub profile)

---

### License

This project is licensed under the **MIT License**. See the [LICENSE]() file for more details.

---

This version provides a welcoming, collaborative message and clarifies each section for potential contributors, users, and supporters. Let me know if you need further customization!

 
 
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
