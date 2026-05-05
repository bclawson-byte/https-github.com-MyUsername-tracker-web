# Zapier inventory — EZLynx (Sales Center)

**Canonical vendor doc:** [EZLynx Zapier Integration Guide](https://ezlynxsupport.freshdesk.com/support/solutions/articles/8000085587-zapier-integration) (Freshdesk). UI labels in Zapier may differ slightly; verify in the EZLynx app while building Zaps.

**Prerequisites (EZLynx-stated):**

- Licensed for **EZLynx Sales Center**.
- Agency **enabled for the Zapier product** (included with Sales Center but enabled separately).
- **Zapier** account at [zapier.com](https://zapier.com/).
- EZLynx support covers EZLynx; **Zapier support** covers Zapier platform issues.

**Hub:** [Zapier · EZLynx integrations](https://zapier.com/apps/ezlynx/integrations)

---

## Outbound triggers (EZLynx → Zapier)

These **emit events** when records change or documents/notes are created. Use them to “pull” data **forward** into staging (Sheet, webhook, email).

| Trigger (conceptual name) | Use when |
|---------------------------|----------|
| New Personal Lines Prospect added | Seed pipeline from PL prospects |
| Personal Lines Prospect updated | Track edits / lead progression |
| New Commercial Lines Prospect added | Commercial prospect intake |
| Commercial Lines Prospect updated | Commercial prospect edits |
| New Personal Lines Applicant added | Strong identity / household-style records |
| Personal Lines Applicant updated | Ongoing AMS edits |
| New Commercial Lines Applicant added | Commercial applicant intake |
| Commercial Lines Applicant updated | Commercial AMS edits |
| New Opportunity added | Pipeline value, LOBs, premiums (see vendor field table) |
| Opportunity updated | Status / premium changes |
| Document Created | Attach metadata (policy number, doc type, paths—per vendor table) |
| Document Edited | Same, on edit |
| Note Created | **Note:** EZLynx documents that **note body is not included** outbound—use Discussion Title, Labels, etc., for workflow |

**Security note (vendor):** Outbound fields are **restricted** to reduce PII exposure; connect only to trusted destinations.

---

## Inbound actions (Zapier → EZLynx)

Use when pushing data **into** EZLynx from web forms, spreadsheets, or other apps.

| Action (conceptual name) | Use when |
|---------------------------|----------|
| Create Personal Lines Prospect | Inbound leads |
| Create Commercial Lines Prospect | Commercial leads |
| Create Personal Lines Applicant with Opportunity | Fuller PL creation |
| Create Commercial Lines Applicant with Opportunity | Fuller commercial creation |
| Create Document | Upload / register documents |
| Create Note | Add discussion notes (respect EZLynx rules) |
| Commercial Applicant Search / Personal Applicant Search | Lookup before update |
| Commercial Applicant Update / Personal Applicant Update | Push changes back to AMS |

---

## Make (Integromat)

This repo does **not** duplicate Make’s module list (it changes). If you use Make, search for **EZLynx** in Make’s library and compare triggers/actions to Zapier; align field mapping with [`03_field_mapping.md`](03_field_mapping.md).

---

## Recommended pilot (v1)

**Chosen pilot trigger:** **New Personal Lines Prospect added** (or **updated** if you must capture edits immediately).

**Why:**

- Narrow surface area vs applicants/opportunities.
- Field set is documented (Id, names, phones, email, lead source, dates—see vendor article).
- Fits early staging rows for **Client**, **Email**, **Phone**, **Lead Source** without claiming policy/carrier truth yet.

**Alternative pilot:** **New Opportunity added** if the priority is **premium / carrier / LOB** signals (`Prior Carrier`, `Quoted Premium`, `Finalized Premium`, etc. in vendor opportunity table)—heavier mapping.

---

## Failure modes and replay

| Issue | Mitigation |
|-------|------------|
| Zap **does not run** | Check Zap **status** (on/off), EZLynx **connection** expired—reconnect in Zapier; confirm Sales Center **Zapier enablement**. |
| **No sample** on trigger test | Create a harmless **test prospect** in Sales Center; re-run trigger test. |
| **Partial fields** | EZLynx restricts outbound fields; do not assume parity with full AMS UI—document gaps in staging **Notes** column. |
| **Duplicate rows** on Sheet action | Prefer **append** for auditability during pilot; dedupe is **matching logic**—requires explicit approval before automation in [`index.html`](../../../index.html). |
| **Missed events while Zap off** | Zapier does not backfill AMS history; recover via **manual export** or **official API** if EZLynx provides one—see [`01_vendor_discovery.md`](01_vendor_discovery.md). |

**Replay:** Zapier **Zap History** supports retry of failed steps where applicable; design staging so rows are **idempotent-by-event** if you later add a webhook with dedupe keys (`Applicant ID` + `Date Modified`, etc.).
