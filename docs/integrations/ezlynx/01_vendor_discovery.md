# EZLynx vendor discovery (Connect / API / QAS)

**Purpose:** Consolidate **publicly documented** facts, list **open questions** for EZLynx, and provide a **copy-paste email** so the human owner can complete vendor discovery. This document satisfies the roadmap task “vendor discovery” at the repository level; actual credentials and contracts live outside git.

---

## What we know from public sources

### Zapier (EZLynx Sales Center webservices)

- EZLynx documents a **Zapier integration** tied to **EZLynx Sales Center**, with agency-level enablement for the Zapier product (included with Sales Center but enabled separately).
- **Outbound data** uses Zapier **triggers** (events leaving EZLynx); **inbound** uses **actions**. Field lists and behavior are documented in EZLynx’s support article (see [`02_zapier_inventory.md`](02_zapier_inventory.md) for a summary and link).
- **Note trigger limitation:** EZLynx states the **note body is not included** in outbound note-created payloads for security; workflow must use metadata (e.g. discussion title, labels).

### Enterprise / marketing API narrative

- EZLynx markets **enterprise APIs**, **prefill**, and **Quoting Automation Services (QAS)** on public pages (e.g. [Insurance API / enterprise](https://www.ezlynx.com/insurance-api.html)). These pages are **not** a substitute for signed developer documentation, sandbox URLs, or OAuth client registration.

### Partner ecosystem

- [Technology Partners](https://int.ezlynx.com/partners/) describes an ecosystem (marketplace-style positioning). Integration specifics remain **vendor-confirmed**.

---

## Unknowns (must confirm with EZLynx)

| Topic | Why it matters |
|-------|----------------|
| **Connect / REST API** vs Zapier-only | If you need bulk history, custom queries, or server-to-server sync without Zapier, you need official API docs and auth. |
| **Sandbox / non-production tenant** | Safe integration testing without touching production PII. |
| **Auth model** | OAuth 2.0, API keys, agency-scoped tokens, IP allowlists—implementation depends on this. |
| **Object coverage** | Which entities are readable/writable (contacts, households, policies, notes, documents). |
| **QAS vs AMS data APIs** | QAS (rating/backend) may be a **different contract** from AMS prospect/applicant data exposed via Sales Center Zapier. |
| **Rate limits, pagination, webhooks** | For any non-Zapier API; affects Supabase or custom worker design later. |
| **IVANS / carrier downloads** | May be orthogonal to EZLynx→tracker workflow; confirm if policies must come from downloads vs AMS UI. |

---

## Paste-ready email to EZLynx (edit bracketed fields)

**To:** Your EZLynx account manager or `sales@ezlynx.com` / support per your contract  
**Subject:** API / EZLynx Connect documentation and sandbox — [Agency name]

---

Hello,

We are planning integrations between EZLynx and our internal follow-up tooling. Please help with the following:

1. **Sales Center Zapier:** Confirm our agency is **enabled for the Zapier product** with Sales Center. If not, what is required to enable it?

2. **Developer / Connect API:** Do we have access to **REST (or equivalent) APIs** for programmatic read/write beyond Zapier? If yes, please provide:
   - Documentation portal or PDF  
   - **Sandbox** or test tenant procedure  
   - **Authentication** method (OAuth 2.0, API keys, etc.)  
   - **Scopes or objects** available (prospects, applicants, opportunities, policies, notes, documents)  
   - **Rate limits** and supported **pagination** models  

3. **Quoting Automation Services (QAS)** vs AMS data: Are **QAS/rating APIs** bundled with our subscription or sold separately? We need clarity on which APIs apply to **rating** vs **policy/applicant master data**.

4. **Compliance:** Any **BA** or data-processing requirements for integrating external systems (including webhook endpoints hosted on our infrastructure or cloud vendor)?

Thank you,  
[Name]  
[Phone]

---

## Repository status

- **Vendor response:** Not stored in git (confidential). Track replies in your ticket system or secure notes.
- **Next step after reply:** Update [`03_field_mapping.md`](03_field_mapping.md) if EZLynx exposes additional IDs or fields not listed in the public Zapier article.
