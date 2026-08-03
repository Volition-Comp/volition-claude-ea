# VIN Decoding for Quotes

How to get year / make / model / wheelbase / roof off a VIN before writing an estimate.
Getting this wrong changes which shelving package fits, so decode it properly, don't infer.

## Ford Transit: use the body code, not a generic decoder

**The body code is VIN digits 5-7.** Decode it with Ford Pro's tool:

https://www.fordpro.com/en-us/tools/orders/ordering-production/transit-body-decoder/

That gives series, roof height, and wheelbase/length directly. It is the authoritative
source. Use it for every Transit.

Worked example: `1FTBR2C86TKA83440` -> digits 5-7 = **R2C** = **Transit 250, Medium Roof,
148" WB (Long)**. Not extended.

### Don't trust NHTSA vPIC for Transit wheelbase or length

The free NHTSA decoder (`vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/<VIN>?format=json`) is
fine for year, make, model, series, body class, GVWR, and plant. It is **not** reliable for
wheelbase or length on a Transit:

- `WheelBaseFrom` / `WheelBaseTo` come back as a **range for the whole model line**
  (e.g. 130 to 148), not the value for that VIN. Reading the high end as the answer is wrong.
- `Trim` and `Trim2` can contradict each other. The example VIN above returned
  Trim = "Medium Roof", Trim2 = "EL", and **Medium Roof EL is not a configuration Ford
  builds.** On the 2026 Transit, Extended Length is High Roof only.

If you only have NHTSA output, treat wheelbase and length as unknown and go to the body
decoder.

## Roof / wheelbase feed the Odoo vehicle fields

Once decoded, set the `sale.order` vehicle fields (`x_studio_year`, `x_studio_make`,
`x_studio_van_type`, `x_studio_wheel_base`, `x_studio_roof_height`, `x_vin`). Wheel base
options are exact strings, e.g. `148" WB` vs `148" WB Extended-Length`. See
`.claude/skills/write-estimates/SKILL.md`.

Roof and length drive the Westcan shelving package: `ABP9660` (96" + 60") is 148" WB MR/HR,
`ABP6060` (three 60") is 148" WB EXT. Picking the wrong one mis-quotes the job.
