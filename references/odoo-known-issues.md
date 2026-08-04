# Odoo Known Issues and Techniques

Gotchas we've hit and the workarounds that actually work. Read before debugging something that
looks new. Most of these cost hours to find the first time.

_Harvested from assistant memory 2026-07-16._

## Which instance am I in?

Two Odoo MCP connections exist:

- **`odoo-prod`** is live production (www.volitioncomponents.com). This is the system of record.
  Real customer quotes live here.
- **`odoo`** is staging. Historically a stale sandbox, now used for AI-agent dev and testing.

**Record IDs differ between the two.** Always re-resolve products and partners in whichever
instance you're writing to. Never assume an id carries over.

For real estimates, opportunities, and any CRM or sales write, use `odoo-prod`. Sanity check by
confirming the latest `sale.order` name looks current (S012xx or higher as of mid-2026).

Staging URLs change: dev.odoo.com boxes get deleted and rebuilt under a new subdomain. When
staging breaks with a TLS "certificate's CN name does not match" error, the host is dead, not the
config. Get the new URL, update `ODOO_URL` and `ODOO_DB` in `.mcp.json`, generate a fresh API key
(keys are per-database), and restart. Never set `ODOO_VERIFY_SSL=0`.

**Staging is rebuilt monthly, fresh from production** (confirmed with Constance 2026-07-30, next
rebuild due 2026-08-04). Any write made only to staging (never applied to prod) gets wiped on the
next rebuild. Don't bother manually re-syncing a staging-only test change if a rebuild is close,
it'll come from prod automatically. If a rebuild happens and staging still shows old/un-fixed data
that should have come from prod, the rebuild source isn't what we think, worth flagging.

## Writes go through the guarded flow

`preview_write` then `validate_write` then `execute_approved_write` with `confirm=true`.

`preview_write` alone does **not** validate the token. You have to call `validate_write` first.
`execute_method` is blocked for create, write, and unlink. `name_create` and `copy` are blocked as
unreviewed side-effect methods.

## Editing a confirmed sale order

On a **confirmed** SO (state = `sale`), **set `product_uom_qty` to 0 to drop a line. Do not
delete it.** Odoo blocks deleting lines already tied to procurement or delivery. The zeroed line
stays visible at $0.

In the `order_line` write: `[1, <line_id>, {"product_uom_qty": 0}]` for the dropped item, then
`[0, 0, {...}]` for the replacement.

Also: the tax field on `sale.order.line` is **`tax_ids`** (many2many), not `tax_id`. On a
tax-exempt order, set `tax_ids: [[6, 0, []]]` on new lines.

Ops still needs to cancel or replace the underlying PO. The SO edit doesn't do that.

## Chatter notes render as escaped HTML

**`chatter_post` HTML-escapes the body and wraps everything in one `<p>`.** Any tags or entities
you pass show up as literal text (`&lt;p&gt;&lt;b&gt;...`). Newlines collapse to spaces.

Two options:

- **Plain text only** through `chatter_post`. Use line breaks and "- " dashes for structure. No
  `<b>`, `<ul>`, `<br>`. Fine for short notes.
- **Formatted notes:** write the `mail.message.body` field directly with real HTML via the guarded
  write flow. Either create the note then overwrite its `body`, or create the `mail.message`
  directly (model `sale.order`, `res_id` = the SO id, `subtype_id` 2). Use real characters
  (`°`, `"`), not HTML entities. Direct field writes store verbatim and render correctly.

To fix an existing ugly note, just `write` the `body` of that `mail.message` id. No need to delete
and repost. (Example: msg 190311 on S01294.)

`message_post` through `execute_method` is blocked, so the direct `mail.message` create is the
clean path for anything formatted.

## `search_records` returns 0 rows silently on some m2o fields

**Found 2026-07-16.** Asking for certain many2one fields makes `search_records` return
`success: true, count: 0` instead of an error, even when records plainly exist.

Reproduced on `res.groups`: requesting `fields: ["id", "name"]` returns rows normally, but adding
`category_id` returns zero. Putting `category_id` in the **domain** (e.g.
`[["category_id.name", "=", "Inventory"]]`) also returns zero. The field exists and has values.

**Why this is dangerous:** a silent empty result reads as "there is no such data" rather than "the
query failed." It's easy to draw a confident wrong conclusion from it.

**Workaround:** drop the offending field and get what you need another way. For group membership,
go through `ir.model.access` instead: query by `model_id.model` and read `group_id` off the ACL
(which resolves fine). Example: the only ACL granting create on `product.template` is
`product.template.manager`, group 150 "Products / Create".

If a query returns 0 and you expected rows, **re-run it with fewer fields before believing it.**

## Odoo 19 renamed `groups_id` to `group_ids`

On `res.users`, the groups field is **`group_ids`** in Odoo 19, not `groups_id`. Also,
`read_record` on `res.users` returned "Record not found" for ids that `search_records` returns
fine, so use `search_records` with an `id in [...]` domain for users.

## Who can create products

Only group **150 "Products / Create"** has create rights on `product.template` (verified against
production 2026-07-16, single ACL `product.template.manager`).

As of that date Adan, Constance, Tony, and Esme all have it, so all four can create parts. Group
counts overall: Constance 35, Adan 29, Tony 29, Esme 15. Esme is constrained on settings and
administration, not on products.

## Creating an eCommerce category fails via MCP

`product.public.category` create returns `HTTP 422: missing a required argument: 'vals'`.

**Cause:** the custom module `mc_volition_upgradation` overrides `create(self, vals)` with a
non-standard singular signature, but the MCP connector sends the standard `vals_list` kwarg.

**Workaround that works:** create child categories by writing the *parent's* `child_id` o2m with a
create command: write `product.public.category[parent]` with `{"child_id": [[0, 0, {"name": ...}]]}`.
Odoo processes `(0,0,vals)` by calling create positionally, which satisfies the override.

**Only one `(0,0,...)` per write.** Batching several throws "Expected singleton". Loop one child
per write.

Top-level categories with no parent still need manual UI creation, or create under a temp parent
and reparent. Scope: create on standard models works fine (`ir.ui.view`, `website.page`,
`website.menu` all verified). Write works everywhere, so tagging products via `public_categ_ids`
is fine.

**Proper fix:** add `@api.model_create_multi` / `vals_list` to the module's create override.

## Odoo 19: "Expected singleton: account.analytic.plan()"

**Symptom:** every transaction that recomputes analytic distribution (adding a product to an SO,
editing a bill, any account move) fails with `RPC_ERROR` / `ValueError: Expected singleton:
account.analytic.plan()`.

**Root cause:** an `account.analytic.distribution.model` rule with an empty distribution and no
filters, so it matches every line. On 2026-07-10 Odoo shipped commit `6fe806b` to the 19.0 branch
changing `_get_distribution` to unconditionally call `current_plans.mapped(...)`. On an empty rule
that hits `ensure_one()` on an empty recordset and crashes. **This is an Odoo core regression, not
our config.** The empty rule had sat harmlessly since 2025-11-06.

**Why it broke with nothing changed on our side:** dev.odoo.com and odoo.sh run the live 19.0
branch source. Odoo updated the branch, so new code went live with no upgrade we initiated.
Module `installed_version` never changed. Worth remembering as a general hazard: our Odoo can
change under us.

**Fix:** delete the empty rule. Search `account.analytic.distribution.model` for records with
`analytic_distribution = false` and no filters, then unlink. Done on staging and prod 2026-07-13
(both had exactly one, id=1).

**If it recurs:** someone re-saved an Analytic Distribution Model (Accounting > Config) without
filling in a distribution. Delete any empty-distribution rule.

## Product images

Setting a product image = writing base64 JPEG/PNG to `image_1920` on `product.template` via the
guarded write flow.

**The reliable path is drag-drop.** Have Adan or Constance drop the full-res file (or the vendor
product-page URL) straight into the Odoo product form. Offer this first.

The MCP path works but is fragile and low-res. If you must:

- `curl` fails with revocation errors on this network. Use `curl --ssl-no-revoke`.
- Vendor CDNs (luvernetruck.com) serve WebP even with an `Accept: image/jpeg` header. Convert.
- No ImageMagick, ffmpeg, or real Python on Adan's machine. Convert and resize with Windows WIC
  via PowerShell (`Add-Type -AssemblyName PresentationCore`, `BitmapImage`, `TransformedBitmap` +
  `ScaleTransform`, `JpegBitmapEncoder`). WIC decodes WebP fine on Win 11.
- **The real trap:** base64 has to be typed into the tool call by hand, and long strings get
  corrupted in transcription. Photos with big uniform backgrounds are worst (long repeated runs).
- **Fix:** downscale until base64 is short (128px JPEG q82 is roughly 3K chars). Then verify before
  writing: write your transcription to a file, `base64 -w0` the real file, `cmp` the two. Only
  reuse a byte-for-byte verified string, identically, in both `validate_write` and
  `execute_approved_write`.

First done: 415036-401471 (tmpl 4520) and 415100-401477 (tmpl 4521), Luverne Grip Step running
boards.

## Attachments

The Gmail MCP lists attachments but can't download their bytes. To get a file into Odoo:

1. **Link the Drive copy** on the record (`https://drive.google.com/file/d/<id>/view`). Preferred.
2. Adan drag-drops the file into Odoo for a native attachment.
3. Native base64 `ir.attachment` upload is unreliable (hand-reproducing large base64 has dropped a
   byte and would have produced a corrupt PDF). Only use if the decoded length matches the Drive
   `fileSize` exactly.

## Invoice PDF stopped showing the Stripe credit-card fee after V19

**Symptom (found 2026-07-17):** invoices used to print the credit-card surcharge Stripe collects
(passed through to the customer). After the Odoo 19 upgrade the fee vanished from the PDF.

**Not a data problem.** The fee is a field `fees` on `account.move`, populated by the custom module
`stripe_fee_ext` (which also adds `stripe_fees_active` + `get_fees()` on `payment.provider` and the
"+ $X Fees" badge on the online payment page). That field is still computed and correct on every
invoice. Only the PDF display broke.

**Root cause:** the upgrade repointed the invoice print action (`account.report_invoice_with_payments`,
report action id 216) at Odoo's **standard** document template `account.report_invoice_document`
(view 723). The standard template never references `o.fees`, and the old fee-printing customization
didn't survive the upgrade. The legacy `volition_mrp.report_invoice_document2` (view 5063) is no longer
used by the print action. General hazard: **report tweaks that aren't inside a maintained module get
wiped when an upgrade regenerates report templates.**

**Fix:** a thin inherited view on `account.report_invoice_document` that appends rows to the totals
table. Key `volition_cc_fee.report_invoice_document_fees` (staging view 7576, prod view 7577). Two rows,
both `t-if="o.fees"` so cash/check invoices are untouched:

- **Credit Card Fee** = `o.fees`
- **Total Amt Processed** = `(o.amount_total - o.amount_residual) + o.fees` (amount paid + fee = what
  actually ran through the card). Also gated on `print_with_payments` so it only shows on the
  with-payments PDF.

Anchor: `//table[hasclass('o_total_table')]` position `inside`. Odoo validates the xpath at write time,
so a successful create/write proves the anchor matched. To undo, deactivate the view (`active = false`).
Built and eyeballed on staging first (INV/2026/00150) before the prod deploy.

### Follow-up 2026-07-20: the other four invoice reports

The fix above only reached two of the six invoice print actions. There are five customer-invoice
reports on `account.move`, and they render **three different document templates**, so one inherited
view does not cover them all:

| Report action | Document template rendered | Fee view |
|---|---|---|
| Invoice PDF (216) | `account.report_invoice_document` (723) | 7577 |
| Invoices without Payment (218) | `account.report_invoice_document` (723) | 7577 |
| Invoices - Shorty Pants (1213) | `account.report_invoice_document_copy_1` (4205) | 7578 |
| Invoices without Payment - Short Stuff (1214) | `account.report_invoice_document_copy_2` (4211) | 7579 |
| Full View (1301) | `volition_mrp.report_invoice_document2` (5063) | 7580 |

The `_copy_1` / `_copy_2` templates are Studio duplicates. They are standalone views, **not** inherits
of 723, so nothing patched onto 723 ever reaches them. Same for `volition_mrp.report_invoice_document2`,
which is still live (it's what Full View prints, correcting the note above).

**The trap: Studio full-copy views at priority 9999999.** Each of those three templates carries a child
view named `web_studio.report_editor_customization_full.view._<template>`, whose entire arch is one
`<xpath expr="/t[@t-name='...']" position="replace" mode="inner">` at **priority 9999999**. That
replaces the whole body of the parent. Any normal inherit at the default priority 16 applies *first*
and then gets thrown away. It saves without error and silently does nothing.

So the three new views (7578/7579/7580) are written at **priority 10000000** to apply after Studio.
Anchor is `//div[@id='total']//table` (these copies don't carry the `o_total_table` class the stock
template has). Contents are otherwise identical to 7577. Rule of thumb: before patching any report
template, check `ir.ui.view` for children with priority 9999999 and set yours higher.

**Gate correction, same day.** Total Amt Processed was originally gated on `print_with_payments`, which
the "without Payment" actions (218, 1214) never set, so that row silently never printed on them. Adan
caught it. All four views now gate on `o.fees and o.amount_total != o.amount_residual` instead, meaning
"a payment has actually been applied." Same behavior on the with-payments reports, and it keeps a
meaningless "Total Amt Processed = just the fee" line off invoices nothing has been paid on yet.
Don't reintroduce `print_with_payments` as the gate.

Known cosmetic issue on Full View: template 5063 already prints a separate `Payment Transaction Fees:`
line in the payment-terms block near the QR code, so that report now shows the fee twice, in two
places. Left alone pending Adan's call on which one to drop.

**Rendering a report to verify is blocked over MCP.** `ir.actions.report._render_qweb_html` is a
side-effect method and isn't in `ODOO_MCP_ALLOWED_SIDE_EFFECT_METHODS` in `.mcp.json`. You can verify
the template chain and rely on Odoo's write-time xpath validation, but confirming the actual PDF means
printing one by hand.

## This machine is behind HTTPS inspection

Adan's Windows machine sits behind an HTTPS-inspection proxy presenting a non-compliant CA cert
(Basic Constraints not marked critical). Windows trusts it. Tools shipping their own cert bundle
don't.

Symptoms: winget `msstore` cert errors, `uv` failing with `invalid peer certificate: UnknownIssuer`,
Python `requests`/`certifi` failing with `CERTIFICATE_VERIFY_FAILED`.

Fixes:

- **uv:** `--native-tls`, or set `UV_NATIVE_TLS=1`
- **winget:** pin `--source winget`, avoid msstore
- **Python:** install `truststore` and auto-load it via `sitecustomize.py`
  (`import truststore; truststore.inject_into_ssl()`). Plain `REQUESTS_CA_BUNDLE` does **not**
  fix it, the strict Basic-Constraints check still rejects the proxy cert.
- **curl:** `--ssl-no-revoke`

Any new Python or CLI tooling on this network will likely hit the same wall. Expect Constance's
machine to need the same treatment.
