# Vehicle Cascade: proposed Model → Roof Height / Wheelbase mapping

_Draft for Adan to verify. Once approved, this populates the model-dependent Roof Height and Wheelbase filters on the sales-order cascade (staging first)._

Roof codes: LR = Low, MR = Medium, HR = High, SHR = Super High.
(Mercedes "Standard Roof" is mapped to LR.)

## Proposed mapping

| Make | Model | Roof Heights | Wheelbases |
|---|---|---|---|
| Ford | Transit | LR, MR, HR | 130", 148", 148" Ext |
| Ford | Transit Connect | LR | 104" (SWB), 120" (LWB) |
| Ford | Explorer | LR | ❓ (SUV, not a standard van WB) |
| Ford | Escape | LR | ❓ (SUV, not a standard van WB) |
| Mercedes-Benz | Sprinter | LR, HR, SHR | 144", 170", 170" Ext |
| Mercedes-Benz | Metris | LR | ❓ 135" (factory is ~126", not in current list) |
| Ram | Promaster | LR, HR | 118", 136", 159", 159" Ext |
| Ram | Promaster City | LR | 122" |
| Chevy | Express | LR | 135", 155" |
| GMC | Savana | LR | 135", 155" |
| Nissan | NV | LR, HR | ❓ (factory ~146", not in current list) |
| Nissan | NV200 | LR | ❓ (factory ~115", closest listed is 118") |

## Flags / things to confirm

1. **Explorer & Escape** are SUVs and had 0 products in the catalog. Do you even want them selectable, or drop them from the model list? If kept, what wheelbase (if any) do you want shown?
2. **Metris** wheelbase: factory is ~126", which isn't in the current list. Add "126\" WB", or use 135"?
3. **Nissan NV** wheelbase: factory ~146", not listed. Add "146\" WB"?
4. **Nissan NV200** wheelbase: factory ~115", not listed. Add "115\" WB" or accept 118"?
5. Any wheelbase in the master list not used by any model can be dropped from the picker (currently unused-looking: 120" appears only on Transit Connect; 104" only Transit Connect; confirm the rest).
6. **Roof heights:** only Transit uses MR (Medium). Confirm no other model needs MR. Confirm Sprinter is the only SHR.

## Year (separate, not model-dependent)

Flat validated dropdown, 2015–2027 (same values as today). Not filtered by model. Confirm that's fine, or if you want a narrower range.

## What happens after you verify

Once you correct this table, I build in one pass (staging):
- Master tables for Roof Height, Wheelbase, Year + seed values.
- Model links (which roofs/wheelbases each model offers) per this mapping.
- Sales-order fields: Roof Height + Wheelbase filtered by the selected Model; Year dropdown.
- Update the SO form: show the new validated fields, hide the old Studio Roof Height / Wheel Base / Year.
