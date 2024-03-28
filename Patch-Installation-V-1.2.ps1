<#============================================================================================================
   Script Name: Patch-Installation.ps1
       Purpose: The script automatically install patches or KB's on all the servers given in a txt file.
         Notes: The script need a ServerList.txt file and KB file with the extension .msu for performing the installation from a Jumpbox server.
        Author: Aswindev
  Date Created: 03/20/2024
       Version: 1.2 - Testing Pending.
	     Fixes: Log Creation is almost fixed, the details regarding the installation will be displayed on the PS instance itself.
======================================================================================================================#>

$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$Servers = Get-Content .\ServerList.txt
$Folder= Get-ChildItem -Path .\ -Filter *.msu | Select-Object -ExpandProperty FullName
$LogFilePath = Join-Path -Path $ScriptDirectory -ChildPath "InstallationLog.txt"
$TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Log-InstallationDetails {
    param (
        [string]$Message
    )
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$TimeStamp - $Message"
    Add-Content -Path $LogFilePath -Value $LogMessage
}
if (-not (Test-Path -Path $LogFilePath)) {
    New-Item -ItemType File -Path $LogFilePath | Out-Null
}
if (-not (Test-Path -Path ".\ServerList.txt")) {
    Write-Host "ServerList.txt file not found in the script directory. Please add the ServerList file to proceed with Patch Installation." -ForegroundColor Red
    Log-InstallationDetails -Message "ServerList.txt file not found in the script directory. Please add the ServerList.txt file to proceed with Patch Installation."
}
if ($Folder.Count -eq 0) {
    Write-Host "No .msu files found in the script directory. Please add a KB file to proceed with the patch Installation..." -ForegroundColor Red
    Log-InstallationDetails -Message "No .msu files found in the script directory. Please add a KB file to proceed with the patch Installation."
    Exit
}
foreach ($Server in $Servers) {
    if (Test-Connection -ComputerName $Server -Count 1 -Quiet) {
        Write-Host "Server $Server is online." -ForegroundColor Green
        Log-InstallationDetails -Message "Server $Server is online."
    } else {
        Write-Host "Server $Server is offline." -ForegroundColor Red
        Log-InstallationDetails -Message "Server $Server is offline."
        continue
    }
    $Test = Test-Path -path "\\$Server\c$\WINUpdate\"
    if ($Test -eq $True) {
        Write-Host "Path exists, hence Copying Patches on $server."
        Log-InstallationDetails -Message "Path exists, hence Copying Patches on $server."
    } else {
        Write-Host "Path doesn't exists, hence Creating folder on $server..."
        Log-InstallationDetails -Message "Path doesn't exists, hence Creating folder on $server."
        New-Item -ItemType Directory -Name WINUpdate -Path "\\$Server\c$\"
    }
    Log-InstallationDetails -Message "Trying to Install patch on the server - $server."
    Log-InstallationDetails -Message "Find the details of Installation in the PowerShell Instance."
    expand -F:* $Folder "\\$Server\c$\WINUpdate"
    icm -ComputerName $server -Scriptblock {
        $CabFile = Get-ChildItem "c:\WINUpdate\Window*.cab" -Recurse | Select-Object -ExpandProperty VersionInfo
        $CabPath = $CabFile | Select FileName -ExpandProperty FileName

        Foreach ($cab in $CabPath) {
            $Result = & cmd /c DISM /Online /Add-Package /PackagePath:$cab /quiet /norestart
            echo "!!! Check the Installation Status here ---> $Result"
        }
       Start-Sleep -Seconds 5
       Remove-Item -Path "c:\WINUpdate\*.*" -Force
    }
    Remove-Item -Path "c:\WINUpdate\*.*" -Force
}
echo "<-------------- Check the staus of Installation in this Powershell Instance itself -------------->"
pause
