# Van Interior Dimensions

Working interior dimensions for every van we upfit. All numbers in inches.

## Sources

**Primary: Westcan 2026 catalogs.** Each has a "Vehicle Dimensions" spread in the first few
pages, measured to the 1/16" and zoned A through L. Updated July 8, 2026, so this is current.
Index page: https://westcanmanufacturing.com/catalogues/

The site is a FlowPaper viewer, but the raw PDFs are downloadable:

| Catalog | Dimension pages | PDF |
|---|---|---|
| Ford (Transit, Transit Connect) | 2 to 5 | `westcanmanufacturing.com/catalogue/ford/docs/Ford-2026-web-July-8.pdf` |
| Mercedes-Benz (Sprinter, Metris) | 2 to 5 | `.../catalogue/mercedes-benz/docs/Mercedes-2026-web-july-8.pdf` |
| RAM (ProMaster, ProMaster City) | 2 to 5 | `.../catalogue/ram/docs/RAM-2026-web-july-8.pdf` |
| GMC / Chevrolet (Savana, Express) | 2 to 3 | `.../catalogue/gmc/docs/GM-2026-web-july-8.pdf` |
| Nissan (NV, NV200) | 2 to 4 | `.../catalogue/nissan/docs/Nissan-2026-web-july-8.pdf` |

**Secondary: Sortimo by Knapheide catalogs** in Drive under Knapheide > Exxpand Archives
(https://drive.google.com/drive/folders/1i1Jr3Ck3oTt17stonjJjj6tvVYdO1XrK). Older and rounded to
whole inches, but a useful sanity check and the source of the base-package table at the bottom.

**Use these before every quote.** Any quote with shelving or mounted accessories gets a
fitment check against these tables first. The procedure is in
`.claude/skills/write-estimates/SKILL.md` under "Fitment check".

## Zone key

| Zone | What it is |
|---|---|
| A | Usable roof height (floor to ceiling at the wall, not the peak) |
| B | Van depth, wall to wall across the van |
| C | Door opening to rear end |
| D | Post-wheel well zone (behind the wheel well, toward the rear) |
| E | Wheel well obstruction (length along the wall) |
| F | Pre-wheel well zone (between the door opening and the wheel well) |
| G | Door opening, including trim |
| H | Partition zone |
| I | Available cargo space (the full usable run) |
| J | Wheel well to rear end |
| K | Partition zone to wheel well |
| L | Contoured partition zone (GM: partition zone to fuel filler) |

These tie together, which is how to catch a typo or a bad transcription:

- `I = C + G`
- `I = K + E + D`
- `J = E + D`
- `F = K - G`

**A is the number that kills jobs.** It's the usable height at the wall, always well under the
manufacturer's max cargo height, which is measured at the centerline peak. Size shelving off A.

## Ford

Transit, 2014 to 2025, 150/250/350. Transit Connect, 2014 to 2023.

| Zone | 130 Low | 130 Med | 148 Low | 148 Med | 148 High | 148 EWB High | Connect LWB |
|---|---|---|---|---|---|---|---|
| A Usable roof height | 51 | 66 7/8 | 51 | 66 7/8 | 76 1/4 | 76 1/4 | 47 5/16 |
| B Van depth | 61 1/8 | 61 1/8 | 61 1/8 | 61 1/8 | 61 1/8 | 61 1/8 | 43 1/8 |
| C Door opening to rear | 57 5/8 | 50 1/2 | 62 1/8 | 61 1/8 | 67 5/8 | 96 1/16 | 39 5/8 |
| D Post-wheel well | 13 1/4 | 13 1/4 | 6 1/16 | 6 1/16 | 13 5/16 | 41 15/16 | n/a |
| E Wheel well | 34 1/4 | 34 1/4 | 34 1/4 | 34 1/4 | 34 1/4 | 34 1/4 | 33 |
| F Pre-wheel well | 10 1/8 | 3 | 21 13/16 | 20 13/16 | 20 1/16 | 19 7/8 | 6 5/8 |
| G Door opening | 49 7/8 | 50 1/8 | 49 7/8 | 50 7/8 | 49 3/8 | 49 3/8 | 34 5/16 |
| H Partition zone | 7 3/4 | 7 3/4 | 7 3/4 | 7 3/4 | 7 3/4 | 7 3/4 | 6 11/16 |
| **I Available cargo space** | **107 1/2** | **100 5/8** | **112** | **112** | **117** | **145 7/16** | **73 15/16** |
| J Wheel well to rear | 47 1/2 | 47 1/2 | 40 5/16 | 40 5/16 | 47 9/16 | 76 3/16 | 33 |
| K Partition to wheel well | 60 | 53 1/8 | 71 11/16 | 71 11/16 | 69 7/16 | 69 1/4 | 40 15/16 |
| L Contoured partition zone | 13 7/8 | 13 7/8 | 13 7/8 | 13 7/8 | 13 7/8 | 13 7/8 | n/a |

Contoured partition deduction on all Transits: 6 1/8". Deduct that from the driver side when
the quote calls for a contoured partition.

Watch the 130 WB: the **medium roof loses about 7" of cargo length versus the low roof**
(100 5/8 vs 107 1/2), because the partition mounts further back. Easy to miss when a customer
upgrades the roof mid-quote.

The Transit floor drawing also carries a "5 3/4" do not exceed" zone along the outer floor edge.

## Mercedes-Benz

Sprinter 2007 to 2025. Metris 2015 to 2023.

| Zone | Metris 126 | Metris 135 | Sprinter 144 Std | Sprinter 144 High | Sprinter 170 High | Sprinter 170 EWB High |
|---|---|---|---|---|---|---|
| A Usable roof height | 50 3/8 | 50 3/8 | 62 5/8 | 74 3/4 | 74 3/4 | 74 3/4 |
| B Van depth | 58 13/16 | 58 13/16 | 61 1/8 | 61 1/8 | 61 1/8 | 61 1/8 |
| C Door opening to rear | 43 7/16 | 52 1/2 | 65 3/8 | 64 5/8 | 105 1/8 | 121 |
| D Post-wheel well | 11 5/8 | 4 1/4 | 17 | 16 3/4 | 31 5/16 | 47 1/16 |
| E Wheel well | 31 5/8 | 31 5/8 | 36 1/2 | 36 1/2 | 36 1/2 | 36 1/2 |
| F Pre-wheel well | 3/16 | 16 5/8 | 11 7/8 | 11 3/8 | 37 5/16 | 37 7/16 |
| G Door opening | 40 | 40 | 51 3/4 | 51 3/4 | 51 3/4 | 51 5/8 |
| H Partition zone | 7 1/8 | 7 1/8 | 7 1/2 | 7 1/2 | 7 1/2 | 7 1/2 |
| **I Available cargo space** | **83 7/16** | **92 1/2** | **117 1/8** | **116 3/8** | **156 7/8** | **172 5/8** |
| J Wheel well to rear | 43 1/4 | 35 7/8 | 53 1/2 | 53 1/4 | 67 13/16 | 83 9/16 |
| K Partition to wheel well | 40 3/16 | 56 5/8 | 63 5/8 | 63 1/8 | 89 1/16 | 89 1/16 |
| L Contoured partition zone | n/a | n/a | 12 1/8 | 12 1/8 | 12 1/8 | 12 1/8 |

Sprinter contoured partition deduction: 4 5/8".

**Super high roof** (2007 to 2018 Sprinter 2500/3500 only, not on the current van):

| Zone | 170 Super High | 170 EWB Super High |
|---|---|---|
| A Usable roof height | 83 | 83 |
| C Door opening to rear | 105 3/16 | 113 5/8 |
| D Post-wheel well | 25 9/16 | 33 13/16 |
| F Pre-wheel well | 43 1/8 | 43 5/16 |
| G Door opening | 51 11/16 | 51 5/8 |
| **I Available cargo space** | **156 7/8** | **165 1/4** |
| J Wheel well to rear | 62 1/16 | 70 5/16 |
| K Partition to wheel well | 94 13/16 | 94 15/16 |

Sprinter 144 standard roof and 144 high roof come out within 3/4" of each other on length. The
roof choice is about height (62 5/8 vs 74 3/4), not floor space.

## RAM

ProMaster 2013 to 2025. ProMaster City is discontinued but still comes through.

| Zone | 118 Low | 136 Low | 136 High | 159 High | 159 EWB High | PM City |
|---|---|---|---|---|---|---|
| A Usable roof height | 62 3/4 | 62 3/4 | 73 1/2 | 73 1/2 | 73 1/2 | 48 1/2 |
| B Van depth | 70 1/4 | 70 1/4 | 70 1/4 | 70 1/4 | 70 1/4 | 57 3/4 |
| C Door opening to rear | 46 1/8 | 56 13/16 | 56 13/16 | 81 | 94 3/4 | 37 3/4 |
| D Post-wheel well | 9 5/8 | 9 1/4 | 9 1/4 | 10 1/4 | 24 1/8 | 3/4 |
| E Wheel well | 34 1/2 | 34 1/2 | 34 1/2 | 34 1/2 | 34 1/2 | 29 1/4 |
| F Pre-wheel well | 2 | 13 3/16 | 13 3/16 | 36 1/4 | 36 1/4 | 7 3/4 |
| G Door opening | 39 3/4 | 46 3/8 | 46 3/8 | 46 3/8 | 46 3/8 | 28 |
| H Partition zone | 7 7/8 | 7 7/8 | 7 7/8 | 7 7/8 | 7 7/8 | 10 1/4 |
| **I Available cargo space** | **85 7/8** | **103 5/16** | **103 5/16** | **127 3/8** | **141 1/8** | **65 3/4** |
| J Wheel well to rear | 44 1/8 | 43 3/4 | 43 3/4 | 44 3/4 | 58 5/8 | 30 |
| K Partition to wheel well | 41 3/4 | 59 9/16 | 59 9/16 | 82 5/8 | 82 1/2 | 35 3/4 |
| L Contoured partition zone | 14 3/8 | 14 3/8 | 14 3/8 | 14 3/8 | 14 3/8 | n/a |

ProMaster contoured partition deduction: 6 1/2".

The ProMaster is the widest of the full-size vans at 70 1/4" wall to wall, but it also has the
biggest wheel well at 17" tall and 9" deep. That combination decides a lot of shelving layouts.
Low roof and high roof are identical on length, only A changes (62 3/4 vs 73 1/2).

## GM

Savana and Express, 2003 to 2025. Unchanged for two decades, so these numbers are stable.

| Zone | Regular WB | Extended WB |
|---|---|---|
| A Usable roof height | 52 | 52 |
| B Van depth | 55 | 55 |
| C Door opening to rear | 49 5/8 | 70 1/8 |
| D Post-wheel well | 10 | 10 1/16 |
| E Wheel well | 36 | 36 |
| F Pre-wheel well | 3 5/8 | 24 1/16 |
| G Door opening | 47 1/4 | 47 1/4 |
| H Partition zone | 7 7/8 | 7 7/8 |
| **I Available cargo space** | **96 7/8** | **117 3/8** |
| J Wheel well to rear | 46 | 46 1/16 |
| K Partition to wheel well | 50 7/8 | 71 5/16 |
| L Partition zone to fuel filler | 22 | 42 3/16 |

Note GM uses zone L for the **fuel filler**, not a contoured partition. The filler is an
intrusion you have to design around, box dimensions 8 3/8" L x 7 5/8" D x 8 5/16" H.

Express and Savana are the narrowest full-size at 55" wall to wall and the shortest at 52" of
usable height. Tall shelving does not fit, and the 36" wheel well is the longest of any van here.

## Nissan

NV 2012 to 2021, NV200 2013 to 2021. Both out of production, used units still come through.

| Zone | NV Std Roof | NV High Roof | NV200 |
|---|---|---|---|
| A Usable roof height | 50 3/4 | 72 1/8 | 51 1/4 |
| B Van depth | 61 1/4 | 61 1/4 | 43 1/2 |
| C Door opening to rear | 55 1/8 | 55 1/8 | 30 5/8 |
| D Post-wheel well | 15 3/8 | 15 3/8 | 1/8 |
| E Wheel well | 37 5/8 | 37 5/8 | 29 5/8 |
| F Pre-wheel well | 3 1/8 | 3 1/8 | 7/8 |
| G Door opening | 43 3/16 | 43 3/16 | 29 |
| H Partition zone | 6 3/8 | 6 3/8 | 3 3/8 |
| **I Available cargo space** | **101 5/16** | **101 5/16** | **59 5/8** |
| J Wheel well to rear | 52 | 52 | 29 3/4 |
| K Partition to wheel well | 49 5/16 | 49 5/16 | 29 7/8 |

Westcan's own note: the NV's rear wheel wells are irregularly shaped and **different left to
right**. Measure the actual van before committing to a symmetrical layout.

## Wheel wells

L is length along the wall, D is how far it intrudes into the van, H is height off the floor.

| Van | L | D | H |
|---|---|---|---|
| Transit | 34 1/4 | 7 1/4 | 10 1/2 |
| Sprinter 2500 / 3500XD | 36 1/2 | 8 1/2 | 12 1/2 |
| Sprinter 3500 / 4500 (dual rear wheel) | 36 1/2 | 16 | 12 1/2 |
| Metris | 31 5/8 | 7 | 13 1/2 |
| ProMaster | 34 1/2 | 9 | 17 |
| ProMaster City | 29 1/4 | 5 3/8 | 17 7/16 (second callout 16 3/4) |
| Savana / Express | 36 | 9 1/2 | 12 |
| NV, driver side | 37 5/8 | 8 3/16 | 11 7/8 |
| NV, passenger side | 34 5/8 | 7 7/8 | 9 3/8 |
| NV200 | 29 5/8 | 4 | 11 |
| Transit Connect | see note | see note | see note |

**Dual rear wheel Sprinters intrude 16" instead of 8 1/2".** Nearly double. If a fleet quote
mixes 3500XD and 4500 chassis, the shelving is not interchangeable.

**Transit Connect:** Westcan's table prints L 5 1/4", D 10 5/8", H 16 7/8", which is transposed.
Zone E on the same page gives the obstruction length as 33". Measure the van, don't trust the box.

## Cross-check against OEM published specs

Customers and dealers quote the brochure. Those are measured at the widest and tallest point of
an empty van with no partition, so they always read bigger. Use them for conversation, use the
Westcan numbers for fitment.

| | Transit | Sprinter | ProMaster |
|---|---|---|---|
| Max cargo width | 70.2 | 70.0 | 75.6 |
| Between wheelhousings | 54.8 | 53.0 | 55.8 |
| Max cargo height | 56.9 / 72.0 / 81.5 | 68 std, 79 high | 65.4 low, 76.0 high |
| Cargo length | 126.0 / 143.7 / 172.2 | 133 / 173 / 189 | 105.1 / 122.8 / 145.9 / 160.2 |
| Side door opening W | 51.4 | not published as one figure | 42.3 |

ProMaster's 75.6" max width is at shoulder height, well above the 70 1/4" you get wall to wall.
Don't promise a customer 75" of usable width.

## Knapheide base shelving package by van

From the KVE sell sheets (Drive: Knapheide > Sell Sheets). Part codes read height x length, so
`4660-1` is 46" tall by 60" long.

| Van | Package | Street side | Curb side |
|---|---|---|---|
| Transit Connect LWB | BP44L | 4460-1 | 4460-1 |
| Transit 130 med roof | BP624L | 4660-1 + ext 4260-2 | 4460-1 |
| Transit 148 low roof | BP624M | 4680-1 + ext 4280-2 | 4480-1 |
| Transit 148 med roof | BP646L | 4660-1 + ext 4460-2 | 4660-1 |
| Transit 148 high roof | BP646M | 4680-1 + ext 4480-2 | 4680-1 |
| Transit 148 EXT high roof | BP646H | 46100-1 + ext 44100-2 | 46100-1 |
| ProMaster City | BP44L | 4460-1 | 4460-1 |
| ProMaster 118 low roof | BP64M | 4680-1 | 4480-1 |
| ProMaster 136 low roof | BP624M | 4680-1 + ext 4280-2 | 4480-1 |
| ProMaster 136 high roof | BP624H | 4100-1 + ext 42100-2 | 44100-1 |
| ProMaster 159 high roof | BP646H | 46100-1 + ext 44100-2 | 46100-1 |
| ProMaster 159 EXT high roof | BP666H | 46100-1 + ext 46100-2 | 46100-1 |
| Metris 126 | BP64L | 4660-1 | 4460-1 |
| Metris 135 | BP624L | 4660-1 + ext 4260-2 | 4460-1 |
| Sprinter 144 std roof | BP646M | 4680-1 + ext 4480-2 | 4680-1 |
| Sprinter 144 high roof | BP646H | 46100-1 + ext 44100-2 | 46100-1 |
| Sprinter 170 high roof | BP666H | 46100-1 + ext 46100-2 | 46100-1 |
| Express/Savana 135 | BP624L | 4660-1 + ext 4260-2 | 4460-1 |
| Express/Savana 155 | BP646L | 4660-1 + ext 4460-2 | 4660-1 |
| NV200 | BP44L | 4460-1 | 4460-1 |
| NV Cargo std roof | BP624L | 4660-1 + ext 4260-2 | 4460-1 |
| NV Cargo high roof | BP624H | 46100-1 + ext 42100-2 | 44100-1 |

For the Westcan side, packages are keyed to roof and length. See `references/vin-decoding.md`:
ABP9660 is 148" WB medium or high roof, ABP6060 is 148" WB EXT.

## Caveats

- Westcan and Knapheide measure differently and their numbers do not match. Westcan's available
  cargo space runs 5" to 20" longer than Knapheide's floor length on the same van, because they
  place the partition differently. Use one source per quote, don't mix them.
- The Westcan catalogs list model years ending 2025 on most vans. The sheet metal hasn't changed
  on any of them, but re-verify after a redesign.
- Knapheide's older numbers are in `Knapheide > Exxpand Archives` in Drive if you need a second
  opinion: Ford pages 95 to 98, Ram 81 to 83, Mercedes 80 to 82, GM 68 to 69, Nissan 70.
