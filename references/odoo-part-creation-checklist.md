# Odoo Part Creation Checklist

Standing rules for creating a new part (product) in Odoo. All three are required unless
there's a specific reason not to. Apply them every time.

_Source: Adan's and Constance's standing corrections, harvested from assistant memory 2026-07-16._

## The three rules

### 1. Internal Reference = the vendor SKU

Set `default_code` on `product.template` to the vendor's part number.

Also set `product_code` on the `seller_ids` (`product.supplierinfo`) line, on the Purchase tab.
Both. The internal reference should line up with the vendor's number so the two match when
anyone goes looking.

### 2. Route = Buy

Set `route_ids` to `[[6, 0, [5]]]`. The "Buy" route is id 5 in both staging and production.

Most parts Volition stocks are purchased from a vendor, so Buy is correct. Only use another
route when the item is genuinely built in-house, meaning it has a BOM with labor, or it's a Kit.
If it's a build or a Kit, ask rather than guessing.

This is Constance's standing rule as operations manager.

### 3. Track Inventory = on

Set `is_storable: true` in the create vals. Product `type` stays `consu`.

Parts need inventory tracking so stock is managed correctly. Verify it's set after creating.
Adan caught two parts created 2026-07-06 where one had this off, which is how it ended up on
this list.

## Verifying

After the create, read the record back and confirm all three landed. The write flow
(`preview_write` then `validate_write` then `execute_approved_write` with `confirm=true`) will
report success even when a field silently didn't take, so check.

## Related

- Product images: see `references/odoo-known-issues.md` (the image upload section). Short version:
  the reliable path is Adan or Constance drag-dropping the full-res file into the Odoo product
  form. The base64-through-MCP route works but is low-res and fragile.
- Product page copy: see `references/website-build-notes.md` for which description field renders
  where.
- Estimates: see `.claude/skills/write-estimates/SKILL.md`.
