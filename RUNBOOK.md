# RUNBOOK.md

How to start, stop, and recover the Alpha Omega Client Follow-Up Tracker locally.

> **Confirmation status:** The contents below are based on inspection of `index.html` (line counts and sizes were accurate for a snapshot taken on 2026-05-03; they drift as the file grows). **Canonical project root:** `c:\tracker-web`.

---

## Project root

- **Folder name:** `tracker-web` (directory on disk)
- **Absolute path:** `c:\tracker-web`
- **Entry file:** `index.html` at the project root

## Does `package.json` exist?

**No.** `index.html` is a single-file static web app. There is no `package.json`, no build step, no bundler, and no `node_modules`. All HTML, CSS, and JavaScript live inside `index.html`. External dependencies are loaded from CDNs at runtime (Google Identity Services script tag at the top of `<head>`).

If Cursor or `npm` reports "no package.json found" — that is **expected**. Do not run `npm init`. Do not introduce a build step without explicit approval.

## How to run the app locally

Because there is no build step, run it with any static file server from inside the project root.

**Option A — Python (recommended, no install needed on most systems):**

```bash
cd c:\tracker-web
python -m http.server 3000
```

Then open: `http://localhost:3000`

**Option B — Node `http-server` (if Python is unavailable):**

```bash
cd c:\tracker-web
npx http-server -p 3000 -c-1
```

The `-c-1` disables caching, which matters because you will edit `index.html` directly and want each refresh to pick up changes.

**Option C — VS Code "Live Server" extension:**

Right-click `index.html` → "Open with Live Server". Defaults to port 5500.

## URL to open

- Default: `http://localhost:3000`
- If port 3000 is busy: `http://localhost:5173` (then start server with `python -m http.server 5173`)
- VS Code Live Server: `http://127.0.0.1:5500/index.html`

## How to stop the server

- In the terminal running the server: press **Ctrl+C** (or **Cmd+C** on Mac).
- Confirm the prompt returns. The port is now free.

## How to restart the server

1. Stop with Ctrl+C.
2. Re-run the same `python -m http.server 3000` command from the project root.
3. Hard-refresh the browser tab: **Ctrl+Shift+R** (or **Cmd+Shift+R** on Mac) to bypass the browser cache.

## Important runtime caveat

`index.html` was written to run **inside Cowork mode** (the Claude desktop app). Specifically:

- Drive load/save (`driveLoad`, `driveSave`) call `window.cowork.callMcpTool(...)` — a function injected only by Cowork mode.
- The Drive prefix is hardcoded: `const DRIVE_PREFIX = "mcp__42601070-e4b2-40c7-a22b-e3309816434d__";` (line 5536 of `index.html`).

When you serve `index.html` from a plain static server in a regular browser tab, `window.cowork` will be **undefined**. Boot will fall back gracefully:

1. `driveLoad()` throws.
2. `readSnapshot()` reads `localStorage.getItem("alphaomega.tracker.snapshot.v1")`.
3. If a local snapshot exists, the app loads it and shows "Drive err · using local cache (N)" in the status pill.
4. If no snapshot, the app loads `SEED` data and disables further saves (`driveSaveBlocked = true`).

For real Drive sync, the app must be opened inside the Cowork desktop app — not just in Chrome.

The Google Sheets integration (Proposal Ledger) uses a **direct** `fetch` call against `sheets.googleapis.com` with the OAuth bearer token (see `fetchProposalLedgerSheetValues` at line 4933), so that path can work in a regular browser **provided** the user has signed in via Google Identity Services and granted `https://www.googleapis.com/auth/spreadsheets.readonly` scope (already in `GOOGLE_SCOPES` at line 4693).

**Production Sheet ID:** Alpha Omega CRM Data v2 is spreadsheet `17jqbpXOryykS9dwOxi_BBFaTNB1a4hJuI_AEESCAGE0` (same value as `PROPOSAL_LEDGER_SPREADSHEET_ID` in `index.html` around line 4769). This ID is the confirmed production Sheet—do not change the app constant unless production is intentionally migrated.

## Proposal Ledger workflow (Phase 5 — process discipline)

This is the **human + agent** checklist for proposal work. It is **not** implemented as buttons inside `index.html`; the CRM only **reads** the ledger (`spreadsheets.readonly`). Agents (Claude/Cowork) and operators must follow it so Sent rows can enrich reliably later.

**Step-by-step (do in order before closing a proposal task):**

1. **Build or revise** the client proposal (coverage, options, revisions).
2. **Confirm** carrier, annual premium, effective date, savings, and policy type **when known** (do not invent placeholders—see `AGENT_RULES.md` data integrity rules).
3. **Send or prepare** the proposal email.
4. **Create or update** the **Proposal Ledger** row in Google Sheets with all known columns (use the **27-column order** in `Alpha_Omega_CRM_Playbook.md`, subsection **Proposal Ledger Columns**). If the assistant cannot write to the Sheet, output a **paste-ready row** for Baruch instead—**never** skip this step silently (per `AGENT_RULES.md` rule 16).
5. **Attach references** in the ledger when available: proposal PDF link, spreadsheet/comparison link.
6. **Confirm CRM linkage:** structured ledger data is what the app uses first for boot-time enrichment (`enrichSentRowsFromProposalLedger`). More code-side matchers do not fix missing ledger rows.

**Paste-ready row hygiene:**

- Deliver paste-ready tab-separated rows inside a **fenced code block** (triple backticks) so tabs stay literal and **Client Email** is not auto-linked as markdown/mailto text in chat (see `AGENT_RULES.md` rule 17).
- **Prepared** proposals: leave **Sent Date** blank. Stamp **Sent Date** only when the proposal email is **actually sent**; align with **Sent** status (or equivalent) at that moment (see `AGENT_RULES.md` rule 18).

**CRM enrichment priority** (for awareness when drafting emails and filling the ledger): **1.** Proposal Ledger → **2.** CRM-readable lines in the email body → **3.** PDF-derived text as fallback → **4.** leave CRM field blank.

**CRM-readable lines** (include in proposal email body when drafting copy, when practical):

```text
Carrier total annual: $X
Effective date: YYYY-MM-DD
```

**Before finishing, confirm:** new vs revision vs sent; ledger row created/updated **or** paste row delivered; carrier; annual premium; effective date if known; sent date if emailed; Gmail subject if emailed; PDF/comparison links if available; **Notes** used for anything missing or uncertain.

See `PROJECT_MAP.md` (Phase 5) for status and scope. This repo does **not** add Sheets write APIs or MCP write automation unless explicitly approved in `AGENT_RULES.md` (forbidden actions).

## Troubleshooting

### "npm says package.json is missing"

This is expected. There is no `package.json` and no Node-based tooling in this project. Use `python -m http.server 3000` instead. If you want a Node-based server, use `npx http-server` directly without `npm install`.

### "localhost:3000 does not load"

1. Confirm the server is actually running — check the terminal for `Serving HTTP on 0.0.0.0 port 3000` or similar.
2. Confirm you started the server **from inside `c:\tracker-web`** (the project root). If you started it from the parent folder, the URL will load a directory listing instead of the app.
3. Try a different port: `python -m http.server 5173`, then open `http://localhost:5173`.
4. Stop and restart with Ctrl+C → re-run command.
5. If using VS Code Live Server, confirm the port in the bottom status bar.
6. Check the browser DevTools Network tab for failed requests.

### "Drive: empty · using local cache" appears in the header pill

This means `driveLoad()` failed. Common causes:

- Running the app in a regular browser instead of inside Cowork mode → `window.cowork` is undefined.
- Not signed in to Google → no `googleAccessToken`.
- The Drive file `Client Followups Tracker.json` does not exist in the user's Drive yet → first-time-ever boot.

The app will continue with cached data; no data loss.

### "Drive: sync failed" banner appears

`doSave()` caught an error. Check the browser console for the underlying message. The banner suggests using "Download CSV" as a backup — that path is independent of Drive.

### Sheet (Proposal Ledger) read returns nothing

- Confirm you are signed into Google in the same browser tab.
- Confirm the OAuth consent dialog granted the Sheets readonly scope (re-prompt may be needed if the scope was added after first sign-in).
- Confirm the hardcoded `PROPOSAL_LEDGER_SPREADSHEET_ID` at `index.html:4769` still matches the **Production Sheet ID** documented earlier in this runbook—do not change the constant unless production is intentionally migrated.
- Confirm the tab is named exactly `Proposal Ledger` (case-sensitive in the API call).

### Browser shows old version after editing `index.html`

Hard-refresh: Ctrl+Shift+R / Cmd+Shift+R. If still stale, open DevTools → Network → check "Disable cache" (only effective while DevTools is open).

## What you should test after every change

Before declaring a phase complete, smoke-test:

1. App loads without a blank white page.
2. Header pill shows a Drive status (any state — "synced", "loading", "err").
3. Pipeline view shows client cards (or the seed data if no Drive load).
4. Inbox view loads.
5. Tasks view loads.
6. No red errors in the browser DevTools console.
7. Sidebar nav switching between Pipeline / Inbox / Tasks works.
