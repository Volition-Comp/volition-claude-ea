# Bug Report: eCommerce shop attribute filter does nothing

**For:** Odoo developer / partner
**Product:** Volition Components website (Odoo 19, eCommerce / `website_sale`)
**Severity:** High. Blocks our entire "find products by filter" effort (vehicle, brand, material, color).
**Date filed:** 2026-06-18

---

## Summary
On the shop page, the left-sidebar **attribute filters do nothing**. Selecting any
attribute value (e.g. Make = Ford, or Color = Black) reloads the page but returns the
**entire catalog** instead of a filtered subset. The filter UI renders correctly; it just
has no effect on the results.

This affects **all attributes**, not a specific one (tested both a no-variant attribute and
a variant-creating attribute). Category filtering and sort both work fine, so the problem is
isolated to attribute filtering in the shop controller.

We suspect this broke when the **Theme Prime** theme was removed (Theme Prime previously
provided product filtering/sorting). Please confirm.

---

## Environment
- Odoo **19**.
- Staging where this was diagnosed: `https://volition-staging-v19-29977972.dev.odoo.com`
- Production (likely same issue): `https://www.volitioncomponents.com`
- Standard `website_sale` shop. Theme Prime was uninstalled/removed at some point.

---

## Expected vs. actual
- **Expected:** Selecting Make = Ford on `/shop` returns only Ford-compatible products
  (~424), the "Ford" option shows as selected, and the filter combines with the current
  category and with other attribute filters.
- **Actual:** The full catalog is returned (~1,095 products, 55 pages). The select still
  shows "All Make" as selected. Same for every attribute value tried.

---

## How to reproduce
1. Open `/shop`. Note the pager goes to page 55 (~1,095 products).
2. Apply an attribute filter via URL (this is exactly what the sidebar `<select>` submits):
   - `/shop?attribute_value=5-30`  → Make = Ford. **Still 55 pages.** Should be ~18.
   - `/shop?attribute_value=9-106` → Color = Black (a *variant* attribute). **Still 55 pages.**
   - `/shop?attribute_value=5-999` → nonsense value. **Still 55 pages** (a working filter would
     return 0). This shows the parameter is being **dropped entirely**, not mis-evaluated.
3. Compare with things that DO work:
   - `/shop/category/refrigeration-36` correctly narrows to ~2 pages. (Category filter OK.)
   - `/shop?order=name asc` reorders the products. (Query-string parsing OK, so it is **not**
     a page-cache problem.)

## The filter form actually rendered on `/shop`
```html
<form method="get" class="js_attributes ..." action="/shop">
  ...
  <select class="form-select css_attribute_select" name="attribute_value">
    <option value="" selected="true">All Make</option>
    <option value="5-30">Ford</option>
    <option value="5-31">Mercedes-Benz</option>
    ...
  </select>
  ...
</form>
```
So the form GET-submits `attribute_value=<attribute_id>-<value_id>` to `/shop`. That value
is correct; the controller just isn't acting on it.

---

## Likely cause / where to look
The shop controller is not applying the `attribute_value` parameter to the product search
domain. Candidates, in rough priority order:

1. **Leftover Theme Prime remnants.** Partially-removed `theme_prime` (or related
   `theme_*`) views, assets, JS, or a controller override that still hijacks `/shop`
   filtering. Check installed modules and any orphaned `ir.ui.view` / `ir.asset` records.
2. **Controller override mismatch.** A custom module overriding
   `website_sale.controllers.main.WebsiteSale.shop`, `_get_search_domain`, or
   `_get_search_options` that drops/ignores `attribute_value`. Our instance has a custom
   module **`mc_volition_upgradation`** that overrides other `website_sale` behavior
   (product page tabs) and a non-standard `product.public.category.create` signature, so it
   is a prime suspect for also touching the shop.
3. **Param-name mismatch.** Confirm the controller reads the same key the template emits.
   v19 standard reads `attribute_value` (format `attr_id-value_id`) via
   `request.httprequest.args.getlist('attribute_value')`. Older code used `attrib`. If the
   template was upgraded but the controller (or an override) still reads `attrib` (or vice
   versa), the filter silently no-ops, exactly as observed.

---

## Acceptance criteria (please verify after the fix)
- `/shop?attribute_value=5-30` (Make = Ford) returns ~424 products / ~18 pages, and the
  "Ford" option shows selected.
- Two attribute filters combine (e.g. Make = Ford **and** Roof Height = High Roof).
- An attribute filter combines with a category (e.g. inside
  `/shop/category/.../paneling`, filtering Material/Brand narrows further).
- The sidebar selects work by click (not just by hand-edited URL).

---

## Why this matters / what it unblocks
We're rebuilding product findability. Working attribute filters let customers refine large
lists (e.g. 120 wall panels) by **material, brand, length, color** in the sidebar, and let
**vehicle** (Make/Model/Year/Roof/Wheelbase) work as combinable facets. Without this we're
forced to build deep, sprawling category trees as a workaround. Fixing the filter is the
single highest-leverage repair for the site.

---

## Notes / context for the developer
- Vehicle fitment lives in no-variant attributes: **Make** (id 5), **Model** (id 6),
  **Year** (id 2), **Roof Height** (id 3), **Wheelbase** (id 4), **Fuel** (id 8). These are
  populated across ~1,200 products and are intended to be shop filters.
- We have started a **category-based** workaround ("Shop by Vehicle" with nested
  Vehicle > Type categories) precisely because the attribute filter is broken. Once the
  filter works, much of that can be simplified.
