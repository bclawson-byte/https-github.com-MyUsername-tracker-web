#Requires -Version 5.1
<#
  Registers a scheduled task so the tracker is served at http://localhost:3000/
  whenever you log on to Windows (no Cursor terminal needed).

  Run once from PowerShell:
    powershell -ExecutionPolicy Bypass -File "c:\tracker-web\scripts\Install-TrackerWeb-LogonServer.ps1"

  Remove with:
    powershell -ExecutionPolicy Bypass -File "c:\tracker-web\scripts\Uninstall-TrackerWeb-LogonServer.ps1"
#>
$ErrorActionPreference = "Stop"
$TaskName = "AlphaOmega-TrackerWeb-Localhost3000"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Get-PythonExe {
  foreach ($cmd in @("python", "py")) {
    $g = Get-Command $cmd -ErrorAction SilentlyContinue
    if (-not $g) { continue }
    if ($cmd -eq "py") {
      return @{ Exe = $g.Source; ArgsPrefix = @("-3") }
    }
    return @{ Exe = $g.Source; ArgsPrefix = @() }
  }
  return $null
}

$p = Get-PythonExe
if (-not $p) {
  throw "Python not found on PATH. Install Python or use Start-Tracker-Web.bat after fixing PATH."
}

$argList = $p.ArgsPrefix + @("-m", "http.server", "3000")
$arguments = ($argList | ForEach-Object {
  if ($_ -match '\s') { '"' + $_ + '"' } else { $_ }
}) -join " "

$action = New-ScheduledTaskAction -Execute $p.Exe -Argument $arguments -WorkingDirectory $RepoRoot
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 0)

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null
Write-Host "OK: Registered '$TaskName' (serves $RepoRoot on port 3000 at logon)."
Write-Host "Start it now without re-login: Start-ScheduledTask -TaskName '$TaskName'"
