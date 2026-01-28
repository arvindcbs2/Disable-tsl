# ===============================
# TLS Hardening Rollback Script
# ===============================

$BasePath   = "C:\SecurityHardening\Backup"
$LogFile    = "C:\SecurityHardening\Logs\TLS_Hardening.log"

Function Write-Log {
    param ($Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -Append $LogFile
}

Write-Log "==== TLS HARDENING ROLLBACK STARTED ===="

if (Test-Path "$BasePath\SCHANNEL_Protocols_Backup.reg") {
    reg import "$BasePath\SCHANNEL_Protocols_Backup.reg"
    Write-Log "SCHANNEL protocol registry restored"
} else {
    Write-Log "ERROR: SCHANNEL backup not found"
}

if (Test-Path "$BasePath\HTTP_Parameters_Backup.reg") {
    reg import "$BasePath\HTTP_Parameters_Backup.reg"
    Write-Log "HTTP Parameters restored"
} else {
    Write-Log "ERROR: HTTP Parameters backup not found"
}

Write-Log "==== TLS HARDENING ROLLBACK COMPLETED ===="
Write-Host "Rollback completed successfully. REBOOT REQUIRED."
