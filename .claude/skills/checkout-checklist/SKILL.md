# Checkout Checklist

Generate a build-specific vehicle checkout inspection sheet from an Odoo sales order.
Use when Esme (or whoever runs checkout) needs a checklist for a finished build, or when
the user says "make a checkout sheet for S0xxxx".

## Why this exists

Checkout today is a visual inspection with no list. The inspector is not a technician, so
"does it look right" is not a question they can answer. Every line on this sheet must be
verifiable by a non-technical person with a clear pass or fail.

The sales order already contains the scope. The `line_section` headers and the `Includes:`
notes are the inspection list. This skill transforms that into something you can walk.

## Source data

Read from `odoo-prod`:
- `sale.order` — `name`, `so_name`, `partner_id`, vehicle fields (`x_studio_year`,
  `x_studio_make`, `x_studio_van_type`, `x_studio_wheel_base`, `x_studio_roof_height`, `x_vin`)
- `sale.order.line` — all lines, ordered by `sequence`. The `line_section` names give you the
  systems. The `line_note` "Includes:" text gives you the parts and the install locations.

## The transform (this is the whole point)

**Do not transcribe the sales order.** The SO is organized by system, because that is how it
was quoted and purchased. An inspector walks a van by location and then tests by function.
Reorganize into:

- **A. Before you start** — VIN, mileage, keys, paperwork packet, owner manuals, weight ticket
- **B. Exterior walk-around** — everything mounted on the outside and the roof
- **C. Interior, streetside front to rear** — in the physical order they will encounter it
- **D. Interior, curbside front to rear**
- **E. Interior, general** — liner, floor, lighting, handles, seat swivels
- **F. Power function test** — always in this order: shore, then generator, then inverter only,
  then protection devices
- **G. Systems function test** — HVAC, ventilation, water, refrigeration, anything with a switch
- **H. Photos required**
- **I. Sign-off**

## Writing the lines

Every line gets three things:

1. **What to check.** Name the item the way it appears on the van, not the way it appears on
   the purchase order. "The awning" not "[08540C01R] Awning, Fiamma F65 Eagle 400".
2. **How you know it passes.** Concrete, observable, and written for someone who has never
   installed one. Not "verify GFCI operation" but "Press TEST. The RESET button pops out and
   the outlet goes dead. Press RESET. The outlet works again."
3. **Photo required, yes or no.** Photograph anything that will be hidden later, anything with
   a serial number, and anything a customer might dispute.

Rules:
- **No judgment calls.** If a line requires an opinion, either rewrite it as a measurement or
  move it to the technician's work order where it belongs.
- **Numbers where a number settles it.** Refrigerator holding between 2 and 8 degrees C. Freezer
  between -30 and -10 degrees C. Battery monitor reading above 13 volts on shore.
- **Failures get a location, not just a flag.** Leave room to write where the problem is.
- **Order matters in section F.** Test each source in isolation before testing transfer, or a
  failure in one source hides behind another.

## Output

A printable sheet. The inspector works from paper at the van, so:
- Real checkboxes with room to tick
- Notes column wide enough to write in
- Page breaks between major sections
- Sign-off block with name, date, and a line for the person who fixes anything that failed

Publish as an artifact so it can be shared and printed, and save the source file alongside the
project. Name it `<SO number> Checkout.html`.

## After the sheet

A completed checkout sheet is data, not paper. Two follow-ups:
- Anything that failed goes back to the floor with a location, and gets re-checked before delivery.
- Repeat failures across builds are the ranking list for which SOP to write next. Log them.

## Where this goes next

This sheet is an interim. The real home for these checks is Odoo Quality, as control points on
the operation with test types `Pass/Fail` and `Take a Picture` instead of `Instructions`. The
module is installed and about thirty points are already configured in the weakest mode. See
`references/odoo-known-issues.md`. Build the sheet now, migrate it into quality points as the
standard operation library lands.
