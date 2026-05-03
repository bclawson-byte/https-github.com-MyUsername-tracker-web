# Agent command playbook

**Project root:** `c:\tracker-web`  
**Audience:** Baruch (operator) — invoke agent roles without drafting a fresh prompt each time.

---

## 1. How this works

- Role instructions and checklists live under **`.claude/agents/`** (Markdown files per role). They define what that role should do and how strictly to behave.
- **You still have to invoke the role explicitly** in **Claude Cowork** or **Cursor Agent** (or paste the reusable prompt below). Most setups do **not** auto-spawn subagents unless the product is configured that way.
- Point the agent at this repo and, when useful, name the file to read first (e.g. `Alpha_Omega_CRM_Playbook.md`, `RUNBOOK.md`, `AGENT_RULES.md`).

---

## 2. Which tool to use

| Tool | Best for |
|------|-----------|
| **Claude Cowork** | Workflow, proposal drafting, business/process review, ledger discipline audits, multi-step reasoning with MCP where configured. |
| **Cursor Agent** | File edits, small code patches, `git` checks, repo verification, read-only code walks. |
| **ChatGPT** | Strategy, prompt design, guardrails, decision support, drafting wording you will paste elsewhere. |

Use **Cowork** when the task is mostly “what should we do / did we follow process?” Use **Cursor** when the task is “change or verify files in `c:\tracker-web`.”

---

## 3. Proposal Ledger Auditor command

**When:** After any proposal-related deliverable (email, revision, paste row, or “no change” reply).

**Paste (adjust bracketed parts):**

```text
You are the Proposal Ledger Auditor for Alpha Omega CRM (repo: c:\tracker-web).

Read and follow: .claude/agents/proposal-ledger-auditor.md
Cross-check: RUNBOOK.md (section "Proposal workflow rules"), Alpha_Omega_CRM_Playbook.md (Phase 5 and "Proposal task types").

Task: Audit the following transcript/output for Proposal Ledger discipline:
[PASTE DELIVERABLE OR POINT TO FILE PATH]

Report: compliance (yes/no/partial), missing items, whether a 27-column TSV in a fenced code block was produced when required, Prepared vs Sent date violations, placeholder use in columns, presence of a one-line Ledger summary, reply-only no-change handling, and whether any Google Sheet write was claimed without explicit human approval.
```

---

## 4. CRM Code Reviewer command

**When:** You want a **read-only** review of `index.html` (or a named slice) without edits.

**Paste:**

```text
You are the CRM Code Reviewer for Alpha Omega CRM (repo: c:\tracker-web).

Read and follow: .claude/agents/crm-code-reviewer.md
Scope: Read-only review of index.html only unless I explicitly approve editing it later.

Focus: [DESCRIBE: e.g. boot path / Proposal Ledger read path / Gmail helpers — or "full-file skim for risky patterns"]
Constraints: Do not edit index.html. Do not add Google Sheets write logic. Do not add matchers unless I explicitly ask.

Output: Findings by severity, file:line references where possible, and recommended next step (single patch or human decision).
```

---

## 5. CRM Docs Guardian command

**When:** Docs/playbooks drifted or you want a consistency pass **without** app code changes.

**Paste:**

```text
You are the CRM Docs Guardian for Alpha Omega CRM (repo: c:\tracker-web).

Read and follow: .claude/agents/crm-docs-guardian.md
Task: Documentation consistency audit only — do not edit index.html or change app behavior.

Compare: [LIST DOCS: e.g. RUNBOOK.md, Alpha_Omega_CRM_Playbook.md, AGENT_RULES.md, PROJECT_MAP.md, CLAUDE.md]
Report: contradictions, stale references, missing cross-links, and a short prioritized fix list (markdown edits only if I ask you to apply them).
```

---

## 6. UI Polish Planner command

**When:** You want UI improvement **plans** only — no implementation.

**Paste:**

```text
You are the UI Polish Planner for Alpha Omega CRM (repo: c:\tracker-web).

Read and follow: .claude/agents/ui-polish-planner.md
Task: UI improvement plan only — do not edit index.html or any code unless I explicitly open a coding phase.

Context: [SCREEN OR FLOW: e.g. pipeline cards / inbox triage / tasks]
Output: Prioritized recommendations, rationale, and risks; no patch unless I request implementation separately.
```

---

## 7. Safe Cursor Patch command

**When:** One small, controlled change in-repo (often `index.html` only **after** explicit phase approval).

**Paste:**

```text
Project root: c:\tracker-web

Mode: Single small controlled patch.
Allowed files: [e.g. index.html ONLY — list explicitly]
Do not: refactor unrelated code, change boot sequence, add matchers, add Google Sheets write logic, edit markdown unless listed, commit.

Goal: [ONE SENTENCE]

After editing: show exact diff, confirm only allowed files changed, run git diff --check if applicable, do not commit unless I say so.
```

---

## 8. Commit Check command

Run from **`c:\tracker-web`** in a terminal before committing:

```bash
git status --short
git diff --check
git diff --stat
git log --oneline -5
```

**Interpret quickly:** `--check` flags trailing whitespace and conflict markers; `--stat` shows scope; `log -5` confirms you are on the intended branch/history.

---

## 9. Rules of engagement

- **No `index.html` edits** unless the current phase explicitly approves touching app code (default for doc/strategy work: hands off).
- **No Google Sheets writes** unless the connector/session is confirmed and **human approval** for writes is explicit for that task (app today is read-only for the ledger unless that policy changes).
- **No broad refactors** — one concern per patch unless a phase doc says otherwise.
- **One patch at a time** — easier review and rollback.
- **Always show the diff** before a commit; review in Cursor or `git diff`.
- **Proposal tasks** must end with **Proposal Ledger Row To Paste** (27-column TSV in a fenced block), **Proposal Ledger Row Update** (only with approved write access), or an explicit **Ledger summary: no ledger change** for reply-only work — per `RUNBOOK.md` (**Proposal workflow rules**) and Phase 11B discipline.

---

*This file is operator guidance only; canonical process detail remains in `Alpha_Omega_CRM_Playbook.md`, `RUNBOOK.md`, and `AGENT_RULES.md`.*
