$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$LogFilePath = "$ScriptDirectory\InstallationLog.txt"
$ServerListFile = "$ScriptDirectory\ServerList.txt"
$MSUFiles = Get-ChildItem "$ScriptDirectory\*.msu"

function Log-InstallationDetails {
    param (
        [string]$Message
    )
    $LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Add-Content -Path $LogFilePath -Value $LogMessage
}

# Check if ServerList.txt file exists
if (-not (Test-Path -Path $ServerListFile)) {
    Write-Host "ServerList.txt file not found in the script directory." -ForegroundColor Red
    Log-InstallationDetails -Message "ServerList.txt file not found in the script directory."
}

# Check if MSU files exist
if ($MSUFiles.Count -eq 0) {
    Write-Host "No .msu files found in the script directory." -ForegroundColor Red
    Log-InstallationDetails -Message "No .msu files found in the script directory."
}

# Get list of servers from ServerList.txt
$Servers = Get-Content $ServerListFile

foreach ($Server in $Servers) {
    # Check if server is online
    if (Test-Connection -ComputerName $Server -Count 1 -Quiet) {
        Write-Host "Server $Server is online." -ForegroundColor Green
        Log-InstallationDetails -Message "Server $Server is online."
    } else {
        Write-Host "Server $Server is offline." -ForegroundColor Red
        Log-InstallationDetails -Message "Server $Server is offline."
        continue
    }

    # Check if WINUpdate folder exists on the server
    $TestPath = "\\$Server\c$\WINUpdate\"
    if (-not (Test-Path -Path $TestPath)) {
        Write-Host "Path doesn't exist, hence creating folder on $Server." -ForegroundColor Yellow
        Log-InstallationDetails -Message "Path doesn't exist, hence creating folder on $Server."
        New-Item -ItemType Directory -Path $TestPath | Out-Null
    }

    foreach ($MSUFile in $MSUFiles) {
        Write-Host "Copying $($MSUFile.Name) to $Server..." -ForegroundColor Cyan
        Copy-Item -Path $MSUFile.FullName -Destination $TestPath -Force

        # Logging copying status
        Log-InstallationDetails -Message "Patch '$($MSUFile.Name)' copied to $Server."

        # Run DISM command to install the update
        $Result = Invoke-Command -ComputerName $Server -ScriptBlock {
            param($Cab)
            & cmd /c DISM /Online /Add-Package /PackagePath:$Cab /quiet /norestart
            return $LASTEXITCODE
        } -ArgumentList $MSUFile.FullName

        if ($Result -eq 0) {
            Write-Host "Patch $($MSUFile.Name) installed successfully on $Server." -ForegroundColor Green
            Log-InstallationDetails -Message "Patch $($MSUFile.Name) installed successfully on $Server."
        } elseif ($Result -eq 3010) {
            Write-Host "Patch $($MSUFile.Name) installation requires reboot on $Server." -ForegroundColor Yellow
            Log-InstallationDetails -Message "Patch $($MSUFile.Name) installation requires reboot on $Server."
        } else {
            if ($LASTEXITCODE -eq 87) {
                Write-Host "Patch $($MSUFile.Name) is not suitable for installation on $Server." -ForegroundColor Yellow
                Log-InstallationDetails -Message "Installation Failed on server $Server - Incompetent KB file"
            } else {
                Write-Host "Failed to install patch $($MSUFile.Name) on $Server." -ForegroundColor Red
                Log-InstallationDetails -Message "Failed to install patch $($MSUFile.Name) on $Server."
            }
        }

        Start-Sleep -Seconds 5
        Remove-Item -Path "$TestPath\*.*" -Force
    }
}

# Pause to keep the window open
Write-Host "Press Enter to exit..."
$null = Read-Host
