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

## Lead times (as of 2026-08-03)

Quote these to customers. Confirm before committing on a large or dated order.

| Vendor | Lead time |
|---|---|
| Prime Design | ~2 weeks |
| Westcan | 4 weeks+ (currently the long pole on any shelving job) |
| Packd | ~1 week |

## Packd

Being evaluated as an alternative to Westcan on shelving: **lower priced and ~1 week lead time**
against Westcan's 4 weeks+. Not yet in Odoo and not yet used on a job.

Quote Westcan, then flip to Packd at order time if the deal lands. That keeps the quote on a
vendor we've priced and built before, and captures the cost and schedule upside once there's a
PO. Don't quote Packd pricing until we've run one through.

## Legend Fleet

### Freight

Free over **$3,500 in cost** (our cost, not list). Under that, freight applies. Get the number from
Legend.

Note the threshold is on **cost**, unlike Prime Design's $800 which is on the order. On a typical
full interior kit (walls + ceiling + doors + flooring) for a full-size van, cost clears $3,500 and
freight is free.

## ProDriven (Weather Guard)

ProDriven is Weather Guard's dealer portal and runs cheaper than Meyer on the same Weather Guard
part numbers. On the 600-8413L HVAC/Mechanical package (July 2026): ProDriven $3,854.30 vs Meyer
$4,621.79, a $767 spread. Check ProDriven first on any Weather Guard line.

### Freight

Free over **$4,000** on the order. Consolidate the whole Weather Guard content of a build onto one
ProDriven order to clear it (shelving package plus racks usually does it on its own).

### Van packages include the mounting kit

The 600-series van packages ship with the vehicle-specific Van Shelf Mounting Kit already in the
box (148" WB = 975104-3-01, low-roof 148 = 975102-3-01, 130 = 975101-3-01). **Don't order it as a
separate line.** Put a note on the purchase line so nobody buys it twice. There is no unistrut in
these packages, the mounting kit is the wall attachment.

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

## Espar heaters: B2 on a Transit, not D2

**Ford stopped building a diesel Transit years ago**, so a Transit coming through the shop is
gas (or an E-Transit). The Espar heater on a Transit is therefore almost always the **gasoline
B2/B2L**, not the diesel D2.

Product: `Gas Heater Package w/Install, Espar, B2L 2KW, Ford Transit Gas/ProMaster/Sprinter`
(prod id 2689). Includes install labor. Fuel pickup plumbs to the vehicle's gasoline tank.

Notes and specs from customers, sales, or the shop often say "D2" out of habit, since that was
the default for years. **Read it as the model family, not the fuel.** Confirm the fuel on the
actual van before ordering, but default to B2 on a Transit. Sprinter and ProMaster still come
both ways, so check those.

## Where the freight line goes

Freight is charged as its own `[S&H] Shipping` line inside a **pricing section**, never as a
standalone FREIGHT section. Which section it lands in is a judgement call, and the rule is:

**Put the bulk of the freight on the largest, most relevant item in the shipment.**

The reason is how it reads to the customer. Freight parked at the bottom of the quote falls into
whatever section happens to be last, and a small section then carries an absurd-looking number.
On S01447 the last section was two 8" running board kits. With $1,665 of freight sitting under it,
the section read $3,357 for two steps. Any person reading that thinks it's ridiculous. Moved onto
the floor (the largest line in the shipment), it disappears into a number that makes sense.

Splitting across sections is fine, and is the right call when the parts genuinely come from
different vendors. S01447 ships the floor, seats, and Shift N Step hardware from Fenton, but the
Braun lift comes direct from Braun, so it carries its own freight line:

| Section | Freight cost | Covers |
|---|---|---|
| FLOOR & SEATING | $1,250 | the Fenton shipment |
| SHIFT N STEP LIFT | $500 | the Braun lift, direct from the manufacturer |

When you split, the section that holds the biggest item takes the larger share. An even split
(e.g. $750 / $750) is also fine when the two shipments are comparable.

Keep "Freight to Volition Components" as the last bullet in the Includes note of any section that
carries a freight line, and leave it out of sections that don't.

## Pricing patterns (quick reference)

- **Catalog pricing** = the product's `list_price`.
- **Parts not in Odoo:** use `[Misc] Special Order Part Non Inv`. Cost goes in the **quantity**
  field, `price_unit` = **1.67** (roughly 40% margin).
- **Shipping:** `[S&H] Shipping`, cost-in-qty, `price_unit` = **1.11**.
- **Tariff:** cost-in-qty, `price_unit` = **1.12** (see Westcan above).

The cost-in-qty pattern exists so the margin shown on the SO stays accurate. Don't put a dollar
figure in the price field for these lines, it skews the margin.
