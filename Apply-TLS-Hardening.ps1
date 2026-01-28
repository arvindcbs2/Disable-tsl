# ===============================
# Windows Server 2016 TLS Hardening
# Backup + Apply Script
# ===============================

$BasePath   = "C:\SecurityHardening"
$BackupPath = "$BasePath\Backup"
$LogPath    = "$BasePath\Logs"
$LogFile    = "$LogPath\TLS_Hardening.log"

# Create directories
New-Item -ItemType Directory -Force -Path $BackupPath, $LogPath | Out-Null

Function Write-Log {
    param ($Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -Append $LogFile
}

Write-Log "==== TLS Hardening STARTED ===="

# -------------------------------
# BACKUP EXISTING SETTINGS
# -------------------------------

Write-Log "Backing up SCHANNEL protocol registry keys"
reg export "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" `
    "$BackupPath\SCHANNEL_Protocols_Backup.reg" /y

Write-Log "Backing up HTTP Parameters"
reg export "HKLM\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" `
    "$BackupPath\HTTP_Parameters_Backup.reg" /y

# Snapshot for audit
Get-ItemProperty `
  "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Recurse `
  | Out-File "$BackupPath\Snapshot.txt"

Write-Log "Registry backup completed"

# -------------------------------
# APPLY TLS HARDENING
# -------------------------------

$Protocols = @(
    "TLS 1.0",
    "TLS 1.1",
    "TLS 1.2"
)

foreach ($Protocol in $Protocols) {
    $ServerKey = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$Protocol\Server"
    New-Item -Path $ServerKey -Force | Out-Null
}

# Disable TLS 1.0 & 1.1
Set-ItemProperty -Path "...TLS 1.0\Server" -Name Enabled -Type DWord -Value 0
Set-ItemProperty -Path "...TLS 1.0\Server" -Name DisabledByDefault -Type DWord -Value 1

Set-ItemProperty -Path "...TLS 1.1\Server" -Name Enabled -Type DWord -Value 0
Set-ItemProperty -Path "...TLS 1.1\Server" -Name DisabledByDefault -Type DWord -Value 1

# Enable TLS 1.2
Set-ItemProperty -Path "...TLS 1.2\Server" -Name Enabled -Type DWord -Value 1
Set-ItemProperty -Path "...TLS 1.2\Server" -Name DisabledByDefault -Type DWord -Value 0

Write-Log "TLS protocol configuration applied"

# -------------------------------
# REMOVE SERVER HEADER
# -------------------------------

Set-ItemProperty `
 "HKLM:\SYSTEM\CurrentControlSet\Services\HTTP\Parameters" `
 -Name DisableServerHeader `
 -Type DWord `
 -Value 1

Write-Log "Server header disabled via HTTP.sys"

Write-Log "==== TLS Hardening COMPLETED ===="
Write-Host "Changes applied successfully. REBOOT REQUIRED."
