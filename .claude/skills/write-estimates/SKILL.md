---
name: write-estimates
description: Draft a sales quote (estimate) in Odoo for Volition Components, in Adan's standard format. Use when Adan says "draft an estimate / quote for [customer]" with a list of parts or a build scope.
---

# Write Estimates (Odoo)

Draft a `sale.order` in Odoo that mirrors Adan's format and pricing conventions.
Estimates are van-upfit quotes (shelving, ladder racks, partitions, flooring,
refrigeration, lighting, specialized builds).

## Connection
Use the **`odoo-prod`** MCP tools. That is the live system of record. The plain
`odoo` instance is a stale sandbox (its SO sequence lags, e.g. stops ~S01213) and
creating there is useless. Re-resolve product/partner IDs in `odoo-prod` (IDs can
differ between instances). Writes go through the guarded flow:
`preview_write` -> `validate_write` -> `execute_approved_write` (confirm=true).
Note: `validate_write` must run in the same session before `execute_approved_write`,
or the approval token is rejected. Always show Adan a readable preview and get an
explicit "go" before creating.

## Inputs to gather (ask only for what's missing)
- **Customer** (and contact person)
- **Project name** (goes in the `so_name` field, labeled "Project Name" on the SO)
- **Vehicle** (year/make/model/wheelbase/roof) when relevant to part fit
- **Line items**: parts/products, quantities, and positioning notes
- **Pricing**: default is Odoo catalog pricing (the product `list_price`)

## Process
1. **Resolve the customer.** `search_records` on `res.partner` by name. Adan's
   quotes attach to a **person contact** (a child of the company), e.g.
   "Phil Long Ford Denver, Troy D Hines". Confirm the contact exists; if only the
   company exists, ask before creating a new contact.
2. **Match products.** `search_records` on `product.product` by `default_code`
   (the part number) or `name`. Read `list_price` for catalog pricing. Prefer
   looking products up live over assuming IDs.
3. **Handle parts not in Odoo.** Use the Misc product `[Misc] Special Order Part
   Non Inv` and put the **cost in the quantity field** with `price_unit` = **1.67**
   (this marks it up for ~40% margin). Same trick for shipping: `[S&H] Shipping`
   with cost in qty and `price_unit` = **1.11**.
   - **Make Misc lines look like catalog parts.** Set the line `name` to
     `[SKU] Nomenclature` so it reads exactly like a real product line. Find or
     generate a real-looking SKU (vendor model number) and a name in our
     nomenclature (Noun first, then brand, then specs, comma-separated, e.g.
     `[ORI121217050] DC-DC Charger, Victron Orion XS, 12/12-50A, 600W, Bluetooth`).
     Research the vendor page when needed to get the real model number. Don't leave
     the default "[Misc] Special Order Part Non Inv" as the visible name.
4. **Build the lines in Adan's format**, as an `order_line` list of Odoo command
   tuples `[0, 0, {...}]`, grouped by package. **Order within each section is strict:**
   - **Section header**: `{"display_type": "line_section", "name": "UPPERCASE PACKAGE NAME"}`
   - **Includes note**: `{"display_type": "line_note", "name": "Includes:\n- ...\n- ..."}`.
     Order inside the note: **parts first** (each as `[SKU] Name`, copied from the
     product/Misc line name, prefix `(QTY n)` when >1), **then the labor
     description(s)** (copied from the labor line names), **then freight** if any
     (e.g. "Freight to Volition Components").
     - **If a line is a package / kit (a product with a BOM), expand it.** Don't list a
       bare package SKU in the note. Read its `mrp.bom` / `mrp.bom.line` (BOMs link by
       `product_tmpl_id`, not `product_id`) and list the **actual component parts**, each
       as `[SKU] Name` with `(QTY n)` when qty > 1. When a section combines two packages
       (e.g. shelving + accessories), group the parts under a sub-label per package
       ("Shelving Package:", "Plumbing Accessories Package:"). **Exclude internal cost
       components** `[PC] Parts Charge` and `[S&H] Shipping` from the list.
     - **Add a technician install description** after the parts: shelf **locations**
       (e.g. 96" shelf streetside / 60" shelf curbside) and where each accessory mounts,
       written so the techs can build from it. Pull the wording from a **prior order of the
       same package** (search line notes for the package SKU; good ones: S01039, S01132) or
       the package's attached picture, and **trim to only the parts actually in this BOM**
       (don't carry over steps for parts this build doesn't include).
     - **No tariff verbiage in the note.** A tariff is charged as its own priced `[TARIFF]`
       line, never described in the Includes text. Likewise **no internal-only notes** like
       free-shipping thresholds ("free, Westcan free shipping over $3,500").
   - **Product lines** (the parts), each `{"product_id": <id>, "name": "[code] Description", "product_uom_qty": <qty>, "price_unit": <list_price>}`
   - **Install labor lines** (`[LABORMTO]` id 2515), one per task, with the
     **install/positioning description in the `name`**, qty = hours.
   - **Freight last** (`[S&H] Shipping`), after the labor lines, only if a cost is given.
   Pattern per section: **section → Includes note → parts → labor → freight.**
   Good references: S01130, S01250 (Tofwerk).
5. **Set the project name**: top-level `so_name` = the project name.
6. **Preview to Adan** (human-readable table + total). Flag: no freight line unless a
   cost is given; tax is $0 on API-created drafts (verify fiscal position, dealers are
   usually resale-exempt).
7. On "go": `validate_write` then `execute_approved_write` (confirm=true).
8. **Read the record back** (`name`, `so_name`, `partner_id`, `amount_total`, `state`)
   and report the new SO number. Leave it in **draft**; never confirm or send.
9. **Create the CRM opportunity and link it** (see Opportunities section). Every SO we
   write gets a matching opportunity, linked both ways.
10. **Post product links to the SO chatter — Misc parts only.** Only for products
    **not already in Odoo** (the `[Misc] Special Order Part Non Inv` lines). Catalog
    products (real `product_id`) are already in the system, so skip their links. For each
    Misc part that has a source/vendor URL, post a chatter note with a short descriptor
    plus the link, one per line, e.g. `24 Inch 12V TV: <url>`. See Posting product links
    below for the method.

## Posting product links (chatter)
`chatter_post` escapes HTML (links show as literal text) and `message_post` via
`execute_method` is blocked as a side-effect method. To get clean clickable links,
**create a `mail.message` record directly** through the guarded write flow
(`preview_write` -> `validate_write` -> `execute_approved_write`):
- `model` = "sale.order", `res_id` = the SO id, `message_type` = "comment",
  `subtype_id` = 2 (Note), `body` = real HTML.
- Body pattern: a `<strong>Product links</strong>` heading, then one `<p>` per product:
  `Descriptor: <a href="URL">URL</a>` (descriptor like "24 Inch 12V TV"). See [[odoo-chatter-formatting]].

## Install / labor products (this Odoo instance)
Look up live when unsure; these are the common ones:
- `Shelving Installation- 1 Shelf MTO` (id 2857, $340) — one shelf, one side
- `Shelving Installation- 2 Shelf MTO` (id 2858, $680) — two shelves, one side
- `[LABORMTO] Labor Installation MTO` (id 2515, $154/hr) — qty = hours
- `[LABPART] Basic Partition Installation MTO` (id 2855)
- `[PREFABFLOOR] Flooring Installation` (id 3883)
- `[LABLRSD] Ladder Rack Installation, Single Drop Down` (id 3949)
- `[Misc] Special Order Part Non Inv` (id 2456) — cost-in-qty x 1.67
- `[S&H] Shipping` (id 2498) — cost-in-qty x 1.11
- `Discount` (id 2909) — negative `price_unit`

## Key fields (sale.order)
- `partner_id` — customer (use the person contact's ID)
- `so_name` — **"Project Name"** (custom char field)
- `client_order_ref` — Customer Reference (optional)
- `order_line` — one2many, build with `[0, 0, {...}]` command tuples

## Vehicle fields (sale.order, all selection dropdowns)
Set these when Adan gives the vehicle. They are selection fields, so use the exact
option string (pull options via `get_model_fields` if unsure):
- `x_studio_year` — "Year" (e.g. "2026", options 2015-2027)
- `x_studio_make` — "Make" (Ford, Mercedes-Benz, Ram, Chevrolet, GMC, Other)
- `x_studio_van_type` — **"Model"** (Connect, Transit, Metris, Sprinter, Savana, Express, Promaster, Promaster City, Other)
- `x_studio_wheel_base` — "Wheel Base" (e.g. `148" WB`, `144" WB`, `159" WB`, ...)
- `x_studio_roof_height` — "Roof Height" (LR, MR, HR, SHR)
- `x_studio_vin` / `x_vin` — VIN (char); `x_studio_customer_request_date` — "Customer Vehicle ETA"

## Opportunities (CRM)
Every SO needs a matching `crm.lead` opportunity, linked both ways.
- **Create** `crm.lead`: `name` = project name (= `so_name`), `type` = "opportunity",
  `partner_id` = same contact as the SO, `expected_revenue` = SO total, `user_id` =
  salesperson (Adan = 6, Tony = 7), `team_id` = Sales (1), `stage_id` = **Proposition (3)**
  for a freshly written quote, plus `contact_name` / `email_from`.
- **Link the SO**: set `opportunity_id` = the new lead, and `origin` ("Source Document",
  on the Other Info tab) = the project name. Both appear on the SO's Other Info tab.
- Stages: New(1), Qualified(2), Proposition(3), Approved – Final Prep(10), Won(4),
  Off-Site(11), In Production(8), Prod. Complete(9), Invoiced(7), Delivered & Unpaid(5),
  Archive(6).

## Material note (don't mislabel)
Section headers and notes must reflect the **actual material**. Don't default to
"aluminum." Known: **Knapheide = steel modular shelving**; **Westcan = aluminum**.

## Format references
Good examples of Adan's shelving/upfit structure: **S00918, S01132, S01066**.
A larger specialized build for section/note style: **S01285**.
**BOM-expanded package note** with grouped parts + technician install description:
**S01039** (shelving + accessories), and **S01316** (Sprinter Plumber's Pkg, cleaned up).
First skill-built estimate: **S01289** (Fire Sale Transit, Phil Long / Troy D Hines).

## Notes & caveats
- Catalog pricing comes from `list_price`. A customer pricelist may discount it; if
  Adan wants pricelist pricing, flag it (API-set `price_unit` overrides the pricelist).
- Taxes do not auto-apply on API create. Confirm the fiscal position on the draft.
- Keep tone/format consistent with [[comm-style-no-em-dashes]] (no em dashes).
