# Volition Components — Labor Time Standards (Draft)

_Data-derived starting point for the VC Standard Labor Manual (VCSLM)._
_Prepared for Adan / Tony. Last updated: 2026-07-08._

## What this is

Standard labor **hours** per operation, reverse-engineered from our own Odoo sales
history, now mapped to Tony's operation-code scheme. This is the "seed" data for the
Standard Labor Manual: instead of starting from scratch, these numbers come from what
we've actually been quoting and building.

## Method

- Source: every `[LABORMTO] Labor Installation MTO` line on our sales orders (hourly labor
  product, **qty = hours**, billed at **$154/hr**), plus the fixed-price labor bundles
  (shelving, partition, ladder rack, flooring, window).
- Scope: confirmed orders (`state = sale`) and live quotes (`sent`/`draft`). **Cancelled
  quotes excluded** — they double-count re-quotes and skew the numbers.
- Pool size: ~8,100 labor-hours on confirmed orders, ~9,700 including live quotes, across
  hundreds of line items back to S00013.
- For each operation I read the actual task descriptions and normalized to a per-unit
  standard (e.g. "grille warning lights (2) = 2 hrs" → 1 hr per light).

**Important caveat:** these are *quoted/sold* hours, i.e. how we've priced the work. They
are not yet *measured* technician clock-times (that's Phase 2 of the manual). But quoted
hours are exactly what an estimator needs, and they're internally consistent, so this is a
legitimate v1 estimating standard.

## Operation code scheme

Tony's proposal published these codes: PW-300, EL-400 / 401 / 407, SR-500 / 501, RF-700,
HV-800, SH-900, MB-1000. Those are preserved exactly below. I extended the same pattern
(2-letter prefix + a 100-block per category, with gaps between codes for future additions)
to cover all 14 chapters:

| Ch | Category | Prefix | Block |
|---|---|---|---|
| 1 | General Information | GN | 100 |
| 2 | Electrical Systems | ES | 200 |
| 3 | Inverters & Shore Power | PW | 300 |
| 4 | Emergency Lighting | EL | 400 |
| 5 | Sirens & Control Systems | SR | 500 |
| 6 | Communications | CM | 600 |
| 7 | Refrigeration Systems | RF | 700 |
| 8 | HVAC Systems | HV | 800 |
| 9 | Shelving & Cabinets | SH | 900 |
| 10 | Interior Components | IN | 1100 |
| 11 | Windows | WN | 1200 |
| 12 | Seating & Mobility | MB | 1000 |
| 13 | Exterior Accessories | EX | 1300 |
| 14 | Quality Control | QC | 1400 |

Note: Seating & Mobility keeps the **1000** block because Tony already published MB-1000,
so it sits numerically ahead of Interior (1100) / Windows (1200). Easy to renumber if you'd
rather it run in strict chapter order. Everything else follows chapter sequence.

## Confidence legend

- **A** = rock-solid. Many orders, tight clustering. Use as-is.
- **B** = good. Several orders, minor spread. Use, refine over time.
- **C** = thin. 1–3 data points or wide range. Treat as a placeholder to validate.

Rate used for price = **$154/hr**. Codes marked ✓ are Tony's published codes.

---

## Chapter 2 — Electrical Systems

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| ES-200 | Isolator + inverter, standard reefer-van package | 2.5 | $385 | **A** | Our single most repeated electrical job. 30+ orders, almost all 2.5. Isolator at OEM battery, power to cargo wall, inverter mounted, on/off with engine. (Bridges into ch.3 — cross-ref PW.) |
| ES-205 | Secondary / auxiliary battery + isolator relay + fusing | 8.0 | $1,232 | **A** | Consistent 8 hrs (S01041, S01046, S01130). Battery box, relay, breakers, 2/0 wire. |
| ES-210 | Aux-battery power / ground upgrade (heavier gauge) | 3.0 | $462 | B | S00742, S00747. |
| ES-215 | Breaker box + breakers + ignition on/off wire | 3.0 | $462 | B | S00155, S00247. |
| ES-220 | Low-voltage disconnect + relay | 1.5 | $231 | B | S00840. |
| ES-225 | Interior scene / work lights to D-pillars w/ LVD | 3.0 | $462 | **A** | Very consistent (S01031–S01078, S00810, S00815). |
| ES-230 | 120V→12V converter (shore charging) | 5.0 | $770 | B | Range 3–6 (S00800, S00806, S00991). |
| ES-235 | DC outlets, pair | 2.0 | $308 | C | S00620. |
| ES-240 | Reset / swap breaker (service call) | 0.5 | $77 | B | S00251, S00407. |

_Codes left open (250+) for manual examples not yet in our data as discrete lines: main
battery feed, fuse panel, relay panel, battery disconnect, power distribution, DC-DC charger._

---

## Chapter 3 — Inverters & Shore Power

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| PW-300 ✓ | Inverter, simple mount (2000W, single connection) | 2.0 | $308 | B | "Install 2K Jupiter inverter" (S00810, S00815); pedestal (S01130). |
| PW-305 | Inverter to partition / shelf end + battery + fuse + isolator + outlets | 4.0 | $616 | **A** | Consistent (S00610, S00742, S00747, S01041, S01046). |
| PW-310 | Inverter, larger cabin build (multiple + exterior outlets) | 6.0 | $924 | B | S00174, S00590, S00642. |
| PW-315 | Xantrex inverter/charger + shore power inlet | 5.0 | $770 | C | S01059. Add hours if reconfiguring existing breaker box (S01196 ran 16). |
| PW-320 | Shore power inlet (15A) | 1.0 | $154 | C | S00599, S00642. |
| PW-325 | Transfer switch (generator tie-in) | 8.0 | $1,232 | C | S00657, S00865. |
| PW-330 | Full generator install + transfer switch (whole project) | 33.0 | $5,082 | C | S00559. Specialized, quote per job. |

---

## Chapter 4 — Emergency Lighting

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| EL-400 ✓ | Warning light, single exterior head | 1.0 | $154 | **A** | mpower grille/bumper/topper lights at 1 hr each (S01273). |
| EL-401 ✓ | Warning lights, pair (e.g. mirror lights) | 2.0 | $308 | **A** | Per above. |
| EL-405 | Interior lightbar (windshield, split) | 2.0 | $308 | B | nFORCE (S01273), visor-mount (S00976). |
| EL-407 ✓ | Full-size emergency roof light bar + controller | 4.0 | $616 | B | Rear-roof lightbar + driver-accessible controller (S00991, S01059). |
| EL-410 | Strobe / warning set of 4 (2 grille + 2 rear) + switch | 6.0 | $924 | **A** | Very consistent (S00512, S00659–S00663). |
| EL-413 | Rear window / hatch lights, pair | 3.0 | $462 | B | S00976. |
| EL-415 | Quarter-glass lights, 4 on wedges | 6.0 | $924 | C | S00987. |
| EL-418 | Rocker / running-board courtesy lights, pair | 4.0 | $616 | C | SL Runner 72" (S01273). |
| EL-420 | Cargo / work LED light bars to roof bows (reefer set) | 2.5 | $385 | **A** | Extremely consistent, 30+ orders. Functional (not emergency) lighting — could move to Interior if you prefer. |
| EL-425 | Pre-wire lights + controller + speaker (harness run) | 5.0 | $770 | B | S00976. |
| EL-430 | Lighting "finals" (final hookup + programming pass) | 6.0 | $924 | B | S00696, S00813, S00814, S01028. |
| EL-440 | Full-vehicle light + siren package (loaded police/fire) | 16–24 | $2,464–$3,696 | B | S00806 (16), S01291 (24). Quote per scope. |

---

## Chapter 5 — Sirens & Control Systems

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| SR-500 ✓ | Install speaker (universal mount, engine bay) | 1.5 | $231 | B | S00976. |
| SR-501 ✓ | Install siren amplifier | 2.0 | $308 | C | Inferred from control-system installs; capture discretely going forward. |
| SR-505 | Siren + rocker switch + speaker (basic under-seat package) | 6.0 | $924 | **A** | Very consistent (S01161, S01187, S01188, S01192, S01193). |
| SR-510 | Siren only (100W, engine bay) | 4.0 | $616 | B | S00967, S01007. |
| SR-515 | Traffic advisor + controller | 6.0 | $924 | **A** | Consistent (S00512, S00659–S00663). |
| SR-517 | Traffic advisor, roof only (no controller run) | 2.0 | $308 | C | S00642. |
| SR-520 | Traffic controller, rear multi-head (6-head) | 3.0 | $462 | C | S01273. |
| SR-525 | Handheld remote siren / controller | 2.0 | $308 | C | 400-series (S01273). |
| SR-530 | Remove existing siren amp / module / panel (R&R) | 3.0 | $462 | C | S01273. |
| SR-535 | Final wiring, programming & function test | 2.0 | $308 | B | S00976. |
| SR-540 | Program controller + lighting functions (ConfigureIT) | 2.0 | $308 | C | S01273. |

---

## Chapter 6 — Communications

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| CM-600 | Antenna to roof + cable run (single, power/ground provided) | 2.0 | $308 | **A** | Extremely consistent, 15+ orders (S00042–S00490). |
| CM-605 | Prewire for antennas / COG (roof antennas → electrical box) | 4.0 | $616 | **A** | Consistent (S00696, S00813, S00814, S01028, S01140). |
| CM-610 | Radio + antenna + Cradlepoint install | 8.0 | $1,232 | B | S01140, S01285. |
| CM-615 | Cradlepoint unit + roof antenna | 5.0 | $770 | C | S00926. |
| CM-620 | Radio + Cradlepoint into custom enclosure + antennas | 12.0 | $1,848 | C | S00599. |
| CM-625 | Radio tray | 1.0 | $154 | B | S00549, S00558. |

---

## Chapter 7 — Refrigeration Systems

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| RF-700 ✓ | Engine-driven compressor + bracket (standard chassis) | 5.0 | $770 | B | Drain coolant, reroute lines (S00567, S00590, S01294). |
| RF-702 | Compressor + bracket, heavy chassis (extensive rerouting) | 16.0 | $2,464 | B | S01097, S01109. Flag chassis type in the estimate. |
| RF-705 | **Full refrigeration unit install** (condenser→rack→roof, evaporator→interior, hoses, evac + test, charge + commission) | 30.0 | $4,620 | **A** | Rock-solid flagship reefer job (S01097, S01109, S01158, S01294). |
| RF-707 | Full reefer install, container variant (condenser on sidewall) | 24.0 | $3,696 | C | S00636. |
| RF-710 | Condenser roof-mount bracket, fabricate | 10.0 | $1,540 | C | S00592. |
| RF-715 | Evaporator mounting | 5.0 | $770 | C | S00567. |
| RF-720 | Refrigerant charge + commission (vacuum, charge, test) | 3.0 | $462 | **A** | Consistent 2–4 (S00560, S00567, S01230, S01253). |
| RF-725 | R&R compressor (repair) | 3.5 | $539 | B | S00969, S01230. |
| RF-730 | Reefer maintenance inspection | 3.0 | $462 | **A** | Consistent recurring service (S01027, S01120, S01128, S01175, S01181, S01256). |
| RF-735 | Reefer diagnostics | 1.0 | $154 | B | S00652, S00670. |

---

## Chapter 8 — HVAC Systems

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| HV-800 ✓ | Rooftop A/C, tie-in to OEM (Ibiza/Webasto, evac + recharge) | 12.0 | $1,848 | **A** | Very consistent (Ibiza S00428–S00433, S00385; Webasto S00144). |
| HV-805 | Rooftop A/C to roof + soft starter (simpler) | 4.0 | $616 | C | S00764. |
| HV-810 | Espar / diesel heater install | 10.0 | $1,540 | **A** | Consistent (S00360, S00836, S00991, S01059, S00865). Simple under-desk kit 4–8. |
| HV-815 | Custom heater enclosure / pedestal | 4.0 | $616 | B | S00840, S00991, S01059, S01284. |
| HV-820 | A/C ducting, custom routing | 7.0 | $1,078 | C | S01135. |
| HV-825 | Roof vent / MaxxFan, per fan | 1.5 | $231 | B | Pair = 2 (S00964, S00975); + LVD wiring = 3 (S01177, S01291). |
| HV-830 | Prisoner-transport slide-in (insulation + slide-in + duct + fans + lights + trim) | 48.0 | $7,392 | B | S01140, S01285, S01298. Specialized package. |

---

## Chapter 9 — Shelving & Cabinets

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| SH-900 ✓ | Shelving install, per shelf, one side | 2.2 | $340 | **A** | Fixed product "Shelving Installation-1 Shelf". 2 shelves = 4.4 / $680. |
| SH-905 | Shelving unit assembly (72"×72", 5-shelf) | 1.0 | $154 | B | Assembly-only, separate from install (S01226, S01255). |
| SH-910 | Folding shelf + tank rack (plumber's pkg), assy + install | 6.0 | $924 | **A** | Consistent across plumber's-pkg orders (S01210–S01335). |
| SH-915 | Drawer install (Westcan, pair) | 6.0 | $924 | C | S01246. |
| SH-920 | Cabinet install, over-cab C-Tech (w/ bracing + demo) | 10.0 | $1,540 | C | S01196. |
| SH-925 | Locking door kits + bins to shelves | 1.0 | $154 | B | S01291, S01337. |
| SH-930 | Anti-slide angle along shelf floor | 1.0 | $154 | C | S01325. |

---

## Chapter 10 — Interior Components

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| IN-1100 | Wall liner install (prefab panel walls) | 2.0–3.0 | $308–$462 | B | Liner S01199 = 3; PreFab "Walls" fixed product = 2. |
| IN-1105 | Ceiling liner install | 1.0–2.0 | $154–$308 | B | Liner S01199 = 2; PreFab "Ceiling" fixed product = 1. |
| IN-1110 | Door liner install (prefab panel) | 1.0 | $154 | B | PreFab "Door" fixed product. |
| IN-1115 | Flooring, prefab panel | 1.5 | $231 | B | Fixed product "PREFABFLOOR". |
| IN-1120 | Liner modifications for outlets / ceiling lights | 3.0 | $462 | C | S01199. |
| IN-1125 | Plywood wall/ceiling panels, cut + upholster + install (full van) | 16.0 | $2,464 | B | S00013, S00029, S00030. |
| IN-1130 | E-track, per horizontal row | 1.0 | $154 | B | Single 5' rows ~1–2 hrs (S01335). |
| IN-1135 | E-track bulkhead package (2 rows + recessed D-rings) | 4.0 | $616 | **A** | Extremely consistent reefer-van package (S01202–S01335). |
| IN-1140 | Partition / bulkhead framing + plywood | 8.0 | $1,232 | B | 2x4 studs + plywood upper bulkhead (S01226, S01255). |
| IN-1145 | Reinforce door + heavy-gauge + E-track (security) | 2.0 | $308 | B | S01176, S01205–S01207. |

---

## Chapter 11 — Windows

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| WN-1200 | Window install, small (clamp-in, incl. water test) | ~2–3 | $570* | B | Fixed product "LaborWinSM" (*bundles labor + shipping). |
| WN-1205 | Window install, large (incl. water test) | ~4–5 | $1,095* | B | Fixed product "LabWinLG" (*bundles labor + shipping). |
| WN-1210 | Window security barrier, per opening / pair | 2.0 | $308 | **A** | Consistent (S00482, S01098–S01102). |
| WN-1215 | Vent window / roof vent install | 2.0 | $308 | B | S01046, S01177. |

_*Windows are currently priced as labor+shipping bundles, not hours. To fit the manual,
split out the pure-labor hours (small ≈ 2–3, large ≈ 4–5) and price freight separately._

---

## Chapter 12 — Seating & Mobility

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| MB-1000 ✓ | Wheelchair lift install (Braun, rear door) | 11.0 | $1,694 | B | S01130 (10), S00867 Braun (12). |
| MB-1005 | Seat install, per row / bench (FMVSS compliant) | 4.0 | $616 | **A** | Consistent (S00605, S00677, S01033, S01157). |
| MB-1010 | Seat mounting plates + floor build (FMVSS) | 8.0 | $1,232 | B | S01296. |
| MB-1015 | Full passenger-van seating (11 seats), assembly + install | 16.0 | $2,464 | C | Assembly 10 + install 6 (S00867). |
| MB-1020 | Seat swivel install | 2.0 | $308 | C | S00865. |
| MB-1025 | Bench seat covers, per bench | 2.0 | $308 | B | S01098–S01102. |
| MB-1030 | Ramp install (swivel-link / bifold) | 4.0 | $616 | B | S01157, S01307. |
| MB-1035 | Shoulder-belt / L-track (headliner mod), per side | 4.0 | $616 | B | S00867; both sides = 8 (S01130). |
| MB-1040 | Lift immobilization interlock | 8.0 | $1,232 | C | S00790. |

---

## Chapter 13 — Exterior Accessories

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| EX-1300 | Ladder rack install, 6' ladder spacing | 2.5 | $385 | **A** | Consistent (S00334, S00338, S00408, S00427). |
| EX-1302 | Ladder rack install, 8' ladder spacing | 3.5 | $539 | **A** | S00314, S00398, S00399. |
| EX-1304 | Ladder rack — single drop-down (fixed product) | 2.9 | $441 | B | "LABLRSD". Double drop-down = $595; cross-bars only = $287. |
| EX-1305 | Ladder rack R&R (remove / reinstall) | 1.0 | $154 | B | S00968. |
| EX-1310 | Running boards, standard, pair | 4.0 | $616 | **A** | S00367, S00790, S01242. |
| EX-1312 | Power running boards (AMP PowerStep, electric) | 8.0 | $1,232 | C | S00723. |
| EX-1315 | Grip steps, pair (driver + passenger) | 4.0 | $616 | **A** | Very consistent (S01140, S01285, S01298, S01334). |
| EX-1320 | Backup alarm | 1.0 | $154 | **A** | S00312, S01122. |
| EX-1325 | Backup / rear camera + mirror monitor | 3.5 | $539 | B | Rear camera + mirror = 3 (S00739); camera system w/ box = 4 (S00567). |
| EX-1330 | 360° camera system (calibrate + dual monitors) | 14.0 | $2,156 | C | S00764. |
| EX-1335 | RVS camera + sensor system, OEM-integrated | 16.0 | $2,464 | C | S00320. |
| EX-1340 | Roof-mounted conduit / material holder on rack | 2.0 | $308 | C | S00983. |

---

## Chapter 14 — Quality Control

| Code | Operation | Std hrs | Price | Conf | Notes / source |
|---|---|---|---|---|---|
| QC-1400 | Functional test + final inspection | 1.0 | $154 | B | S01273. Add to every build as a standard line. |
| QC-1405 | Whole-vehicle "finals" (final hookup + programming + test) | 6.0 | $924 | B | S00696, S00813, S00814, S01028. For loaded electrical builds. |

_Codes left open (1410+) for road test, leak inspection, final cleaning, customer
demonstration — currently folded into commissioning / finals rather than billed separately.
Decide whether to make them their own coded operations._

---

## High-confidence anchors (start here)

The **A-rated** operations — high volume, tight clustering, safe to standardize today.
These are ~80% of what we quote. Load these first:

| Code | Operation | Std hrs |
|---|---|---|
| ES-200 | Isolator + inverter package (standard van) | 2.5 |
| ES-205 | Aux battery + isolator relay + fusing | 8 |
| ES-225 | Interior work lights to D-pillars + LVD | 3 |
| EL-400 / 401 | Single / pair warning light | 1 / 2 |
| EL-410 | Strobe/warning set of 4 + switch | 6 |
| EL-420 | Cargo LED light bars to roof bows | 2.5 |
| SR-505 | Siren + switch + speaker package | 6 |
| SR-515 | Traffic advisor + controller | 6 |
| CM-600 | Antenna to roof + cable run | 2 |
| CM-605 | Prewire antennas / COG | 4 |
| RF-705 | Full refrigeration unit install | 30 |
| RF-720 | Refrigerant charge + commission | 3 |
| RF-730 | Reefer maintenance inspection | 3 |
| HV-800 | Rooftop A/C OEM tie-in | 12 |
| HV-810 | Espar / diesel heater | 10 |
| SH-900 | Shelving install, per shelf | 2.2 |
| SH-910 | Folding shelf + tank rack | 6 |
| IN-1135 | E-track bulkhead package | 4 |
| MB-1005 | Seat install, per row | 4 |
| EX-1300 / 1302 | Ladder rack, 6' / 8' | 2.5 / 3.5 |
| EX-1310 / 1315 | Running boards / grip steps, pair | 4 |
| EX-1320 | Backup alarm | 1 |

## How to get these into Odoo

Two ways, and they can layer:

1. **As service products** — create a labor product per coded operation (like the existing
   `LABPART`, `LABLRSD`, `PREFABFLOOR` fixed-price bundles), with the operation code as the
   Internal Reference / SKU and the standard hours baked into the price. Fastest for
   estimators: drop the operation on a quote, hours are already set. Best for the A-rated,
   high-repeat operations.
2. **On the relevant part products** — add the standard install hours (or a linked labor
   operation) to the part itself, so quoting the part auto-suggests its labor. Matches the
   manual's "add to the relevant products" goal but is more setup.

Suggested path: start with option 1 for the ~22 A-rated anchors (~80% of what we quote),
then expand to the B/C list and to per-part labor as the manual matures.

## Next steps / open questions

- **Tony to confirm the code scheme** (prefixes + blocks above) and the MB-1000 vs
  chapter-order question. Once locked, the codes become the SKUs in Odoo.
- **Validate the C-rated rows.** Thin data — confirm from experience or capture more.
- **Phase 2: measured times.** These are quoted hours; compare against actual technician
  timecard hours once we track them, to hit the manual's productivity-measurement goal.
- **Split window labor from freight** so windows fit the hours-based standard.
- Want me to generate the ready-to-create Odoo labor products for the A-rated anchors
  (code as SKU, name, hours, price)? Say the word and I'll build the load list.
