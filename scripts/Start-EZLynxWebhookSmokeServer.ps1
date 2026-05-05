<#
.SYNOPSIS
  Minimal HTTP listener for local EZLynx/Zapier webhook smoke tests (POST body logged as JSON lines).

.DESCRIPTION
  Listens on http://127.0.0.1:8787/ezlynx/ingest and appends each request body to a log file.
  Use with ngrok (or similar) to give Zapier "Webhooks by Zapier" a public URL during pilot.
  Do not expose to the internet without TLS and authentication in production.

.PARAMETER Port
  TCP port (default 8787).

.PARAMETER LogPath
  Path to append JSON lines (default: EZLynx-webhook-smoke.log in temp).

.EXAMPLE
  .\Start-EZLynxWebhookSmokeServer.ps1
#>
param(
  [int]$Port = 8787,
  [string]$LogPath = (Join-Path $env:TEMP "EZLynx-webhook-smoke.log")
)

$prefix = "http://127.0.0.1:$Port/ezlynx/ingest/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
try {
  $listener.Start()
} catch {
  Write-Error "Failed to start listener on $prefix : $_"
  exit 1
}

Write-Host "Listening on $prefix"
Write-Host "POST JSON payloads will append to: $LogPath"
Write-Host "Press Ctrl+C to stop."

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $req = $ctx.Request
  $res = $ctx.Response
  $res.Headers.Add("Content-Type", "application/json; charset=utf-8")
  try {
    $reader = New-Object System.IO.StreamReader($req.InputStream, $req.ContentEncoding)
    $body = $reader.ReadToEnd()
    $reader.Close()
    $entry = [ordered]@{
      receivedAtUtc = (Get-Date).ToUniversalTime().ToString("o")
      method        = $req.HttpMethod
      path          = $req.Url.PathAndQuery
      remote        = $req.RemoteEndPoint.ToString()
      body          = $body
    }
    $line = ($entry | ConvertTo-Json -Compress -Depth 20)
    Add-Content -Path $LogPath -Value $line -Encoding UTF8
    $msg = '{"ok":true}'
    $buf = [System.Text.Encoding]::UTF8.GetBytes($msg)
    $res.StatusCode = 200
    $res.OutputStream.Write($buf, 0, $buf.Length)
  } catch {
    $err = '{"ok":false}'
    $buf = [System.Text.Encoding]::UTF8.GetBytes($err)
    $res.StatusCode = 500
    $res.OutputStream.Write($buf, 0, $buf.Length)
  } finally {
    $res.OutputStream.Close()
  }
}
