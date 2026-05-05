# EZLynx integration (Alpha Omega tracker-web)

This folder implements the **repo-side deliverables** for the EZLynx integration roadmap: vendor discovery packet, Zapier inventory, field-mapping contract, middleware pilot runbook, and approval-gates checklist.

**Scope:** Planning and staging-only automation. No changes to [`index.html`](../../../index.html), no automated matching, and no writes to the production Proposal Ledger unless separately approved per [`CLAUDE.md`](../../../CLAUDE.md).

| Document | Purpose |
|----------|---------|
| [`01_vendor_discovery.md`](01_vendor_discovery.md) | Public sources, unknowns, and a paste-ready request for EZLynx (Connect/API, QAS, sandbox). |
| [`02_zapier_inventory.md`](02_zapier_inventory.md) | Outbound triggers and inbound actions (Sales Center Zapier), pilot trigger, replay/failure notes. |
| [`03_field_mapping.md`](03_field_mapping.md) | EZLynx → tracker `FIELDS` and Proposal Ledger columns; recommended join key. |
| [`04_middleware_pilot_runbook.md`](04_middleware_pilot_runbook.md) | Staging Sheet setup, Zap steps, monitoring, optional webhook smoke test. |
| [`05_approval_gates_checklist.md`](05_approval_gates_checklist.md) | Sign-offs required before app or production Sheet automation. |
| [`staging_sheet_headers.tsv`](staging_sheet_headers.tsv) | Paste row 1 into a **new** Google Sheet used only for EZLynx staging. |
