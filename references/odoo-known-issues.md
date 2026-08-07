# Odoo Known Issues and Techniques

Gotchas we've hit and the workarounds that actually work. Read before debugging something that
looks new. Most of these cost hours to find the first time.

_Harvested from assistant memory 2026-07-16._

## Who am I connected as? (set this up before anything else)

`.mcp.json` is committed and shared, so it must not name a person. Both Odoo entries read the
login from **your own** environment:

```
ODOO_LOGIN         your Odoo email, used by both instances
ODOO_API_KEY       your STAGING key
ODOO_PROD_API_KEY  your PRODUCTION key
```

On Windows, one time each, then fully restart VS Code (new env vars don't reach a running
process):

```
setx ODOO_LOGIN "you@volitioncomponents.com"
setx ODOO_PROD_API_KEY "<your prod key>"
setx ODOO_API_KEY "<your staging key>"
```

**API keys are per-user and per-database.** A key only works with the login that generated it, so
a mismatched `ODOO_LOGIN` fails auth outright, and (worse) a shared key silently attributes every
chatter note, activity, and quote to the wrong person.

Confirm before doing real work: `get_odoo_profile` returns `user_context.uid`. That's who you are.
Current prod uids: Adan 6, Tony 7, Constance 2, Esme 22. **Skills must resolve this uid at runtime
and never hardcode it.** Hardcoding uid 6 in the audit-activities skill is what showed Adan's
overdue to-do list to Constance on her own machine (fixed 2026-08-07).

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

## Quote/SO PDF hides individual priced line items from customers

On our quotation and sale-order PDFs, **individual priced line items do not print in the customer
copy** (they only appear in the full/internal view). What the customer actually reads is the
**section headers and the note lines** (`line_section` and `line_note`). Practical consequences:

- Vendor sourcing and internal placeholders left on *priced* lines (e.g. "from ProDriven", "do not
  purchase kit X", "Update Specs") are **not** customer-visible. No need to strip them for the
  customer's sake.
- **Note quality is the customer-facing document.** For completeness/formatting review, the
  "Includes:" notes and section names are what to scrutinize. A quote whose note is a stub reads as
  near-blank to the customer even if the priced lines are complete.
- Anything you *want* the customer to see (install requirements, scope) has to live in a
  `line_section` or `line_note`, not in a priced line's description.

Note: `line_note` text can drop content on create (observed the final line of a multi-line note
silently truncated on first write, stored fully on a follow-up write). Read the note back after
writing to confirm it stored whole.

## You and the person you're working with are the same Odoo user

The assistant connects with that teammate's own API key, so **every write it makes carries their
`write_uid`**. If they're editing the same record in the Odoo UI while the assistant works over
MCP, `write_uid` and `write_date` cannot tell the two apart.

**Found 2026-08-07 on S01469 (draft).** The assistant edited four lines, then noticed the order
total had moved the wrong way: down $68.65, despite $57.78 of material being added. Line 19695
(the Xantrex inverter, untouched by any of those writes) had picked up `discount` = 15.

The assistant concluded its own writes had triggered a pricelist recompute, "restored" the
discount to 0, and wrote that up here as an Odoo bug. **All of it was wrong.** Adan had typed
that 15% in by hand, in the UI, while the edits were happening. The revert wiped real pricing off
a live customer quote.

Lessons:

- **An unexplained delta on a record is not automatically your own side effect.** The other person
  is in there too. Ask before reverting anything that looks like it appeared on its own.
- **Reverting is a write like any other.** "Putting it back the way it was" deserves the same
  confirmation as any other change to customer pricing, not less.
- Checking `amount_total` after editing lines is still worth doing. Just don't assume the cause.

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

## CRM: quotes look "missing" on opportunities (two unrelated causes)

**Found 2026-07-25**, chasing "I can't see quotes on opportunities on my phone." Two separate
things, and they compound.

### 1. The smart-button row disappears below 768px

Odoo hides the entire `oe_button_box` (Meetings, Quotations, Orders, Similar Leads) when the
viewport is narrower than **768 CSS pixels**. Hard cutoff in the framework, not a setting, and
there is no overflow menu to dig into. The buttons are simply not rendered. From
`web/static/src/core/ui/ui_service.js` (19.0):

```js
export const MEDIAS_BREAKPOINTS = [
    { maxWidth: 575 },
    { minWidth: 576, maxWidth: 767 },   // isSmall tops out here
    { minWidth: 768, maxWidth: 991 },
    ...
];
```

`isSmall` is true at `SIZES.SM` or below, so 767px and under.

iPhone landscape widths straddle that line exactly:

| Model | Landscape width | Layout |
|---|---|---|
| SE (all gens), 7, 8 | 667 | mobile, no buttons |
| 8 Plus | 736 | mobile, no buttons |
| X, XS, 11 Pro, 12/13 mini | 812 | desktop, buttons |
| 11, 12, 13, 14, 15, 16 | 844 to 896 | desktop, buttons |
| any Plus / Pro Max | 926 to 956 | desktop, buttons |

That's why two people on the same app looking at the same record see different screens. Safari page
zoom above 100% and iOS Display Zoom set to "Larger Text" can also push a newer phone under the
line, so check those before blaming the hardware.

### 2. `quotation_count` reads 0 as soon as a quote is confirmed

`quotation_count` counts only orders still in **draft or sent**. On confirmation the order shifts to
`sale_order_count` and the Orders button. So on any **won** opportunity, Quotations shows 0 while
the money sits under Orders. Working as designed, but it reads exactly like missing data, and it
hits desktop users too.

Also worth knowing: `quotation_count` and `sale_order_count` are **`store: false, searchable:
false`**. A domain like `[["quotation_count", ">", 0]]` comes back `count: 0` with no error, which
is another instance of the silent-zero trap above. Search `sale.order` on `opportunity_id` instead,
which is stored and behaves.

### Fix

A **"Quotes & Orders" tab** on the `crm.lead` form listing `order_ids` (stored one2many to
`sale.order` via `opportunity_id`) with every linked record regardless of state. It sits in the
record body rather than the button row, so it renders at any width and sidesteps both problems at
once. Read-only, hidden on leads via `invisible="type == 'lead'"`.

**Live on prod as view 7584**, `crm.lead.form.quotes.orders.tab`, deployed 2026-08-05 and confirmed
working on the mobile app. Inherits `crm.lead.form` (**id 2389**), mode extension, priority 99.
Reversible by archiving the one view; touches no data.

It adds a notebook page listing `order_ids` read-only with `name`, `so_name`, `date_order`,
`amount_untaxed`, `amount_total`, `state`, `invisible="type == 'lead'"`. Odoo 19, so `<list>` not
`<tree>`. It also injects `<field name="type" invisible="1"/>` before the notebook rather than
trusting the base form, per the modifier gotcha below.

First built as staging view 7579 on 2026-07-25, held pending Constance's testing, then lost when
staging was rebuilt in early August 2026. Rebuilt from this spec straight into prod. The rebuild
cost nothing because the spec was written down, which is the argument for writing it down.

### Verifying a view actually applied (without the UI)

`execute_method` on the model with `get_view` (kwargs `{"view_id": <base id>, "view_type": "form"}`)
returns the **combined** arch plus a `models` dict of every field Odoo resolved. If your page and
its fields appear there, the view applied. This is the check that distinguishes "saved cleanly" from
"actually works", and it's the only server-side proof available over MCP.

### Gotcha: the Odoo mobile app caches view definitions

A view created minutes ago **will not appear** in the mobile app until you fully quit it (swipe it
away, not just background it) and reopen. Backgrounding is not enough. This reads exactly like a
broken view and cost us a round of debugging on 2026-08-05 when the view was already correct. Verify
server-side with `get_view` **first**, then restart the app, and only then start suspecting the view.
Same applies to a browser: hard refresh.

## Expected Revenue auto-populates from the quote

**Built on staging 2026-07-27, deployed to prod 2026-07-28.** Replaces hand-typing Expected Revenue
on every opportunity, which drifted constantly (prod opp 1165 Schaefer read $46,078.04 against a
$46,694.04 quote, and several opps with live quotes sat at $0).

Odoo gives you `sale_amount_total` ("Sum of Orders") for free, but it is **not stored** and counts
**confirmed orders only**, so it can't drive `expected_revenue`. You need an automation rule.

**The pieces (prod / staging):**

| Piece | Prod | Staging | What it does |
|---|---|---|---|
| `base.automation` | 27 | 27 | On Sales Order, trigger `on_create_or_write`, trigger fields `state` / `amount_untaxed` / `opportunity_id`, filter `[("opportunity_id","!=",False)]` |
| `ir.actions.server` | 1892 | 1891 | Python code action that writes `expected_revenue` on the linked lead |
| `ir.ui.view` | 7582 | 7580 | Opportunity form: Expected Revenue read-only once a quote exists |
| `ir.ui.view` | 7583 | 7581 | Opportunity list: Expected Revenue read-only outright |

**The staging IDs in that table are dead.** Staging was rebuilt in early August 2026, so 7580, 7581,
and server action 1891 no longer exist and the staging URL / DB changed with it. The **prod** side
survived untouched because it had already been deployed on 2026-07-28. Re-resolve every staging ID
against the new instance before trusting it. General lesson: a change that only exists on staging is
one rebuild away from gone, so write the spec down and deploy or discard rather than parking it.

**The rule (chosen by Adan over "sum everything" and "latest only"):**

- Any confirmed order on the opp: sum the untaxed totals of the confirmed ones.
- Nothing confirmed yet: use the newest live quote's untaxed total.
- Cancelled quotes ignored. If *every* quote is cancelled, leave the number alone rather than
  zeroing it.
- **Zero-value quotes ignored too**, same reasoning. Without this, opening a blank quote shell on an
  opportunity wipes a real estimate to $0. Caught during the prod backfill: opp 1098 CU Boulder
  Primary Care Van had a real $85,000 estimate and an empty draft quote, and would have been zeroed.
- Untaxed, not total. That matches how Adan was filling it in by hand.

Summing everything breaks on revisions (prod opp 1164 has two live quotes that are the same job,
$3,525.84 then $3,776.50). Latest-only breaks on genuinely multi-order deals (prod opp 300,
Bachelor Gulch, has 8 separate orders). The confirmed/else-latest split handles both.

It populates on **draft** quotes. Confirmation is not required, it only switches which branch feeds
the number.

### Gotcha: base_automation does not fire on a no-op write

Writing a field its **existing** value does not trigger the rule. Odoo drops unchanged values before
the automation sees them. So you **cannot** use "write the m2o back to itself" as a manual way to
kick an automation over MCP, and a test done that way reads as a broken rule when the rule is fine.
Test with a real change instead.

### Gotcha: fields used in a view modifier must be in *your* view

The form lock first went in as `readonly="quotation_count &gt; 0 or sale_order_count &gt; 0"`,
relying on those two fields already being in the form via sale_crm's smart buttons (view 2467).
The xpath matched, Odoo accepted the view, the data was correct, and the field **stayed editable**.

Fields declared inside `<button>` nodes in the button box do not reliably reach the form's
evaluation context. Fix: inject them into your own inherited view next to the field you're
gating, as `<field name="..." invisible="1"/>`. Duplicate field nodes in a *form* are fine, the base
`crm.lead.form` already declares `partner_id` and `email_from` twice.

General rule: a view that saves cleanly is not a view that works. Odoo validates the xpath at write
time, and nothing else.

### Gotcha: you can't simulate quote confirmation over MCP

`state` on `sale.order` is readonly in `fields_get`, so `validate_write` refuses it and
`action_confirm` is a blocked side-effect method. The draft-to-confirmed transition has to be tested
by hand in the UI.

### Known gap

Move a quote from opportunity A to opportunity B and **B updates, A keeps its stale number**. The
action only sees the new opportunity. Rare enough that it was left alone deliberately; a nightly
sweep over open opps would close it if it ever bites.

### "Not won and not lost" is not the same as "open"

Filtering opportunities on `won_status = 'pending'` to find the live pipeline pulls in **425 records
parked in a stage literally named Archive**, carrying $3.29M of stale expected revenue. Those are old
deals nobody ever formally marked Won or Lost. Any bulk operation scoped by won/lost status will hit
them.

The real selling pipeline is `stage_id in (1 New, 2 Qualified, 3 Proposition, 10 Approved – Final
Prep)`. Stages 11 Off-Site, 8 In Production, 9 Prod. Complete, 7 Invoiced and 5 Delivered & Unpaid
sit *after* Won in sequence but still read `is_won = false`, so they also survive a pending filter
while representing work already sold. Scope by stage, not by won status.

### Backfill done 2026-07-28

14 opportunities in the selling stages, net +$88,407. Deliberately skipped:

- **Opp 1098 CU Boulder Primary Care Van**, protected by the zero-quote guard above.
- **Opp 1157 State Bid Quotes**, a bucket opp holding 25 unrelated live draft quotes (~$163k total).
  Neither "newest quote" ($51,841.05) nor the sum is meaningful. Left at $0. **The automation will
  set it to the newest quote as soon as anyone edits one of those 25.** The real fix is splitting it
  into separate opportunities.

The 34 opportunities in post-sale stages were left alone. Only 10 differed and the net was -$171,
almost all cent-level rounding.

### Reversing it

Deactivate the automation rule and the two views. Touches no data. The backfilled values stay as
written.

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

## Drive returns OCR for drawings, not the drawing

`read_file_content` on an image or a drawing-heavy PDF returns **extracted text**: dimension
callouts, titles, labels. It does not tell you what is drawn or where anything sits. Working a
cabinet elevation or a floor plan from that output will produce confident, wrong conclusions.

Found 2026-08-05 on the CU Boulder C-Tech elevations. The OCR carried every dimension but hid that
the curbside run loses its first 38" to the sliding door, and that the Douglas Radio Van puts the
refrigerator curbside aft of the slider rather than streetside. Both change the layout.

**To actually see it:** the Drive MCP can't hand over usable image bytes (base64 into context and
back out is the corruption trap in the Product images section above), and Drive is **not** synced
to a local folder on these machines. So:

1. Check `C:\Users\<user>\Downloads` first. A file someone just uploaded to Drive is almost always
   still sitting there under the same name.
2. Read the local path. Images render visually from disk.
3. If it isn't local, ask for it to be dropped in Downloads. Don't guess from OCR.

### PDFs need rendering first

Reading a local PDF fails with "pdftoppm is not installed", and there is no poppler, ImageMagick,
or real Python on these machines. Windows can do it natively: **`references/render-pdf.ps1`** uses
the built-in `Windows.Data.Pdf` WinRT API to rasterize each page to PNG, which can then be read.

```powershell
& "references\render-pdf.ps1" -Pdf "$env:USERPROFILE\Downloads\FILE.pdf" -OutDir "<scratchpad>\out"
```

Writes `page01.png`, `page02.png`, … at 1700px wide (`-Width` to change). It prints a harmless
`PdfPage does not contain a method named 'Close'` error per page and exits non-zero; **the pages
still render**. Check the output directory rather than trusting the exit code.

Worth it: C-Tech project recaps carry a cabinet thumbnail next to every line, and the appliance
cutouts show as solid black panels. That is how you tell a fridge opening from a door opening, and
none of it survives text extraction.

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

## Onboarding a teammate to Claude Code on a locked-down office machine

Findings from setting up Constance's machine, 2026-07-29. These machines fight the local connector
install at nearly every step. Read this before onboarding the next person on Track A.

**The punchline first: on a locked-down office machine, prefer the REMOTE connector over the local
one.** Once the remote OAuth connector (MCP Studio / the app connector) is live, Claude Code can
point at *that* instead of a local stdio connector, which skips uv, the TLS workaround, and the
McAfee fight entirely. The whole local-install gauntlet below exists only because we're standing up
the local connector before the remote one. If the remote connector is already up, use it and skip
most of this.

Walls hit, in order, with what worked:

1. **McAfee kills the standard uv installer.** `irm https://astral.sh/uv/install.ps1 | iex` gets the
   PowerShell process terminated (VS Code shows "terminal process terminated with exit code: 1").
   Endpoint protection blocks the download-a-script-and-execute-it pattern. It fails *silently
   enough* to look like the install just "closed." Verify with
   `Test-Path "$env:USERPROFILE\.local\bin\uv.exe"` (came back `False`). Workaround: install uv
   **without** the piped-script pattern, download the uv Windows binary from the astral-sh/uv GitHub
   releases page in the **browser** (browser downloads are allowed; it's CLI script-execution that's
   blocked) and extract it, or `pip install uv` if a real Python is present.

2. **Cloning into Documents / Desktop / OneDrive / the C:\ root gives "destination folder access
   denied."** Controlled Folder Access / locked permissions. Clone into a fresh plain folder in the
   user profile instead: `cd ~; mkdir dev; cd dev; git clone <url>`. Lands clean in
   `C:\Users\<user>\dev`.

3. **git isn't preinstalled, and VS Code hides "Git: Clone" until it is.** If the command is missing
   from the palette, git's not there. Install Git for Windows from git-scm.com (browser download,
   not winget), then **fully restart VS Code**.

4. **VS Code's terminal keeps the old PATH after an installer runs.** A new terminal *tab* isn't
   enough; the integrated terminal inherits VS Code's environment from when VS Code launched. Either
   fully restart VS Code, or add to the session PATH by hand
   (`$env:Path = "$env:USERPROFILE\.local\bin;" + $env:Path`).

5. **Claude Code the VS Code extension vs. Claude the web app are different things.** "I'm chatting
   with Claude" might be the browser app. For Track A they need the **VS Code extension** (Extensions
   panel, search "Claude Code", Anthropic publisher). The repo context/skills only load in the
   extension opened on the cloned folder.

6. **Each person needs their own Odoo API key, and only they can make it.** Generated in Odoo web UI
   (My Profile > Account Security > New API Key). The agent can't create it. Set it as the env var
   `.mcp.json` expects (`ODOO_PROD_API_KEY`, and `ODOO_API_KEY` for staging).

7. **The committed `.mcp.json` hardcodes Adan's connector path**
   (`C:\Users\agonz\.local\bin\odoo-mcp.exe`). Each machine needs its own path, plus the TLS
   truststore chain from the HTTPS-inspection section above. This is the still-unsolved portability
   item, another reason to prefer the remote connector.

**Least-privilege note for admins:** the committed config has writes enabled. For an Odoo admin
(Constance), the API key carries full admin permissions (Odoo keys inherit the user's rights; you
can't scope a key below its user without a second, limited Odoo user). Set up **read-only first**
(drop the writes flag) and enable writes deliberately once the key approach is settled.
