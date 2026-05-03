# Alpha Omega CRM — Claude / agent guidance

## Project identity

- **Canonical project root:** `c:\tracker-web`
- **Canonical playbook:** `c:\tracker-web\Alpha_Omega_CRM_Playbook.md`

## Evidence and memory

- **Read actual files** before making claims about repo contents, docs, or UI.
- **Do not** rely on remembered “Section 9 / Section 10” or other historical playbook structure—open the playbook and verify.

## Change boundaries (unless explicitly approved for a later phase)

- **Do not** edit `index.html` without explicit human approval for that change.
- **Do not** add **matching logic** without explicit approval.
- **Do not** add **Google Sheets write logic** without explicit approval.
- **Do not** change CRM product behavior when the task is documentation, audit, or planning-only.

## Proposal Ledger

- The **Proposal Ledger** is the structured **source of truth** for proposals.
- Every **new, revised, prepared, or sent** proposal must **create/update a Proposal Ledger row** **or** output a **paste-ready tab-separated row** with **all 27 columns** (per project/playbook definitions).
- **Unknown fields** stay **blank**; **missing information** goes in **Notes**.

## Specialized agents

See `.claude/agents/` for role-specific instructions:

- `crm-docs-guardian.md` — documentation consistency and staleness (no app code edits).
- `proposal-ledger-auditor.md` — ledger discipline and 27-column TSV readiness (no Sheets writes without approval).
- `crm-code-reviewer.md` — read-only code review (`index.html` edits only if explicitly approved later).
- `ui-polish-planner.md` — UI improvement plans only (no UI edits yet).
