# Phoenix Expansion — Proposal Evaluation

_Status: Under evaluation. Last updated: 2026-07-13._

Brian Bearden sent a proposal (July 5, 2026) to open a second Volition location in
Phoenix as a 50/50 partnership, with him as operating partner. This folder holds our
analysis of it, pressure-tested against real Volition financials.

## The proposal (Brian's ask)
- **Structure:** New legal entity under the Volition Components brand. 50% Volition / 50% Brian Bearden.
- **Roles:** Volition contributes brand, vendor relationships (Legend, Knapheide, Prime Design, Zanotti), SOPs, pricing, training, oversight. Brian contributes his share of capital, day-to-day GM leadership, and dealership relationships across the Phoenix metro.
- **Location:** Flex industrial, 8,000–15,000 sq ft, West Valley (low rent, I-10/Loop 303).
- **Year 1 target:** 175 vehicles, ~$1.23M revenue (ramping to ~5 vehicles/week by Month 12).
- **Startup capital:** Worst-case ~$801k ($651k–$1.1M range), driven almost entirely by tenant improvements ($150k–$600k).
- **Governance:** Monthly financials, quarterly strategic review, joint approval on major spend. Exit/buyout left undefined.

Source docs (Brian's): Google Drive folder "Phoenix Expansion" — `Volition Components_Phoenix_Expansion_Blueprint.pdf` and `Volition_Phoenix_Financial_Model (Assumptions).xlsx`.

## What we verified (Odoo FY2024–25, QuickBooks 2021–23)

**Broomfield is growing and margins are improving.**
- Confirmed orders: **$1.45M (2024) → $1.80M (2025)** untaxed. Recognized/posted revenue $1.31M → $1.58M.
- Gross margin (accounting): **56.9% (2024) → 59.8% (2025)**, improving. A conservative per-part calc lands ~41%; the gap means some material cost isn't posting to COGS and is worth reconciling.
- Operating income: **$123k (2024) → $183k (2025)**, after ~$218k of owner comp.
- Order count 2025: **217 confirmed sales orders** (the official 4DX actual; Odoo query returns ~222 depending on order-type filters). **260 is our 2026 goal, not a 2025 actual.** Brian built his Broomfield benchmark ($1.83M = 260 × $7,024) on our 2026 target, so he is benchmarking Phoenix's Year 1 against a number the flagship has not yet reached.

**Average ticket, de-skewed (Adan's point, confirmed):**
- Raw average across 222 orders: $8,110.
- **69 orders (31% of count) are sub-$1,000 warranty / online / service tickets = $21,556 total (1.2% of revenue).** They drag the mean down.
- **Real upfit jobs ($3k+): 121 orders, $1.72M, avg ~$14,208/order.** Brian's $7,024/vehicle is per-vehicle and is conservative, not optimistic.

**Cost assumptions, re-graded on current data:**
- Labor billing rate: ~$137.50/hr (2025). Brian's $140 checks out (rate was raised from the old $125).
- Tech wages: $25/hr (tech), $23/hr (apprentice), ops manager (Constance) $35.50/hr (~$74k/yr). Brian's $26/hr and $78k ops-manager line are well-calibrated.
- **Insurance:** New agent brought it from $30k (2025) to **~$16.6k annualized (2026 YTD)**, which now matches Brian's $16.8k. (Earlier flagged as underbudgeted; corrected.)
- Rent: Broomfield ~$70.6k (2025) → ~$80k annualized (2026). Brian's Phoenix $120k is ~50% higher, defensible for a fresh lease.
- Utilities: Broomfield ~$7–8k/yr. Brian's $24k looks high even with Phoenix cooling.
- Inventory on-hand: ~$112k (Brian cited $83,611 EOY, plausible).

## Assessment
The unit economics in Brian's model are largely sound and well-matched to how Broomfield
runs today. The first-pass criticisms of his cost assumptions mostly evaporated once we
used 2024–25 actuals instead of 2021–23. The proposal really comes down to three questions:

1. **The ramp.** Broomfield took three years and a money-losing 2022 to reach ~$1.3M, and did **217 orders in 2025** (its 5th year). Phoenix's Year-1 target of 175 vehicles / $1.23M is ~80% of mature-Broomfield volume in month 12, and it is benchmarked against our **2026 stretch goal (260)**, not proven performance. That only works as a genuine warm start (brand, systems, supplier pricing, and Brian's dealer pipeline). His dealer pipeline is asserted but not quantified. This is the whole ballgame.
2. **Capital sizing.** $801k worst-case, mostly tenant improvements, against a Broomfield that opened on ~$70k owner capital and zero capitalized TI. Realistic startup is likely ~$275–400k if Phoenix leases move-in-ready space. The real need is working-capital runway, not build-out.
3. **Deal terms.** 50/50 with a mostly-intangible Volition contribution, undefined exit/buyout/valuation, and Volition's brand/reputation on the line in a market it can't easily supervise from Colorado.

## Pro forma tool
Interactive Year-1 model (flex ramp, margin, rent, TI, price/vehicle, partner salary):
**https://claude.ai/code/artifact/0699f8ba-c4c6-4ed1-a100-914702a6d4c6**
Local copy: `phoenix-proforma.html` (in this folder).

Default case (52% margin, Brian's ramp): ~+$149k Year-1 operating income after Brian's
salary, cumulative break-even ~Month 6, deepest cash dip ~$31k, right-sized startup ~$273k
(~$137k/partner). The sensitivity grid shows the outcome is set almost entirely by ramp
and margin; a conservative ramp at 45% margin turns it into a Year-1 loss.

## Open questions / next steps
- [x] ~~Confirm what "260 vehicles" counts.~~ **Resolved: 217 = 2025 actual orders, 260 = 2026 goal. Brian benchmarked on the goal, not the actual.**
- [ ] Get Brian to **quantify the dealership pipeline**: which dealers, expected referral volume, anything in writing.
- [ ] Re-frame the capital ask around working-capital runway; share Broomfield's real (lean) buildout history.
- [ ] Give Brian our real cost structure so his pro forma reflects our economics; require an honest month-by-month showing the Year-1 loss and cumulative break-even.
- [ ] Nail down governance: exit, buyout, valuation formula, brand-standard enforcement.
- [ ] Reconcile the gross-margin gap (accounting ~60% vs per-part ~41%) in Odoo.

## Data provenance
- Odoo production (odoo-prod MCP): `sale.order`, `sale.order.line`, `account.move.line`, `hr.employee`, `stock.quant`, FY2024–25.
- QuickBooks exports (Google Drive): P&L / Balance Sheet / Trial Balance / Cash Flow / Payroll 2021–23. Note: the invoice-level CSV exports are truncated at 2022-04-01 despite filenames; summary statements are complete.
