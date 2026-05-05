# Field mapping contract — EZLynx (Zapier) → Alpha Omega tracker

**Sources:** EZLynx published Zapier field tables ([Freshdesk article](https://ezlynxsupport.freshdesk.com/support/solutions/articles/8000085587-zapier-integration)); tracker columns from [`index.html`](../../../index.html) (`FIELDS`) and Proposal Ledger order from [`Alpha_Omega_CRM_Playbook.md`](../../../Alpha_Omega_CRM_Playbook.md).

---

## Primary join key (decision)

**Recommended:** **`Email`** as the human-primary join when present and stable (normalize to lowercase for comparison).

**Secondary / corroboration:**

- **EZLynx Id** fields (`Id`, `Applicant ID`, opportunity `Id`) — use as **external keys** in staging and future DB rows; required for idempotent updates without fuzzy matching.
- **Do not** implement automated **dedupe/merge** into production tracker rows without explicit **matching-logic approval** per [`CLAUDE.md`](../../../CLAUDE.md).

---

## Tracker row columns (`FIELDS`)

From code (order preserved):

`Client`, `Carrier`, `Premium`, `Savings`, `Date Sent`, `Status`, `Last Contact`, `Next Follow-Up`, `Email`, `Phone`, `Quote Number`, `Renewal Date`, `Date Bound`, `Lead Source`, `Notes`

---

## Pilot mapping — Personal Lines Prospect (new / modified)

Typical EZLynx outbound fields (names per vendor doc):

| EZLynx field | Tracker `FIELDS` target | Notes |
|--------------|-------------------------|-------|
| First Name + Last Name | **Client** | Concatenate with space; handle Prefix/Suffix if needed |
| Email | **Email** | Primary inbox key |
| Home Phone / Mobile Phone / Work Phone | **Phone** | Prefer mobile → home → work; or concatenate with labels in **Notes** |
| *(none in PL prospect table)* | **Carrier** | Leave blank for pilot |
| *(none)* | **Premium**, **Savings** | Leave blank |
| *(none)* | **Date Sent** | Leave blank (proposal workflow not in this trigger) |
| *(none)* | **Status** | Optional literal `Prospect` or leave blank until human triage—align with internal conventions |
| Date Modified or Date Created | **Last Contact** *(optional)* | Only if you adopt “last AMS touch” semantics; otherwise leave blank |
| *(none)* | **Next Follow-Up** | Human-set in tracker unless separate workflow |
| *(none)* | **Quote Number** | Blank |
| *(none)* | **Renewal Date**, **Date Bound** | Blank |
| Lead Source | **Lead Source** | Map text; may need translation table if EZLynx uses codes |
| Id + dates | **Notes** | Append `EZLynx prospect Id: …` for traceability |

---

## Translation — Lead Source (starter)

EZLynx may send free text or controlled values. Do **not** invent mappings; extend this table as real samples arrive.

| EZLynx value (example) | Tracker `Lead Source` |
|-------------------------|------------------------|
| *(empty)* | Leave blank or `Other` per internal policy |
| Website / Web | `Website` if it matches the app dropdown (`LEAD_SOURCES` in `index.html`, ~line 6676) |
| Referral | `Referral` |

Tracker allowed values (from app): `Referral`, `Website`, `Walk-in`, `Cold lead`, `Insurance Marketplace`, `Existing client`, `Other`, or blank.

**Rule:** If EZLynx sends a value **not** in the list, put the raw value in **Notes** and leave **Lead Source** blank until a human maps it.

---

## Opportunity trigger (optional later) — high-value columns

If you switch pilot to **New or Modified Opportunity**, vendor fields include LOB lines with **Prior Carrier**, **Prior Premium**, **Quoted Premium**, **Finalized Premium**, **Finalized Master Company**, etc.

| EZLynx (LOB / opportunity) | Tracker `FIELDS` |
|-----------------------------|------------------|
| Finalized Master Company / carrier-like fields | **Carrier** (best-effort; confirm semantics with AMS) |
| Quoted / Finalized Premium | **Premium** (single field—may need formatting) |
| Prior Premium vs Finalized | **Savings** only if your business defines savings from those fields—**do not guess** |

---

## Proposal Ledger (27 columns) — alignment note

Automated filling of Proposal Ledger columns from EZLynx is **out of scope for v1 pilot** unless operationally required. Many columns (**Gmail Thread ID**, **Proposal PDF Link**, **Sent Date**, etc.) come from **Gmail / proposal workflow**, not AMS prospects.

When a human promotes a staging row to a proposal, use the playbook order (1–27) in [`Alpha_Omega_CRM_Playbook.md`](../../../Alpha_Omega_CRM_Playbook.md); leave unknowns blank.

| Ledger column | Typical EZLynx source (if any) |
|---------------|-------------------------------|
| Client ID | EZLynx Applicant ID / prospect Id when agreed |
| Client Name | Applicant / contact name fields |
| Client Email / Phone | EZLynx email / phone |
| Carrier | Opportunity LOB / finalized carrier fields—verify |
| Annual Premium | Finalized or quoted premium—verify |
| *(Gmail / proposal columns)* | Not from EZLynx Zapier prospect pilot |

---

## Document / Note triggers

- **Document Created/Edited:** Useful for **policy number** metadata in vendor table; map into **Notes** or future structured staging—not directly to `Quote Number` without validation.
- **Note Created:** **Note body not included** per EZLynx—use discussion title/labels for automation; avoid assuming full note text in Sheets.
