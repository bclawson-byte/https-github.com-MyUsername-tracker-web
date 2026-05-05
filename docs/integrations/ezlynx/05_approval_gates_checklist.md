# Approval gates — EZLynx ↔ tracker automation

**Reference:** [`CLAUDE.md`](../../../CLAUDE.md) and [`Alpha_Omega_CRM_Playbook.md`](../../../Alpha_Omega_CRM_Playbook.md).

This checklist records **explicit human approvals** before implementation work that would otherwise violate project guardrails. **Ticking a box requires a named approver and date** (fill in the table below).

---

## Gates

| # | Gate | What it unlocks | Approved | Approver | Date |
|---|------|-----------------|----------|----------|------|
| 1 | **Edit `index.html`** | UI or logic in the tracker app (EZLynx panel, import buttons, etc.) | ☐ | | |
| 2 | **Matching / dedupe logic** | Automated merge of EZLynx rows into tracker `model` by email/ID/fuzzy rules | ☐ | | |
| 3 | **Google Sheets write automation** | Zap/scripts that create/update **production** Proposal Ledger or other canonical Sheets | ☐ | | |

**Staging-only Sheets** (dedicated workbook named and isolated per [`04_middleware_pilot_runbook.md`](04_middleware_pilot_runbook.md)) are intended to stay **outside** gate 3 until you explicitly promote automation to production ledger tabs.

---

## Playbook reminder

- **Proposal Ledger:** 27-column discipline; unknown fields blank; no guessing ([`Alpha_Omega_CRM_Playbook.md`](../../../Alpha_Omega_CRM_Playbook.md)).
- **Secrets:** EZLynx and Zapier credentials **never** committed to git; use Zapier OAuth and secure vaults for any webhook secrets.

---

## Completion note

This document is **complete** when all planned phases requiring gates have either **sign-offs** or an explicit decision that the gate **does not apply** (document in Notes below).

**Notes:**
