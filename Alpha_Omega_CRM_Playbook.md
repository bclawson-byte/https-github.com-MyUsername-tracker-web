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
