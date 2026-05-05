# Middleware pilot runbook — EZLynx → staging (no production Proposal Ledger)

**Goal:** One reliable **EZLynx → staging** path using Zapier, **without** writing to the production Proposal Ledger Sheet or modifying [`index.html`](../../../index.html).

Choose **one** primary spine:

- **A (recommended for fastest pilot):** Zapier → **Google Sheets** (new workbook — staging only).
- **B:** Zapier → **Webhooks by Zapier** → HTTPS endpoint (Supabase Edge Function, Cloudflare Worker, etc.) — see §Optional webhook.

---

## A. Google Sheets staging pilot

### 1. Create staging spreadsheet

1. In Google Drive, create a new spreadsheet named e.g. **`EZLynx_Staging_DO_NOT_SYNC`** (name reminds operators it is not production).
2. Open [`staging_sheet_headers.tsv`](staging_sheet_headers.tsv). Copy the header row into **row 1** (tab-separated columns paste correctly in Sheets).
3. **Share** only with operators who need QA; do **not** link this workbook to Proposal Ledger automation.

### 2. Build the Zap

1. Zapier → **Create Zap**.
2. **Trigger:** EZLynx → choose **`New Personal Lines Prospect`** (or **`New Personal Lines Prospect`** only—adjust if your pilot uses **Updated**).
3. Connect EZLynx per prompts; **Test trigger** with a test prospect in Sales Center if needed.
4. **Action:** Google Sheets → **Create Spreadsheet Row**.
   - Spreadsheet: select **staging** workbook.
   - Worksheet: first sheet (or dedicated tab).
   - Map columns using Zapier field picker:
     - **EventReceivedAt:** Zapier `{{zap_meta_human_now}}` or current time step if needed.
     - **TriggerName:** static text `New Personal Lines Prospect` (or exact trigger label).
     - **EZLynxRecordId:** map **Id** from EZLynx.
     - **ClientName:** combine First Name + Last Name (Formatter by Zapier optional).
     - **Email**, **Phone**, **Lead Source**, dates → map from EZLynx fields per [`03_field_mapping.md`](03_field_mapping.md).
     - **Carrier / Premium / Savings:** leave empty or map only if using Opportunity trigger.
     - **Status:** optional static `Staging` or blank.
     - **NextSteps:** optional operator instructions.
     - **ZapRunId:** `{{zap_meta_execution_id}}` if available in your Zapier version (or leave blank).
     - **ZapierPayloadJSON:** optional—use **Formatter → Utilities → Line Item to Text** or Code step to stringify full payload for debugging (advanced).

5. Turn Zap **On**.

### 3. Monitor

- **Zap History:** filter **Errors** daily during pilot.
- **Sheet:** confirm one row per expected Sales Center event; spot-check **Email** and **EZLynxRecordId**.

### 4. Pilot exit criteria

- At least **10** successful rows **or** 2 weeks without connector errors (whichever fits volume).
- Written list of **field gaps** (fields you wanted but EZLynx did not send).

---

## B. Optional webhook PoC (advanced)

Use when staging must land in **Postgres / Supabase** instead of Sheets.

1. Deploy an HTTPS endpoint that accepts **POST JSON** (Auth header or secret query param).
2. Zapier action: **Webhooks by Zapier** → **POST** to that URL with Raw JSON body from EZLynx trigger.
3. Store **full payload** + **received_at** + **dedupe key** (`Id` + trigger type).

**Local smoke test (Windows):** run [`Start-EZLynxWebhookSmokeServer.ps1`](../../../scripts/Start-EZLynxWebhookSmokeServer.ps1) and expose via **ngrok** or similar so Zapier can reach `https://…`; inspect logged JSON before deploying cloud.

---

## What this pilot explicitly does **not** do

- No merge into **Client Followups Tracker** Drive JSON ([`PROJECT_MAP.md`](../../../PROJECT_MAP.md)).
- No **automated matching** or dedupe across AMS and tracker.
- No writes to **production** Proposal Ledger Sheet ID used by the app.

Next steps after pilot success are gated by [`05_approval_gates_checklist.md`](05_approval_gates_checklist.md).
