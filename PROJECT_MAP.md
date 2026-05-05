# PROJECT_MAP.md

A map of the Alpha Omega Client Follow-Up Tracker codebase as it exists today. Anchor points use line numbers from the `index.html` snapshot reviewed on 2026-05-03 (10,529 lines, 444 KB). Line numbers will drift after edits — re-grep by function name when you patch.

> **Critical findings up front (read these before doing anything else):**
>
> 1. **Production Alpha Omega CRM Data v2 Sheet ID (confirmed).** `index.html:4769` sets `PROPOSAL_LEDGER_SPREADSHEET_ID = "17jqbpXOryykS9dwOxi_BBFaTNB1a4hJuI_AEESCAGE0"`, the active production Google Sheet. If any older external playbook or note still lists a different Sheet ID, treat it as obsolete—production is `17jqbpXOryykS9dwOxi_BBFaTNB1a4hJuI_AEESCAGE0`.
>
> The active production Alpha Omega CRM Data v2 Sheet ID has been confirmed as 17jqbpXOryykS9dwOxi_BBFaTNB1a4hJuI_AEESCAGE0. Do not change the app constant unless the production Sheet is intentionally migrated.
>
> 2. **Phase 4 (Proposal Ledger read-only integration) is largely already built.** `enrichSentRowsFromProposalLedger()` exists at `index.html:~10116` and runs on boot at ~10590. **Phase 4A** (`[premium-ledger-debug]` via `DEBUG_PROPOSAL_LEDGER` / `emitProposalLedgerDebug`) and **Phase 4B** (blank `Carrier` fill from ledger `out.carrier` on match) are implemented — see Proposal Ledger section below. Matching remains Thread ID → Email → Client Name + Carrier; Sent Date ±14, Property Address + Carrier, and Gmail Subject matching are still deferred. The OAuth scope `https://www.googleapis.com/auth/spreadsheets.readonly` is already in `GOOGLE_SCOPES` (line 4696). Agent-facing truth for roots, approval gates, and Proposal Ledger discipline lives in **`CLAUDE.md`**, **`AGENT_RULES.md`**, **`RUNBOOK.md`**, and **`Alpha_Omega_CRM_Playbook.md`**—read those files on disk; do not assume structure from an unstated longer external playbook.
>
> 3. **Google Calendar task sync is now present in Tasks view.** The app reuses Google Identity Services token flow and includes `https://www.googleapis.com/auth/calendar.events` in `GOOGLE_SCOPES`; task records now carry `calendar_sync` metadata and support Link/Sync/Unlink + Pull sync actions in Tasks view.
>
> 3. **The app uses Cowork MCP for Drive, not direct Google Drive API.** `driveLoad`/`driveSave` call `window.cowork.callMcpTool(...)`. Running `index.html` in a plain browser tab without Cowork mode will degrade to localStorage-cache mode. See RUNBOOK.md.

---

## Main files

```
tracker-web/          ← on disk: c:\tracker-web
└── index.html        ← single-file SPA: HTML + CSS + JS (10,529 lines)
```

That is the entire app. There is no `package.json`, no build system, no separate JS/CSS files, no images on disk (assets are inline or remote), no submodules. Any future split into multiple files is an explicit refactor and out of scope for the current documented project phases.

## App entry point

The boot sequence is an immediately-invoked async function at the bottom of `index.html` (starts around line 10436, ends at line 10527). High-level boot order:

1. `setDrive("Drive: connecting…", "")` and `setGmail("Gmail: idle", "")` — initialize header status pills.
2. `await driveLoad()` — try to fetch `Client Followups Tracker.json` from Drive via Cowork MCP.
3. **On success:** hydrate `model` (clients) and `tasks` from the JSON; backfill legacy `Date Bound` for Bound clients; call `writeSnapshot(...)` to update local cache.
4. **On Drive empty:** `readSnapshot()` from `localStorage`. If found, hydrate from cache and set `driveSaveBlocked = true`.
5. **On both missing:** load `SEED` (built-in demo data), `driveSaveBlocked = true`.
6. **On Drive throw:** same as Drive empty path.
7. `renderFilters(); renderStats(); renderApp();` — first paint.
8. `await enrichSentRowsFromProposalLedger();` — Sheet enrichment (Phase 4 logic, already built).
9. `renderStats(); renderApp();` — re-paint after enrichment.
10. `checkAllReplies();` — Gmail polling for reply detection.
11. `discoverNewClients();` — scan sent mail for new proposals not in tracker.

## Global state overview

Defined inside the main IIFE scope:

| Variable | Line | Purpose |
|---|---|---|
| `model` | 6366 | `let model = []` — array of client/pipeline rows. Each row has the fields listed in `FIELDS` plus a `Log` array. |
| `tasks` | 6367 | `let tasks = []` — array of task records produced by `createTaskRecord`. |
| `currentView` | 6374 | `let currentView = "pipeline"` — one of `"pipeline"`, `"inbox"`, `"tasks"`. Drives sidebar styling and `body[data-view=...]` CSS selectors. |
| `processedInboxThreads` | 4759 | Top-level. Gmail thread IDs already classified by Inbox. Persisted in snapshot. |
| `proposalLedgerCache` | 4771 | Top-level. `{ values, fetchedAt }` in-memory cache of Sheet rows. |
| `googleAccessToken` | 4699 | Top-level. Bearer token from Google Identity Services. |
| `googleTokenClient` | 4700 | Top-level. GIS token client instance. |
| `tasksViewMode` | 6395 | `"list"` or `"board"` toggle for Tasks view. |
| `tasksUiState` | 6402 | Tasks page UI state (selected task, filters, etc.). |
| `inboxTriageState` | (near 7245) | Inbox triage modal state. |
| `driveSaveBlocked` | (set on cache fallback) | When `true`, `queueSave` is suppressed to avoid clobbering Drive with cache contents. |

### Important constants

| Constant | Line | Value |
|---|---|---|
| `FIELDS` | 5521 | `["Client","Carrier","Premium","Savings","Date Sent","Status","Last Contact","Next Follow-Up","Email","Phone","Quote Number","Renewal Date","Date Bound","Lead Source","Notes"]` |
| `LOG_KEY` | 5522 | `"Log"` — name of the per-row activity log array. |
| `TRACKER_TITLE` | 5529 | `"Client Followups Tracker.json"` — Drive file name (searched by title prefix). |
| `DRIVE_PREFIX` | 5536 | `"mcp__42601070-e4b2-40c7-a22b-e3309816434d__"` — Cowork MCP tool prefix for Drive. |
| `SEED` | 5543 | Hardcoded demo client array used only when both Drive and snapshot are empty. |
| `GOOGLE_CLIENT_ID` | 4692 | OAuth client ID. |
| `GOOGLE_SCOPES` | 4693–4698 | Drive (full), Gmail (modify), Sheets (readonly), Calendar events. |
| `PROPOSAL_LEDGER_SPREADSHEET_ID` | 4769 | **`17jqbpXOryykS9dwOxi_BBFaTNB1a4hJuI_AEESCAGE0`** — confirmed production Sheet; see critical note above. |
| `PROPOSAL_LEDGER_TAB` | 4770 | `"Proposal Ledger"` |

## Drive JSON load/save flow

**Load — `driveLoad()` at `index.html:5983`:**

1. `driveSearchLatest()` (line 5974) calls `window.cowork.callMcpTool(DRIVE_PREFIX + "search_files", { query: "title contains 'Client Followups Tracker'", pageSize: 50 })`.
2. Filters results to titles starting with `"Client Followups Tracker"`, sorts by `modifiedTime` descending, returns the newest.
3. Calls `download_file_content` for that file ID, base64-decodes, JSON-parses.
4. Returns `{ clients, tasks, file, migratedFromOldFormat }`. Old format (top-level array) is detected and flagged.

**Save — `driveSave(clients, taskRecords)` (search `async function driveSave` in `index.html`):**

1. Strips each row to `FIELDS` plus `Log` plus a sanitized **`clientDocs`** array (pinned `https` links: label, url, `addedAt`). Other row keys (e.g. `_gmail`, ledger display cache) are not persisted by design.
2. Wraps in `{ version: 2, clients, tasks, updated_at }` envelope.
3. Base64-encodes and calls `create_file` (which Drive treats as a new revision because of the title match).

**Save scheduling — `queueSave` / `doSave` at line 6016:**

- `queueSave()` debounces saves with a 1500 ms timer.
- `doSave()` guards against concurrent saves with `saveInFlight`/`pendingSave`.
- On success: `writeSnapshot()` updates `localStorage` mirror.
- On failure: `setDrive("Drive: sync failed", "err")` and a banner.

**Snapshot (local cache):**

- `readSnapshot()` at line 4731 — reads `localStorage.getItem("alphaomega.tracker.snapshot.v1")`.
- `writeSnapshot(clients, threads, taskRecords)` at line 4755 — writes the same key.
- Snapshot is the boot fallback when Drive is unavailable.

## Gmail auth/sync flow

**Auth — `initGoogleAuth()` at line 4702:**

- Loads Google Identity Services script (from `<head>`).
- Initializes `googleTokenClient` with the three scopes.
- Token callback sets `googleAccessToken` and resolves `_tokenWaiter` if anything was awaiting it.
- `waitForGoogleToken()` at line 4762 — promise that resolves when a token is present.

**Reading messages — direct Gmail REST calls:**

- `gmailThreadToShape(t)` at line 5287 — strips a Gmail thread API response into a normalized shape.
- `gmailThreadToShapeFull(t, auth)` at line 5322 — same but resolves inline CID images and HTML bodies.
- `gmailResolveInlineCidHtml(m, auth)` at line 5262 — fetches inline image attachments and rewrites `cid:` references to data URLs.
- `gmailCollectTextBodies`, `gmailCollectAttachmentNames`, `gmailCollectPdfAttachmentRefs` — body and attachment helpers.

**Sending and drafting:**

- `buildRFC2822(args)` at line 5356 — assembles a MIME message.
- AI-drafted reply uses a Cloudflare Worker proxy: `https://tracker-claude-proxy.tracker-claude-proxy.workers.dev` (line 5376) for Claude API calls. Outbound Gmail send uses standard Gmail REST.

## Inbox flow

- View entry: `currentView === "inbox"` triggers Inbox-specific UI.
- `loadInboxFromServer(forceRefresh)` at line 6862 — fetches recent threads, runs them through `gmailThreadToShape`, populates the Inbox list. Guards with `if (currentView !== "inbox") return;` so stale fetches don't paint the wrong view.
- `renderInbox()` at line 6887 — paints the Inbox list and the active thread reading pane.
- Inbox triage state is held in `inboxTriageState` (around line 7245).
- HTML email rendering: `collapseQuotedAndSignaturesInHtml(htmlStr)` at line 5037 — collapses Outlook/Gmail quoted reply blocks and `--` signature blocks into `<details>` toggles.

## Pipeline flow

- View entry: `currentView === "pipeline"` (default).
- Render: `renderApp()` at line 7879 — top-level paint coordinator (toggles header buttons, sub-views).
- `renderGrid()` at line 9151 — paints the client card grid for the Pipeline view.
- `renderStats()` and `renderFilters()` — stats bar and filter controls.
- Each card is built from a `model[i]` row using `FIELDS` and `Log` entries.
- Status values include `"Sent"`, `"Bound"`, etc. Filter and counts derive from `Status`.

## Tasks flow

- View entry: `currentView === "tasks"`.
- `renderTasksPage()` at line 8490 — paints the Tasks view.
- Two view modes via `tasksViewMode`: `"list"` and `"board"` (Kanban-like).
- Task records are normalized through `createTaskRecord` (used in load and save paths).
- `tasksUiState` (line 6402) holds selected task, filters, and other Tasks-page UI state.
- Task records now include a `calendar_sync` object (`event_id`, `calendar_id`, push/pull timestamps, state).
- Task rows and detail panel now expose Calendar controls: `Link Calendar`, `Sync`, `Unlink`; header includes `Pull Calendar`.
- Reconciliation behavior is timestamp-based (last-write-wins): pull applies event fields only when Google Calendar `event.updated` is newer than CRM `task.updated_at`.

## Sent-proposal discovery flow

- `discoverNewClients()` at line 10166 — runs on boot (line 10526) and on demand.
- Calls Gmail (via Cowork MCP tool — `GMAIL_TOOL`) with the query `from:bclawson@alphaomegainsurance.net subject:"proposal" newer_than:30d`.
- For each sent thread that doesn't already match a row in `model`, builds a "candidate" with email, name, carrier, sent date, and surfaces them in a banner: `"Found N sent proposals not in your tracker."`.
- `bindDiscoverHandlers()` at line 10252 — wires the discover modal: each candidate row has accept/dismiss buttons (`btn.dataset.candIdx`).
- Acceptance creates a new `model` row with Status `"Sent"`, then `queueSave()`.

## Proposal Ledger Google Sheet integration plan (current state)

**Current implementation (already wired up — do not rebuild):**

- Constants: `PROPOSAL_LEDGER_SPREADSHEET_ID` (line 4769), `PROPOSAL_LEDGER_TAB` (line 4770).
- Cache: `proposalLedgerCache` at line 4771 — in-memory `{ values, fetchedAt }`.
- Header parsing: `normalizeProposalLedgerHeaderKey` (4773), `findProposalLedgerColumn` (4780), `buildProposalLedgerColumnMap` (4798).
- Date parsing: `parseProposalLedgerDateToIso` (4829), `pickLedgerRenewalOrEffective` (4850).
- Quote number normalizer: `normalizeQuoteNumberFromLedger` (4857).
- Row → output conversion: `proposalLedgerRowToOut` (4864).
- Pipeline row → Sheet row matcher: `findLedgerSheetRowForPipelineRow` (4898). Match priorities currently implemented:
  1. Thread ID
  2. Email
  3. Client Name + Carrier
- Sheet fetch: `fetchProposalLedgerSheetValues()` (4933) — direct `fetch` to `sheets.googleapis.com/v4/spreadsheets/{id}/values/'Proposal Ledger'!A1:ZZ5000` with `Authorization: Bearer <googleAccessToken>`.
- Per-email lookup: `getProposalLedgerRowByEmail(email)` (4950) — used during proposal acceptance.
- **Boot-time enrichment: `enrichSentRowsFromProposalLedger()` (~10116)** — iterates `model`, for each row where `Status === "Sent"` and any of Premium/Savings/effective field/Quote Number/**Carrier** is blank, calls `findLedgerSheetRowForPipelineRow`, fills blanks only (including **Carrier** from `out.carrier` only when `row.Carrier` is blank — existing values are never overwritten), appends a log entry with `meta: { source: "proposal-ledger-refresh", matchKind, fields }`. Triggers `queueSave()` if anything changed. Runs once on boot at ~10590.

**Phase 4A — Proposal Ledger debug logging (implemented):**

- `DEBUG_PROPOSAL_LEDGER` lives with the other PDF debug flags at `index.html:~9859`.
- `emitProposalLedgerDebug(diag)` at ~10002 — returns immediately when the flag is false; builds a whitelisted `safe` object (no raw sheet dumps, no email bodies); emits `console.debug("[premium-ledger-debug]", safe)`.
- `enrichSentRowsFromProposalLedger` emits `[premium-ledger-debug]` for: **sheet load** (`stage: "sheet_loaded"`, including `sheetLoaded` / `sheetRowCount` and reasons such as fetch failure or empty values), **Sent-row candidates** that need ledger fields (`stage: "sent_row"` with `candidateEmail`, `candidateName`, `carrier`, `threadId`, match flags, `reasonIfNoMatch`, etc.), and **enrich errors** (`stage: "enrich_error"` with `errorMessage`).
- `getProposalLedgerRowByEmail` (~4950) still ends in a **silent `catch`** (returns empty fields). That path was **intentionally left out of Phase 4A**; debug visibility is scoped to the boot enrichment path only.

**Phase 4B — Blank Carrier enrichment (implemented):**

- On a ledger row match, `enrichSentRowsFromProposalLedger` sets `row.Carrier` from `out.carrier` (`proposalLedgerRowToOut`) **only** when `row.Carrier` is blank, using the same trimmed-string pattern as Premium/Savings/Quote Number.
- **Non-blank** pipeline `Carrier` values are **not** overwritten. `"Carrier"` is included in `filledLabels` and the same activity-log / `queueSave()` path as other ledger-filled fields.

**Deferred matching and enrichment gaps (repo-tracked):**

The table below states **what the code does today** versus **behaviors still deferred** in `index.html`. Process rules (ledger-first, paste-ready rows, blank vs. Notes) are canonical in **`CLAUDE.md`**, **`AGENT_RULES.md`** (rule 16), **`RUNBOOK.md`**, and **`Alpha_Omega_CRM_Playbook.md`** (including the **Proposal Ledger Columns** order).

| Target / expectation | Current code | Gap |
|---|---|---|
| Match priority 1: Gmail Thread ID | ✅ Implemented | — |
| Match priority 2: Client Email | ✅ Implemented | — |
| Match priority 3: Client Name + Carrier | ✅ Implemented | — |
| Match priority 4: Property Address + Carrier | ❌ Still deferred | `model` rows do not currently expose a property-address field; would require schema check. |
| Match priority 5: Sent Date ±14 days + name/email | ❌ Still deferred | Add as a tie-breaker. |
| Match priority 6: Gmail Subject | ❌ Still deferred | Add as a fallback. |
| Enrich Carrier when blank | ✅ Implemented (Phase 4B) | After match, `out.carrier` is applied only when `row.Carrier` is blank; existing values unchanged. |
| Debug log `[premium-ledger-debug]` with safe fields | ✅ Implemented (Phase 4A) | `DEBUG_PROPOSAL_LEDGER` ~9859; `emitProposalLedgerDebug` ~10002; `enrichSentRowsFromProposalLedger` logs sheet load, Sent-row candidates, and enrich errors. Row activity log entries unchanged. `getProposalLedgerRowByEmail` still silent-catch by design (out of Phase 4A scope). |
| Source priority order Sheet → Email body → PDF → blank | ⚠️ Partial | Sheet path exists. Email body and PDF fallbacks exist independently; their ordering relative to Sheet for **new** discoveries needs auditing in `discoverNewClients` and the candidate-accept flow. |

**Outstanding code work** on this surface should be treated as **audit and patch remaining enrichment gaps** in the existing implementation (Sheet ID is aligned with production—see critical note above). Phase 4A (debug) and Phase 4B (blank Carrier) are done. **Matching** is still Thread ID → Email → Client Name + Carrier only; Property Address + Carrier, Sent Date ±14, and Gmail Subject remain deferred per the table above.

### Phase 5 — Proposal Ledger process discipline

- **Status:** In progress (operational / agent discipline—not a CRM UI or `index.html` feature flag).
- **Purpose:** Before investing in more **matching** logic in code, every real proposal workflow must **consistently create or update** a Proposal Ledger row. The CRM read-only enrichment path can only fill **Sent** pipeline rows when structured values exist in the Sheet; matchers cannot recover data that was never logged.
- **Scope — in:** Agents and operators must ensure every **new, revised, sent, or prepared** proposal results in a ledger row **or** a **paste-ready** row for Baruch; missing fields stay blank with explanations in **Notes**; no silent failure; do not treat PDF as the primary premium source when email/ledger text is available. Detailed checklist and steps live in **`RUNBOOK.md`** (Proposal Ledger workflow); the permanent agent rule lives in **`AGENT_RULES.md`** (rule 16).
- **Scope — out:** Phase 5 does **not** change CRM UI behavior, does **not** add new enrichment matchers in `index.html`, does **not** add Google Sheets MCP, and does **not** add Sheets **write** APIs or append/update calls (still forbidden per `AGENT_RULES.md` unless explicitly approved).
- **Next after Phase 5:** Audit live proposal workflows to verify ledger rows are created consistently; only then prioritize additional matchers (Property Address + Carrier, Sent Date ±14, Gmail Subject, etc.).

## Known fragile areas

1. **Sheet ID is hardcoded in two places** (the constant at 4769; any future write-back will hardcode it again). Centralize before adding write-back.
2. **`window.cowork` dependency.** Drive load/save and Gmail discovery rely on Cowork MCP. The app has no Drive REST fallback. Outside Cowork mode, you lose Drive sync entirely.
3. **PDF extraction path** (`buildSanitizedPdfSnippetAroundTotalOrAnnual` at 9941, `emitPdfPremiumDebug` near 10080) — **`AGENT_RULES.md`** (data integrity rules) and **`RUNBOOK.md`** treat PDF-derived text as fragile fallback. Treat it as last-resort enrichment only.
4. **Cloudflare Worker proxy for Claude API** (`https://tracker-claude-proxy.tracker-claude-proxy.workers.dev`, line 5376). External dependency with no documented retry/auth posture in this file.
5. **Snapshot/Drive divergence.** When `driveSaveBlocked` is set (cache fallback), edits accumulate in `model` but are never flushed to Drive. A subsequent successful Drive load could overwrite them. There is no merge logic.
6. **Inbox view-guard race.** `loadInboxFromServer` returns early if `currentView !== "inbox"`. If the user switches views during a long fetch, the result is silently dropped. Acceptable but worth knowing.
7. **`backfill Date Bound`** runs unconditionally on every Drive load (line 10451). It mutates `model` and queues a save. This is intentional but means the first boot after a code change can produce surprise saves.
8. **Single 10,529-line `index.html`.** Any agent trying to "clean up" by splitting files is doing a refactor, not a feature. Forbid until explicitly approved.

## EZLynx integration (documentation only)

- **Status:** No EZLynx code paths in `index.html`. Planning and pilot runbooks live under **`docs/integrations/ezlynx/`** (see **`README.md`** there): vendor discovery packet, Zapier trigger inventory, field-mapping contract, middleware pilot runbook, approval-gates checklist, staging Sheet header TSV, and optional **`scripts/Start-EZLynxWebhookSmokeServer.ps1`** for local webhook smoke tests.
- **Guardrails:** Follow **`CLAUDE.md`** before editing `index.html`, adding matching logic, or automating Google Sheets writes (including production Proposal Ledger).
