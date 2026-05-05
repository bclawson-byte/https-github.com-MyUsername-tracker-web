#Requires -Version 5.1
$ErrorActionPreference = "Stop"
$TaskName = "AlphaOmega-TrackerWeb-Localhost3000"
$existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if (-not $existing) {
  Write-Host "Nothing to do: task '$TaskName' is not installed."
  exit 0
}
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
Write-Host "OK: Removed scheduled task '$TaskName'."
