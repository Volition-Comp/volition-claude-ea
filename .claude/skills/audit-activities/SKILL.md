---
name: audit-activities
description: Audit planned activities on Odoo opportunities (and sales orders), then mark done / edit / cancel each. Use when Adan says "audit my activities", reviews an opportunity's to-dos, or for a recurring activity cleanup.
---

# Audit Activities (Odoo CRM)

Keep the activity list real. Opportunities auto-load a templated sales cadence
(see [[odoo-estimate-conventions]] and the write-estimates skill), which is often
heavier than a given deal needs. This skill reviews open activities and dispositions
each one: **mark done**, **edit**, **cancel**, or **keep**.

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
  `args: [[<ids>]]`, optional `kwargs: {"feedback": "<note>"}`. This logs the activity
  to the record's chatter as completed.
  - Requires `mail.activity.action_feedback` in `ODOO_MCP_ALLOWED_SIDE_EFFECT_METHODS`
    (set in `.mcp.json`). Env changes need a VS Code reload to take effect.
- After acting, re-list the record's remaining activities to confirm.

## Recurring use
As EA services grow, run this on a cadence (e.g. Monday): sweep Adan's open + overdue
activities, hand him a grouped triage list with recommended dispositions, then apply his
calls. Can be wired to a scheduled routine. Always confirm cancels/done before executing.
