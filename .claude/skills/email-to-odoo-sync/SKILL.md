---
name: email-to-odoo-sync
description: Sweep Gmail for sales-relevant mail and reconcile it with Odoo CRM — propose new opportunities, log correspondence onto existing opportunities/SOs, and flag stale deals. Use for the daily inbox sweep or when the user says "review my inbox" / "what came in".
---

# Email-to-Odoo Sync

Keep Odoo in sync with the current user's inbox. Produce a **triage digest**, then apply
only what they approve.

## Whose inbox, whose records
Sweep the **current user's own** mailbox and match against records they own. The Gmail
connector is per-account, so it already reads only their mail. Odoo is the part that can
go wrong: confirm the connected Odoo user with `get_odoo_profile` (`user_context.uid`)
and use that uid for ownership checks and for any `user_id` you set. Never assume a
specific person. See [[audit-activities]] for the same rule in full.

## Settings (2026-06-10)
- **Cadence:** daily digest (morning, user's local timezone).
- **Autonomy:** approve everything first. Nothing is written to Odoo until the user says go.
- **Stale threshold:** an open opportunity with no activity or correspondence in **14 days**.

## Tools
- Gmail: `search_threads`, `get_thread` (claude.ai Gmail MCP).
- Odoo: `search_records`, `read_record`, and the guarded write flow
  (`preview_write` -> `validate_write` -> `execute_approved_write`).

## Process
1. **Pull recent mail.** `search_threads` with `in:inbox is:unread newer_than:1d` (or
   since the last sweep). Exclude internal senders (`@volitioncomponents.com`),
   newsletters, and automated/no-reply mail. Use `get_thread` (FULL_CONTENT) when the
   snippet is thin or there's an attachment.
   - **Avoid resurfacing handled threads.** `search_threads` returns the whole thread, so
     an old message can look open. Before flagging a thread, confirm its **most recent
     message is an inbound one the user has NOT already answered** (the latest message is
     not `SENT` / not from them, and is genuinely within the window). If they already
     replied, skip it. When unsure, ask before drafting a reply or logging a note.
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
6. **Approve-first.** Present the digest; the user dispositions each item. Then apply:
   - **Create opportunity** — follow the opportunity conventions in
     [[odoo-estimate-conventions]] / the write-estimates skill (name, partner_id,
     type=opportunity, user_id, team_id=1, stage_id, contact_name, email_from). A new
     inbound with a spec sheet is usually **Qualified (2)**.
   - **Log correspondence** — post a dated note to the record's chatter (via
     `chatter_post`; may need `MCP_CHATTER_DIRECT` enabled in `.mcp.json`, like the
     `action_feedback` method). Keep it short: date, who, what.
   - **Stale nudge** — propose a follow-up activity (a Call/Email `mail.activity`) or
     surface it for the user to action. See [[audit-activities]].

## Notes & caveats
- **Local connector:** the Odoo MCP runs locally on the user's own machine, so this sweep
  runs when Claude Code is running locally (on-demand each morning, or a local scheduled
  trigger). A cloud/headless routine cannot reach local Odoo until we move Odoo to a
  remote/OAuth connector (the Option B in the claude-integrations project).
- **Email attachments — ALWAYS ASK to attach to the opportunity.** Whenever an email
  has an attachment, ask the user whether to attach it to the related opportunity/SO.
  Reliable methods (in order):
  1. **Link the Drive file** (preferred): if it's saved in Drive, find it with
     `Google_Drive.search_files` and put a clickable link on the record
     (`https://drive.google.com/file/d/<id>/view`) in the description or a note. No
     corruption risk, single source of truth.
  2. **The user drag-drops** the file into Odoo for a true embedded attachment.
  3. Native binary upload (create `ir.attachment` with base64 `datas`) is **unreliable
     through this path** — reproducing large base64 by hand drops bytes and corrupts the
     file. Avoid unless the content can be verified byte-exact (decoded length must match
     the Drive `fileSize`).
- Always leave new opportunities for the user to review; never email anyone on their
  behalf without explicit approval.
- Known repeat contacts include dealer reps (e.g., John Wieneke, Ken Garff Ford Greeley,
  jwieneke@kengarff.com).
