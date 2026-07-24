# Vendor Rules

Per-vendor freight, tariff, and build rules that affect quoting. Keep this current as terms change.

_Harvested from assistant memory 2026-07-16. See `.claude/skills/write-estimates/SKILL.md` for how
these get built into a quote._

## Materials, at a glance

- **Knapheide** = steel modular shelving
- **Westcan** = aluminum

Don't default a section header to "aluminum." Check the vendor.

## Westcan

### Freight

By order total:

| Order total | Freight |
|---|---|
| $1,000 to $3,499.99 | 15% of order total (e.g. $1,000 order = $150 freight) |
| $3,500 and over | Free |
| Under $1,000 | Not specified. Ask. |

Import fees and tariffs are **separate** from freight and charged on top.

On a quote over $3,500 Westcan's own freight is free, so a shipping line would only be Volition's
pass-through or handling. Confirm with Adan rather than auto-applying 15% on large orders.

### Tariff

**22% of Westcan material cost**, as its own `[TARIFF]` line (product id 4161).

Material cost = the sum of `standard_price` for the Westcan-purchased BOM components only.
Exclude the non-Westcan strut channel (`[616013120262]`), `[PC] Parts Charge`, and `[S&H] Shipping`.

Build the line cost-in-qty style: put `0.22 x material_cost` in the **qty** field, and set
`price_unit` to **1.12** (12% markup). One TARIFF line per package or section.

Validated against S01316, built into S01319.

## Legend Fleet

### Freight

Free over **$3,500 in cost** (our cost, not list). Under that, freight applies. Get the number from
Legend.

Note the threshold is on **cost**, unlike Prime Design's $800 which is on the order. On a typical
full interior kit (walls + ceiling + doors + flooring) for a full-size van, cost clears $3,500 and
freight is free.

## Prime Design

### Freight

Free over $800. Otherwise $95.

### ProMaster City double drop down rack

The old single-SKU ErgoRack double drop down kit (catalog **VRR-PC11-HM**, id 3173, vendor
PD-VRR-PC11-M) is **obsolete**. Build it from components instead. Quantities per the Prime Design
Quick Order:

| SKU | Part | Qty | Odoo id | List |
|---|---|---|---|---|
| FEA-0024 | Rotation Feature, Drop Down, Universal | 2 | 4242 | $1,274.60 |
| FEA-0025 | Ratchet Handle, Extendable | 1 | 4162 | $255.20 |
| FEA-0027 | Drive Shaft Assy, Safe Fleet, Universal [6FT-8FT] | 1 | 4163 | $308.00 |
| CBR-0001 | Crossbar Feature 62 in | 1 | not in catalog | Misc, cost-in-qty x1.67 (cost $226.38 to $378.05) |
| FBM-1013-BLK | FBM Universal, 2 CBR, ProMaster City | 1 | 2562 | $486.52 |

Labor: **LABLRDD** Ladder Rack Installation, Double Drop Down (id 3950, $595).

Catalog list prices already include the standard 1.67x markup on Prime Design dealer cost, so
don't mark them up again.

## Pricing patterns (quick reference)

- **Catalog pricing** = the product's `list_price`.
- **Parts not in Odoo:** use `[Misc] Special Order Part Non Inv`. Cost goes in the **quantity**
  field, `price_unit` = **1.67** (roughly 40% margin).
- **Shipping:** `[S&H] Shipping`, cost-in-qty, `price_unit` = **1.11**.
- **Tariff:** cost-in-qty, `price_unit` = **1.12** (see Westcan above).

The cost-in-qty pattern exists so the margin shown on the SO stays accurate. Don't put a dollar
figure in the price field for these lines, it skews the margin.
