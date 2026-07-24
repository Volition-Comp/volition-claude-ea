---
name: audit-activities
description: Audit planned activities on Odoo opportunities (and sales orders), then mark done / edit / cancel each. Use when Adan says "audit my activities", reviews an opportunity's to-dos, or for a recurring activity cleanup. Has two modes — a read-only daily DIGEST (overdue / due today / upcoming, for the morning sync) and the full weekly TRIAGE (disposition each activity).
---

# Audit Activities (Odoo CRM)

Keep the activity list real. Opportunities auto-load a templated sales cadence
(see [[odoo-estimate-conventions]] and the write-estimates skill), which is often
heavier than a given deal needs. This skill reviews open activities and dispositions
each one: **mark done**, **edit**, **cancel**, or **keep**.

Two modes:
- **Digest (read-only, daily):** a fast readout for the morning sync. No writes, no
  decisions required. See [[#Digest mode (read-only)]].
- **Triage (full, weekly):** disposition each activity. The rest of this skill.

## Digest mode (read-only)
A daily readout, meant to be folded into the morning sync. **No writes — never cancel,
edit, or mark done in this mode.** Just surface what's on Adan's plate so nothing slips.
- Pull Adan's open activities: `search_records` `mail.activity`, domain
  `[["user_id","=",6],["res_model","in",["crm.lead","sale.order"]]]`,
  order `date_deadline`. The `note` field is bulky HTML — omit it unless an item needs
  detail.
- **Exclude archived deals** (Adan's standing rule): drop activities whose `crm.lead` is
  archived (`active=False`) or sits in the **Archive** stage (`stage_id` 6). Confirm by
  reading the parent leads' `active` + `stage_id`.
- Bucket by `state`/`date_deadline` relative to today:
  - **Overdue** — past deadline. Lead with these.
  - **Due today**
  - **Upcoming** — next ~5 days, so nothing sneaks up.
- Group by opportunity; show type, summary, deadline, stage. Flag anything stale (e.g.
  intro cadences months overdue on untouched New-stage deals — candidates for the weekly
  triage). Keep it short: most mornings this is a glance.
- If something obviously needs action, name it and offer to handle it (in the live
  session or the next triage). Don't act automatically.

## Pull the activities
Open (planned) activities live in `mail.activity`. Done ones are gone from here and
logged to the record's chatter.
- For one opportunity: `search_records` `mail.activity`, domain
  `[["res_model","=","crm.lead"],["res_id","=",<lead_id>]]`.
- For Adan's whole pipeline: domain `[["res_model","=","crm.lead"],["user_id","=",6]]`,
  order by `date_deadline`. Add `["date_deadline","<",<today>]` to find overdue.
- Useful fields: `activity_type_id`, `summary`, `note`, `date_deadline`, `user_id`,
  `state` (overdue / today / planned), `res_id`, `res_model`.
- Activity types: Email = 1, Call = 2, Meeting = 3.

## Triage
Group by opportunity. For each activity, recommend a disposition and **show Adan a
table**; he decides per item (cancel and mark-done are not reversible-cheap, so confirm
before executing). Heuristics:
- **Done** — already happened in the real world (e.g. proposal sent).
- **Cancel** — template bloat or irrelevant for this deal (e.g. on-site review and
  final-negotiation meetings on a small dealer parts job).
- **Edit** — right intent, wrong date/owner/scope.
- **Keep** — still the real next step.

## Execute (per Adan's decisions)
- **Cancel** → guarded **unlink**: `preview_write` -> `validate_write` ->
  `execute_approved_write` with `operation: "unlink"`, `record_ids: [...]`.
- **Edit** → guarded **write** on `mail.activity` (`date_deadline`, `summary`,
  `activity_type_id`, `user_id`).
- **Mark done** → `execute_method`, model `mail.activity`, method `action_feedback`,
  `kwargs: {"ids": [<ids>], "feedback": "<note>"}`. This logs the activity to the
  record's chatter as completed. (The JSON-2 transport rejects positional `args` for
  this method, so pass the ids inside `kwargs`, not as `args: [[<ids>]]`.)
  - Requires `mail.activity.action_feedback` in `ODOO_MCP_ALLOWED_SIDE_EFFECT_METHODS`
    (set in `.mcp.json`). Env changes need a VS Code reload to take effect.
- After acting, re-list the record's remaining activities to confirm.

## Recurring use
As EA services grow, run this on a cadence (e.g. Monday): sweep Adan's open + overdue
activities, hand him a grouped triage list with recommended dispositions, then apply his
calls. Can be wired to a scheduled routine. Always confirm cancels/done before executing.
