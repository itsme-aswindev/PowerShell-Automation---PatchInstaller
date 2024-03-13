
# PowerShell Script for Automating Patch Installation on Multiple Remote Servers 

This repository contains a PowerShell script designed to automate the process of patch installation on multiple remote servers. The script utilizes PowerShell remoting capabilities to connect to remote servers and install patches without manual intervention, thereby saving time and effort for system administrators.


## Features
**Remote Patch Installation**: The script enables the installation of patches on multiple remote servers simultaneously.
- **Customization**: Users can specify which patches to install or apply custom configurations according to their requirements.
- **Logging**: Comprehensive logging functionality helps in tracking the patch installation process and identifying any issues encountered during execution.
- **Error Handling**: The script incorporates error handling mechanisms to gracefully handle errors and continue with the patch installation process.

## Requirements
Windows PowerShell (version X.X or later) installed on the machine running the script.
- Administrative privileges on both the local and remote machines.
- Network connectivity between the local machine and the remote servers.
- Appropriate firewall rules configured to allow PowerShell remoting (WinRM).
- Create a TXT file with the name "ServerList.txt" and place the file in the same directory as that of the script.
- The required KB with the extension ".msu" must be also placed at the same directory. (Note - Only one KB file must be placed at a time).
## Usage
1. Clone or download the repository to your local machine.
2. Open PowerShell with administrative privileges.
3. Navigate to the directory containing the script.
4. Modify the script according to your requirements, specifying the list of remote servers and patches to install.
5. Execute the script by running the following command:
    ```powershell
    .\PatchInstallationScript.ps1
    ```
6. Monitor the console output for progress updates and check the log files for detailed information about the patch installation process.
## Feedback

If you have any feedback, please reach out to us at aswinved@gmail.com

