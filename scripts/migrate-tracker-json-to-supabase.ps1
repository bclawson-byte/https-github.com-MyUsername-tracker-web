param(
  [Parameter(Mandatory = $true)]
  [string]$SupabaseUrl,

  [Parameter(Mandatory = $true)]
  [string]$ServiceRoleKey,

  [Parameter(Mandatory = $true)]
  [string]$AgencyId,

  [Parameter(Mandatory = $true)]
  [string]$JsonPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $JsonPath)) {
  throw "JsonPath not found: $JsonPath"
}

$raw = Get-Content -Path $JsonPath -Raw
$parsed = $raw | ConvertFrom-Json

$clients = @()
$tasks = @()

if ($parsed -is [System.Array]) {
  $clients = $parsed
  $tasks = @()
} else {
  $clients = @($parsed.clients)
  $tasks = @($parsed.tasks)
}

$headers = @{
  "apikey" = $ServiceRoleKey
  "Authorization" = "Bearer $ServiceRoleKey"
  "Content-Type" = "application/json"
}

function Invoke-SupabaseDelete {
  param([string]$Table)
  $uri = "$SupabaseUrl/rest/v1/$Table?agency_id=eq.$AgencyId"
  Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers | Out-Null
}

function Invoke-SupabaseInsert {
  param([string]$Table, [object]$Payload)
  if ($null -eq $Payload -or $Payload.Count -eq 0) { return }
  $uri = "$SupabaseUrl/rest/v1/$Table"
  $body = $Payload | ConvertTo-Json -Depth 20
  Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body | Out-Null
}

$clientRows = @()
for ($i = 0; $i -lt $clients.Count; $i++) {
  $row = $clients[$i]
  $clientRows += @{
    agency_id = $AgencyId
    sort_order = $i
    client_name = [string]$row.Client
    carrier = [string]$row.Carrier
    premium = [string]$row.Premium
    savings = [string]$row.Savings
    date_sent = [string]$row.'Date Sent'
    status = [string]$row.Status
    last_contact = [string]$row.'Last Contact'
    next_follow_up = [string]$row.'Next Follow-Up'
    email = [string]$row.Email
    phone = [string]$row.Phone
    quote_number = [string]$row.'Quote Number'
    renewal_date = [string]$row.'Renewal Date'
    date_bound = [string]$row.'Date Bound'
    lead_source = [string]$row.'Lead Source'
    notes = [string]$row.Notes
    activity_log = if ($row.Log) { $row.Log } else { @() }
    client_docs = if ($row.clientDocs) { $row.clientDocs } else { @() }
  }
}

$taskRows = @()
for ($i = 0; $i -lt $tasks.Count; $i++) {
  $task = $tasks[$i]
  $taskId = [string]$task.id
  if ([string]::IsNullOrWhiteSpace($taskId)) {
    $taskId = [string][guid]::NewGuid()
  }
  $taskRows += @{
    id = $taskId
    agency_id = $AgencyId
    sort_order = $i
    payload = $task
  }
}

Write-Host "Deleting existing rows for agency '$AgencyId'..."
Invoke-SupabaseDelete -Table "crm_tasks"
Invoke-SupabaseDelete -Table "crm_clients"

Write-Host "Inserting $($clientRows.Count) clients..."
Invoke-SupabaseInsert -Table "crm_clients" -Payload $clientRows

Write-Host "Inserting $($taskRows.Count) tasks..."
Invoke-SupabaseInsert -Table "crm_tasks" -Payload $taskRows

Write-Host "Migration complete."
