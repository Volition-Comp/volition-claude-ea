---
name: email-to-odoo-sync
description: Sweep Gmail for sales-relevant mail and reconcile it with Odoo CRM — propose new opportunities, log correspondence onto existing opportunities/SOs, and flag stale deals. Use for the daily inbox sweep or when Adan says "review my inbox" / "what came in".
---

# Email-to-Odoo Sync

Keep Odoo in sync with Adan's inbox. Produce a **triage digest**, then apply only
what Adan approves.

## Adan's settings (2026-06-10)
- **Cadence:** daily digest (morning, MST).
- **Autonomy:** approve everything first. Nothing is written to Odoo until Adan says go.
- **Stale threshold:** an open opportunity with no activity or correspondence in **14 days**.

## Tools
- Gmail: `search_threads`, `get_thread` (claude.ai Gmail MCP).
- Odoo: `search_records`, `read_record`, and the guarded write flow
  (`preview_write` -> `validate_write` -> `execute_approved_write`).

## Process
1. **Pull recent mail.** `search_threads` with `in:inbox newer_than:1d` (or since the
   last sweep). Exclude internal senders (`@volitioncomponents.com`), newsletters, and
   automated/no-reply mail. Use `get_thread` (FULL_CONTENT) when the snippet is thin or
   there's an attachment.
2. **Classify each relevant thread:**
   - **New opportunity** — a sales request/spec/quote ask from someone with no open
     opportunity. (E.g., a dealer rep sending an upfit spec sheet.)
   - **Correspondence on an existing deal** — sender/customer matches an open
     opportunity or SO; capture a one-line summary to log.
   - **Skip** — not sales-relevant.
3. **Match to Odoo.** `search_records` `res.partner` by sender email; then `crm.lead`
   and `sale.order` by that partner (and by keyword/project name). Check whether an
   **open** opportunity already exists (ignore Archive/Won/closed stages) to avoid dupes.
4. **Stale check.** `crm.lead` opportunities not in a closed stage with last activity /
   correspondence older than 14 days → flag for a nudge.
5. **Build the digest**, grouped:
   - **New opportunities to create** (proposed name, contact, stage, why)
   - **Notes to log** (which record, the one-line summary)
   - **Stale deals** (name, days quiet, suggested next step)
6. **Approve-first.** Present the digest; Adan dispositions each item. Then apply:
   - **Create opportunity** — follow the opportunity conventions in
     [[odoo-estimate-conventions]] / the write-estimates skill (name, partner_id,
     type=opportunity, user_id, team_id=1, stage_id, contact_name, email_from). A new
     inbound with a spec sheet is usually **Qualified (2)**.
   - **Log correspondence** — post a dated note to the record's chatter (via
     `chatter_post`; may need `MCP_CHATTER_DIRECT` enabled in `.mcp.json`, like the
     `action_feedback` method). Keep it short: date, who, what.
   - **Stale nudge** — propose a follow-up activity (a Call/Email `mail.activity`) or
     surface it for Adan to action. See [[audit-activities]].

## Notes & caveats
- **Local connector:** the Odoo MCP runs locally on Adan's machine, so this sweep runs
  when Claude Code is running locally (on-demand each morning, or a local scheduled
  trigger). A cloud/headless routine cannot reach local Odoo until we move Odoo to a
  remote/OAuth connector (the Option B in the claude-integrations project).
- Always leave new opportunities for Adan to review; never email anyone on his behalf
  without explicit approval.
- Known repeat contacts include dealer reps (e.g., John Wieneke, Ken Garff Ford Greeley,
  jwieneke@kengarff.com).
