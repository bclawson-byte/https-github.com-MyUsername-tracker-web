# Alpha Omega CRM Playbook

## Phase 5 — Proposal Ledger discipline

Every **new**, **revised**, **prepared**, or **sent** insurance proposal must **create or update** a Proposal Ledger row **or** output a **paste-ready tab-separated row** with **all 27 columns in order**.

The **Proposal Ledger** is the structured **source of truth** for proposal **carrier**, **premium**, **savings**, **effective date**, **sent date**, **Gmail subject**, **Gmail thread ID**, **proposal PDF link**, **spreadsheet/comparison link**, and **notes** (and the other ledger columns as applicable).

If **direct Google Sheets writing** is unavailable, **Claude/Cowork must provide a paste-ready row** before ending the task.

**Do not guess** missing information. Leave unknown fields **blank** and document missing items in **Notes**.

## Proposal Ledger Columns

Paste-ready rows and Sheet columns use this **exact 1–27 order** (tab-separated when pasting):

1. Proposal ID
2. Client ID
3. Client Name
4. Client Email
5. Phone
6. Property Address
7. Carrier
8. Quote Type
9. Policy Type
10. Annual Premium
11. Home Premium
12. Auto Premium
13. Other Premium
14. Total Savings
15. Current Carrier
16. Current Premium
17. Effective Date
18. Sent Date
19. Proposal Status
20. Gmail Subject
21. Gmail Thread ID
22. Proposal PDF Link
23. Spreadsheet/Comparison Link
24. Notes
25. Created By
26. Created At
27. Updated At

**When handing off a paste row:** Put the **TSV** inside a **fenced code block** so tabs and plain email addresses survive copy/paste from chat. **Unknown** fields stay **blank**. If **Proposal Status** is **Prepared**, keep **Sent Date** blank until the message is **actually sent**—then set **Sent Date** together with **Sent** status.

## Proposal task types

Use this table to decide whether a **Proposal Ledger** row (or paste-ready 27-column TSV / explicit no-change summary) is required. When a row is required, follow **Prepared** vs **Sent** rules in `RUNBOOK.md` (**Proposal workflow rules**): **Prepared** = Sent Date blank; **Sent** = Sent Date = actual send date; **Gmail Thread ID** blank until available.

| Task type | Ledger row required? | Status / date rules |
|-----------|----------------------|----------------------|
| **New proposal prepared but not sent** | **Yes** — new row or clear update to an existing draft row. | **Proposal Status** = Prepared (or equivalent); **Sent Date** blank; **Gmail Thread ID** blank until known. |
| **Proposal sent to client** | **Yes** — create or update row to reflect send. | **Proposal Status** = Sent; **Sent Date** = actual send date; populate **Gmail Subject** / **Gmail Thread ID** when known. |
| **Revised proposal** | **Yes** — update the same logical proposal (or new row if your process splits versions; document in **Notes**). | If not yet sent: Prepared rules (Sent Date blank). If resent: Sent rules on send. |
| **Client reply / follow-up needed** | **No row** if there was **no** new/revised/prepared/sent proposal—end with **Ledger summary: no ledger change** (reply-only). | If the reply includes a **new** proposal attachment or material revision, treat as **Revised** or **New prepared** and a row is **Yes**. |
| **Missing premium / savings / effective date** | **Yes** if you are filling CRM/ledger context for a tracked proposal; use blanks for unknown columns and explain in **Notes**. | Do not invent values; Prepared/Sent date rules follow the current lifecycle of that proposal. |
| **Proposal created from Gmail/thread context** | **Yes** when the outcome is a new or updated tracked proposal. | Populate from verified thread metadata where possible; leave unknowns blank; **Gmail Thread ID** when confirmed. |
| **Proposal created from quote PDFs/docs** | **Yes** when the outcome is a new or updated tracked proposal. | Extract only verified values into columns; remainder blank; cite source in **Notes** if needed. |

If unsure whether the touch was “reply-only,” default to documenting a **one-line Ledger summary** and either a **27-column paste row** or an explicit **no ledger change** statement—never silence the handoff.
