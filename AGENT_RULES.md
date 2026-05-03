# AGENT_RULES.md

Rules every agent — Cursor, Claude Code, ChatGPT, or any other assistant — must follow when working in this repo. Owner: Baruch (product owner and final approver).

These rules exist because this app is a single 10,529-line `index.html` with multiple intertwined integrations (Drive via Cowork MCP, Gmail REST, Google Sheets REST, a Cloudflare Worker proxy, and a localStorage cache). One sloppy refactor can silently break a Drive sync, a reply detector, or an enrichment path. The cost of "while I'm in there" edits is high.

---

## Non-negotiables

1. **Inspect before editing.** Always read the relevant function(s) end-to-end before proposing any change. State the file, the function, and the line range you intend to touch in your plan. If you do not know which function to touch, ask before guessing.

2. **Show function names and line ranges before patching.** A patch proposal must specify: filename, function name(s), and the line range of each change. "I'll update the Sheet logic" is not a patch proposal. "I'll modify `findLedgerSheetRowForPipelineRow` at `index.html:4898–4930` to add a Property Address + Carrier match" is.

3. **One feature per patch.** If you find a second issue while implementing the first, write it down for a follow-up. Do not bundle. The user must be able to review one focused diff at a time.

4. **No broad refactors.** Renaming things, splitting `index.html` into multiple files, "modernizing" syntax, replacing libraries, reformatting whitespace, or adding a build step are all refactors. None are permitted unless the user explicitly asks for that specific refactor in the current message. "Cleanup" is not a license.

5. **Do not touch Gmail sync unless explicitly asked.** The Gmail surface includes: `initGoogleAuth`, `waitForGoogleToken`, `gmailThreadToShape*`, `gmailResolveInlineCidHtml`, `loadInboxFromServer`, `buildRFC2822`, `discoverNewClients`, `bindDiscoverHandlers`, `checkAllReplies`, the `GOOGLE_SCOPES` constant, the Cloudflare Worker proxy URL, and any code path that calls `gmail.googleapis.com`. If you are not asked, leave them alone.

6. **Do not touch Drive save/load unless explicitly asked.** The Drive surface includes: `driveLoad`, `driveSearchLatest`, `driveSave`, `queueSave`, `doSave`, `readSnapshot`, `writeSnapshot`, `TRACKER_TITLE`, `DRIVE_PREFIX`, `FIELDS`, `LOG_KEY`, the boot hydration block at lines 10436–10521, and the `driveSaveBlocked` flag.

7. **Do not touch Inbox / Pipeline / Tasks UI unless explicitly asked.** The UI surface includes: `renderApp`, `renderGrid`, `renderInbox`, `renderTasksPage`, `renderStats`, `renderFilters`, `inboxTriageState`, `tasksUiState`, the sidebar nav handlers around lines 7184–7196 and 7480–7730, and any CSS rule keyed off `body[data-view="..."]`.

8. **Always run a syntax/lint check after edits.** At minimum, open `index.html` in a browser after the patch and confirm: no parse errors in the console, the page paints, all three views load. If you have access to a linter or `node --check` workflow on the embedded JS, use it.

9. **Always show a focused diff before committing.** Either a unified diff or a side-by-side review must be presented to Baruch before the change is finalized. No "I'll just push it" workflow.

10. **Preserve working behavior over clever refactors.** If a function looks awkward but works, leave it. If you have a strong urge to "fix" something not in your task scope, write a TODO and move on.

---

## Data integrity rules

These rules protect the user's CRM data from silent corruption.

11. **Never overwrite manually entered CRM values.** Enrichment passes (Sheet, email body, PDF) must check that the target field is blank before writing. The current `enrichSentRowsFromProposalLedger` (`index.html:10090`) already does this — match its pattern: `if (!String(row.X || "").trim()) { ... }`.

12. **Never insert `N/A`, `undefined`, `null`, `"null"`, or guessed premium values.** If a source returns an empty/missing value, leave the field blank. Empty string is acceptable; placeholder strings are not.

13. **Never create duplicate client rows.** Discovery flows must dedupe by (Email) and by (Gmail Thread ID) before appending to `model`. Acceptance flows must check the existing list.

14. **Source priority for proposal data is fixed.** Sheet (Proposal Ledger) → Email body → PDF extraction → blank. Do not promote PDF above email body. Do not skip the Sheet check.

15. **Keep PDF extraction as fallback only.** The PDF path is fragile and known-noisy. Do not invest in it unless the Sheet and email body paths have already been ruled out for a specific case.

---

## Required process for every change

Follow this sequence for every patch proposal:

1. **Acknowledge scope.** State which phase of the playbook this work belongs to and confirm it is the current approved phase.
2. **Inspect.** Read the relevant code. State which functions and which line ranges you read.
3. **Plan.** State what you intend to change, in what function, at what line range, and what behavior should be preserved.
4. **Wait for approval.** Do not edit until Baruch says "approved" or equivalent.
5. **Patch.** Make the focused change. No drive-by edits.
6. **Diff.** Present the unified diff.
7. **Test.** Smoke-test Pipeline, Inbox, Tasks. Verify no console errors. Verify the specific behavior you changed.
8. **Summarize.** Report: files changed, functions touched, line ranges, what was deliberately not touched, any known follow-ups, how Baruch can verify.

---

## The universal checkpoint prompt

After every patch, before declaring the phase done, summarize:

1. Files changed
2. What was added
3. What was intentionally not touched
4. Any known issues
5. How to test this phase
6. Whether app behavior changed

If you cannot answer any of these clearly, the patch is not ready.

---

## Forbidden actions (do not do these without explicit, in-message approval)

- Add `package.json` or any build tooling.
- Add or remove an npm dependency.
- Split `index.html` into multiple files.
- Rename any constant in the FIELDS list.
- Change `TRACKER_TITLE` or the Drive search query (would orphan existing user data).
- Change `PROPOSAL_LEDGER_SPREADSHEET_ID` without an explicit, in-message request to migrate production Sheets (confirmed production ID: `17jqbpXOryykS9dwOxi_BBFaTNB1a4hJuI_AEESCAGE0`). The active production Alpha Omega CRM Data v2 Sheet ID has been confirmed as 17jqbpXOryykS9dwOxi_BBFaTNB1a4hJuI_AEESCAGE0. Do not change the app constant unless the production Sheet is intentionally migrated.
- Add a Sheets **write** scope or any code that calls `values.append` / `values.update`. Phase B work, not now.
- Add new top-level `<script src="...">` tags or new external CDN dependencies.
- Modify the Cloudflare Worker proxy URL or its request shape.
- Touch the OAuth `GOOGLE_SCOPES` array except to add a single specific scope explicitly requested.
- Wrap `index.html` in any framework (React, Vue, Svelte, etc.).
- Run `git push` to a remote without Baruch's confirmation.
- Reformat the file (Prettier, Black, etc.) — even unintentionally as part of an editor save action.

---

## Allowed actions (no special approval required, within current phase scope)

- Read any file in the repo.
- Run `git status`, `git diff`, `git log`.
- Open `index.html` in a browser to test.
- Search the codebase with `grep`, `rg`, or the IDE's search.
- Add `console.log` lines for debugging during development, **provided they are removed or guarded by a debug flag before the diff is finalized**.
- Add comments to clarify existing behavior (kept minimal — code that needs a comment to be understood may need a later refactor proposal, but propose, do not perform).

---

## How to handle disagreements with these rules

If you believe a rule is preventing the right outcome:

1. Stop the patch.
2. State which rule conflicts and why.
3. Propose a specific, narrow exception.
4. Wait for Baruch to approve the exception explicitly for this change.

Do not silently work around the rule. Do not assume Baruch will agree later.

---

## Why this file exists

Cursor, Claude Code, and other agents do not retain context between sessions. Without these written rules, every agent rediscovers the codebase, makes the same broad-refactor mistakes, and burns Baruch's time on cleanup. This file is the front door: read it first, every session.
